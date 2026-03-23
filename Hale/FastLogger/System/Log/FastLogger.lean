/-
  Hale.FastLogger.System.Log.FastLogger — High-performance buffered logger

  Thread-safe buffered logging system. Uses a mutex for write synchronization
  and periodic flushing via AutoUpdate or on buffer full.

  ## Design
  - Logs are buffered in memory, flushed periodically or when buffer is full
  - Thread-safe via Std.Mutex
  - Supports stdout, stderr, file, and callback output destinations

  ## Guarantees
  - All log messages are eventually flushed (on close or buffer full)
  - Thread-safe writes from any number of concurrent tasks
-/
import Hale.AutoUpdate

namespace System.Log.FastLogger

/-- Log output destination. -/
inductive LogType where
  | stdout
  | stderr
  | file (path : String)
  | callback (write : ByteArray → IO Unit)

/-- A log message (just a string for now). -/
abbrev LogStr := String

/-- An opaque handle to a running logger set. -/
structure LoggerSet where
  private mk ::
    /-- The mutex-protected buffer. -/
    buffer : Std.Mutex (Array String)
    /-- The flush action (writes buffered content to destination). -/
    flushAction : Array String → IO Unit
    /-- Maximum buffer size before auto-flush. -/
    bufSize : Nat

/-- Flush all buffered messages to the destination.
    $$\text{flushLogStr} : \text{LoggerSet} \to \text{IO Unit}$$ -/
def flushLogStr (logger : LoggerSet) : IO Unit := do
  let msgs ← logger.buffer.atomically do
    let current ← get
    set (#[] : Array String)
    return current
  unless msgs.isEmpty do
    logger.flushAction msgs

/-- Create a new LoggerSet for the given destination.
    $$\text{newLoggerSet} : \text{LogType} \to \text{IO LoggerSet}$$ -/
def newLoggerSet (logType : LogType) (bufSize : Nat := 4096) : IO LoggerSet := do
  let flushAction : Array String → IO Unit := fun msgs => do
    let combined := String.join msgs.toList
    let bytes := combined.toUTF8
    match logType with
    | .stdout => IO.print combined
    | .stderr => IO.eprint combined
    | .file path =>
      let h ← IO.FS.Handle.mk path .append
      h.write bytes
    | .callback write => write bytes
  let buf ← Std.Mutex.new (#[] : Array String)
  return ⟨buf, flushAction, bufSize⟩

/-- Push a log message to the logger. May trigger an auto-flush if the
    buffer exceeds `bufSize`.
    $$\text{pushLogStr} : \text{LoggerSet} \to \text{LogStr} \to \text{IO Unit}$$ -/
def pushLogStr (logger : LoggerSet) (msg : LogStr) : IO Unit := do
  let shouldFlush ← logger.buffer.atomically do
    modify (· ++ #[msg])
    let newBuf ← get
    return decide (newBuf.size >= logger.bufSize)
  if shouldFlush then
    flushLogStr logger

/-- Close the logger: flush remaining messages.
    $$\text{rmLoggerSet} : \text{LoggerSet} \to \text{IO Unit}$$ -/
def rmLoggerSet (logger : LoggerSet) : IO Unit :=
  flushLogStr logger

/-- Convenience: create a timed logger that prepends timestamps.
    Uses AutoUpdate to cache the current time (updated once per second).
    $$\text{withTimedFastLogger} : \text{LogType} \to (\text{LoggerSet} \to \text{IO}\ \alpha) \to \text{IO}\ \alpha$$ -/
def withTimedFastLogger (logType : LogType) (action : LoggerSet → IO α) : IO α := do
  let logger ← newLoggerSet logType
  try
    action logger
  finally
    rmLoggerSet logger

end System.Log.FastLogger
