# QSem
**Lean:** `LeanStd.Control.Concurrent.QSem` | **Haskell:** `Control.Concurrent.QSem`

## Overview
A simple quantity semaphore: at most `n` resources can be acquired concurrently. All blocking is promise-based. Waiters are served in FIFO order.

## API Mapping
| Lean | Haskell | Kind | Signature |
|------|---------|------|-----------|
| `QSem.new` | `newQSem` | Constructor | `Nat -> BaseIO QSem` |
| `QSem.wait` | `waitQSem` | Async op | `QSem -> BaseIO (Task Unit)` |
| `QSem.signal` | `signalQSem` | Function | `QSem -> BaseIO Unit` |
| `QSem.withSem` | *(bracket pattern)* | Combinator | `QSem -> IO a -> IO a` |

## Proofs & Guarantees

### Non-Negative Count
The count is `Nat` by construction -- it cannot underflow below zero.

### Structural Invariant

```
count > 0  =>  waiters = empty
```

If resources are available, no one should be waiting. Maintained by `signal`: it wakes a waiter before incrementing the count.

### FIFO Fairness
Waiters are queued in `Std.Queue` and dequeued in insertion order.

### No Lost Wakeups
`signal` either wakes exactly one waiter or increments the count. Both branches are mutually exclusive (case split on `waiters.dequeue?`).

### Exception Safety
`withSem` uses try/finally to ensure `signal` is called even if the action throws.

## Example
```lean
import LeanStd.Control.Concurrent.QSem

open LeanStd

-- Create a semaphore allowing 3 concurrent accesses
let sem <- QSem.new 3

-- Acquire one unit (async, non-blocking by type)
let task <- sem.wait
IO.wait task

-- Release one unit
sem.signal

-- Bracket pattern: acquire, run, release
let result <- sem.withSem do
  -- at most 3 threads run this section concurrently
  pure 42
```

## Performance Notes
- **Promise-based blocking:** A `wait` on an exhausted semaphore creates a dormant promise. No OS thread is consumed while waiting.
- **`withSem` blocks an OS thread** via `IO.wait` for the initial acquire. For fully non-blocking usage, call `wait` directly and chain with `BaseIO.bindTask`.
- **Mutex contention:** Both `wait` and `signal` go through `Std.Mutex.atomically`. Under high contention this is the bottleneck.
- **Single-unit granularity:** For multi-unit acquire/release, use `QSemN` instead.
