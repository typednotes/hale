# LeanStd.Control — Concurrency Primitives

Phase 6 of the lean-std library: concurrent programming primitives ported from Haskell's `Control.Concurrent` family.

## Design Philosophy

All concurrency primitives are **promise-based**, not OS-thread-based. Blocking operations return `BaseIO (Task a)` rather than suspending an OS thread. This enables scaling to millions of concurrent "threads" on Lean's task-pool scheduler.

Cancellation is **cooperative**: `killThread` sets a `CancellationToken` rather than throwing an asynchronous exception. CPU-bound threads that never check the token will not be interrupted.

## Modules

- [Concurrent](Concurrent.md) — `Control.Concurrent`: ThreadId, forkIO, forkFinally, threadDelay, yield, killThread
- [MVar](MVar.md) — `Control.Concurrent.MVar`: synchronisation variables with FIFO fairness
- [Chan](Chan.md) — `Control.Concurrent.Chan`: unbounded FIFO channels with subscriber-based dup
- [QSem](QSem.md) — `Control.Concurrent.QSem`: quantity semaphores
- [QSemN](QSemN.md) — `Control.Concurrent.QSemN`: generalised quantity semaphores

## Haskell Module Mapping

| Lean Module | Haskell Module |
|---|---|
| `LeanStd.Control.Concurrent` | `Control.Concurrent` |
| `LeanStd.Control.Concurrent.MVar` | `Control.Concurrent.MVar` |
| `LeanStd.Control.Concurrent.Chan` | `Control.Concurrent.Chan` |
| `LeanStd.Control.Concurrent.QSem` | `Control.Concurrent.QSem` |
| `LeanStd.Control.Concurrent.QSemN` | `Control.Concurrent.QSemN` |

## Key Type: `Concurrent`

```
abbrev Concurrent (a : Type) := BaseIO (Task a)
```

Any function returning `Concurrent a` is non-blocking by construction. Compose concurrent actions with `BaseIO.bindTask`.

## Performance Notes

- **No OS threads consumed while waiting.** Waiters are dormant `IO.Promise` values resolved by the producing side.
- **Millions of concurrent tasks** are feasible because the thread pool is fixed-size and tasks are lightweight.
- **Mutex contention** is the primary bottleneck under high concurrency; all primitives use `Std.Mutex` for state protection.
- **`threadDelay` granularity** is milliseconds (Lean's `IO.sleep`); microsecond values are rounded up.
