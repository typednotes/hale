# FastLogger -- Buffered Thread-Safe Logging

**Lean:** `Hale.FastLogger` | **Haskell:** `fast-logger`

High-performance buffered logger with mutex synchronization and periodic flushing via AutoUpdate. Supports stdout, stderr, file, and callback destinations.

## Key Types

| Type | Description |
|------|-------------|
| `LogType` | `stdout \| stderr \| file \| callback` |
| `LogStr` | `String` (log message) |

## Files
- `Hale/FastLogger/System/Log/FastLogger.lean` -- LogType, LogStr, logger lifecycle
