/-
  Hale.Network.Network.Socket.EventDispatcher — Event loop ↔ Green monad bridge

  Routes kqueue/epoll readiness events to IO.Promise-based waiters, allowing
  Green threads to suspend without blocking pool threads while waiting for
  socket I/O readiness.

  ## Design

  A single dedicated OS thread runs the dispatch loop, calling
  `EventLoop.wait` in a tight loop. When a socket becomes ready, the
  dispatcher resolves the corresponding `IO.Promise`, which wakes the
  Green thread that was awaiting it (via `GreenBase.await`).

  ## Guarantees (axiom-dependent)

  - **No pool starvation:** Green threads that call `waitReadable`/`waitWritable`
    free their pool thread via `GreenBase.await` (uses `BaseIO.bindTask`).
  - **One-shot semantics:** Each waiter is resolved exactly once and removed.
  - **Thread safety:** The waiter map is protected by `Std.Mutex`.
-/

import Hale.Network.Network.Socket
import Hale.Base.Control.Concurrent.Green

namespace Network.Socket

open Control.Concurrent.Green

/-- A waiter entry: the Promise to resolve and the event type being waited for. -/
private structure Waiter where
  promise : IO.Promise Unit
  events  : EventType

/-- Event dispatcher: bridges kqueue/epoll events to Green thread suspensions.

    Create with `EventDispatcher.create`, use `waitReadable`/`waitWritable`
    to suspend Green threads, and `shutdown` to stop the dispatch loop.

    The waiter map uses `Nat` keys (converted from `USize` fds) to avoid
    compiled-mode ABI issues with scalar types in closures. -/
structure EventDispatcher where
  private mk ::
  eventLoop : EventLoop
  waiters   : Std.Mutex (Std.HashMap Nat (List Waiter))
  running   : IO.Ref Bool

namespace EventDispatcher

/-- Register a waiter for a socket fd and add it to the event loop. Internal.
    Takes RawSocket directly to avoid compiled-mode issues with phantom-
    parameterized structure unwrapping. -/
private def register (disp : EventDispatcher) (raw : RawSocket)
    (evts : EventType) : IO (IO.Promise Unit) := do
  let fdNat ← FFI.socketGetFd raw
  let promise ← IO.Promise.new
  let waiter : Waiter := { promise := promise, events := evts }
  let fdRef ← IO.mkRef fdNat
  disp.waiters.atomically fun wRef => do
    let fd ← fdRef.get
    let ws ← wRef.get
    let existing := ws.getD fd []
    wRef.set (ws.insert fd (waiter :: existing))
  -- Register interest with the event loop
  FFI.eventLoopAdd disp.eventLoop raw evts.flags
  pure promise

/-- Check if an event matches what a waiter is waiting for. -/
private def waiterMatches (evType : EventType) (w : Waiter) : Bool :=
  (evType.hasReadable && w.events.hasReadable) ||
  (evType.hasWritable && w.events.hasWritable) ||
  evType.hasError

/-- The dispatch loop. Runs on a dedicated OS thread. -/
private partial def dispatchLoop (disp : EventDispatcher) : IO Unit := do
  while ← disp.running.get do
    let events ← EventLoop.wait disp.eventLoop 1
    for ev in events do
      let fd : Nat := ev.socketFd
      let evType := ev.events
      -- Store fd in IO.Ref to avoid capturing scalar in atomically closure
      let fdRef ← IO.mkRef fd
      disp.waiters.atomically fun wRef => do
        let fd ← fdRef.get
        let ws ← wRef.get
        match ws[fd]? with
        | none => pure ()
        | some waiterList =>
          let (toResolve, remaining) := waiterList.partition (waiterMatches evType)
          for w in toResolve do
            w.promise.resolve ()
          if remaining.isEmpty then
            wRef.set (ws.erase fd)
          else
            wRef.set (ws.insert fd remaining)

/-- Create a new EventDispatcher with a running dispatch loop. -/
def create : IO EventDispatcher := do
  let el ← EventLoop.create
  let waiters ← Std.Mutex.new {}
  let running ← IO.mkRef true
  let disp : EventDispatcher := EventDispatcher.mk el waiters running
  -- Start the dispatch loop on a dedicated OS thread
  let _ ← IO.asTask (prio := .dedicated) (dispatchLoop disp)
  pure disp

/-- Stop the dispatch loop and close the event loop. -/
def shutdown (disp : EventDispatcher) : IO Unit := do
  disp.running.set false
  EventLoop.close disp.eventLoop

/-- Wait for a socket to become readable. Suspends the Green thread
    (frees the pool thread) and resumes when the socket is readable.
    $$\text{waitReadable} : \text{EventDispatcher} \to \text{Socket}\ s \to \text{Green Unit}$$ -/
def waitReadable (disp : EventDispatcher) (s : Socket state) : Green Unit := do
  let promise : IO.Promise Unit ← (disp.register s.raw EventType.readable : IO _)
  Green.await promise.result!

/-- Wait for a socket to become writable. Suspends the Green thread
    (frees the pool thread) and resumes when the socket is writable.
    $$\text{waitWritable} : \text{EventDispatcher} \to \text{Socket}\ s \to \text{Green Unit}$$ -/
def waitWritable (disp : EventDispatcher) (s : Socket state) : Green Unit := do
  let promise : IO.Promise Unit ← (disp.register s.raw EventType.writable : IO _)
  Green.await promise.result!

/-- Send all bytes on a connected socket, using the event loop for
    backpressure (waits for writability on wouldBlock).
    $$\text{sendAllGreen} : \text{EventDispatcher} \to \text{Socket .connected} \to \text{ByteArray} \to \text{Green Unit}$$ -/
partial def sendAllGreen (disp : EventDispatcher) (s : Socket .connected)
    (data : ByteArray) : Green Unit := do
  let mut offset := 0
  while offset < data.size do
    let outcome : SendOutcome ← (Network.Socket.send s (data.extract offset data.size) : IO _)
    match outcome with
    | .sent n => offset := offset + n
    | .wouldBlock => disp.waitWritable s
    | .error e => throw (IO.userError s!"sendAllGreen: {e}")

/-- Receive data from a connected socket, waiting for readability first.
    $$\text{recvGreen} : \text{EventDispatcher} \to \text{Socket .connected} \to \text{Nat} \to \text{Green RecvOutcome}$$ -/
def recvGreen (disp : EventDispatcher) (s : Socket .connected)
    (maxlen : Nat := 4096) : Green RecvOutcome := do
  disp.waitReadable s
  let outcome : RecvOutcome ← (Network.Socket.recv s maxlen : IO _)
  pure outcome

end EventDispatcher

end Network.Socket
