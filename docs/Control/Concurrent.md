# Concurrent
**Lean:** `LeanStd.Control.Concurrent` | **Haskell:** `Control.Concurrent`

## Overview
Thread management primitives: forking lightweight threads, cooperative cancellation, delays, and yielding. Threads run on Lean's task pool via `IO.asTask`, not as 1:1 OS threads.

## API Mapping
| Lean | Haskell | Kind |
|------|---------|------|
| `ThreadId` | `ThreadId` | Type |
| `forkIO` | `forkIO` | Function |
| `forkFinally` | `forkFinally` | Function |
| `killThread` | `killThread` | Function |
| `threadDelay` | `threadDelay` | Function |
| `yield` | `yield` | Function |
| `waitThread` | *(no direct equivalent)* | Function |

## Differences from GHC

| Aspect | GHC | lean-std |
|--------|-----|----------|
| Thread model | Green threads with RTS scheduler | `IO.asTask` on Lean's thread pool |
| Cancellation | Asynchronous exceptions (`throwTo`) | Cooperative `CancellationToken` |
| `threadDelay` unit | Microseconds | Microseconds (converted internally to ms, rounded up) |
| Thread ID uniqueness | Runtime-assigned, may be reused | Monotonic `Nat` counter, never reused |

## Instances
- `BEq ThreadId` — equality by `id` field
- `Hashable ThreadId` — hash of `id` field
- `ToString ThreadId` — `"ThreadId(n)"`
- `Repr ThreadId` — `"ThreadId(n)"`

## `ThreadId` Structure

```
structure ThreadId where
  private mk ::
  id : Nat                              -- unique, monotonic
  private task : Task (Except IO.Error Unit)
  private cancelToken : Std.CancellationToken
```

Fields `task` and `cancelToken` are private; the only public field is `id`.

## Proofs & Guarantees
- **Unique IDs by construction:** `freshThreadId` reads and increments a global monotonic counter. Within a single process, no two `ThreadId` values share the same `id`.
- **`forkFinally` finaliser guarantee:** The `finally_` callback runs in both the success and error branches of a try/catch, so it executes regardless of outcome.
- **Cooperative cancellation only:** `killThread` sets a `CancellationToken`; it does not forcibly terminate the thread. A thread that never checks the token will continue running.

## Example
```lean
import LeanStd.Control.Concurrent

open LeanStd

-- Fork a thread that prints a message
let tid <- forkIO do
  IO.println "hello from thread"

-- Fork with a finaliser
let tid2 <- forkFinally (do IO.println "working..."; pure 42) fun
  | .ok val   => IO.println s!"done: {val}"
  | .error e  => IO.println s!"failed: {e}"

-- Cooperative cancellation
killThread tid

-- Delay for 1 second (1_000_000 microseconds)
threadDelay 1000000

-- Yield to other threads
yield

-- Wait for a thread to complete
waitThread tid2
```

## Performance Notes
- `forkIO` is lightweight: it schedules a task on the thread pool, not an OS thread.
- `threadDelay` has millisecond granularity due to `IO.sleep`. A request for 1 microsecond will sleep for 1 millisecond.
- `yield` is equivalent to `IO.sleep 0`, giving other tasks a chance to run.
