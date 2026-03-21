# QSemN
**Lean:** `LeanStd.Control.Concurrent.QSemN` | **Haskell:** `Control.Concurrent.QSemN`

## Overview
A generalised quantity semaphore that allows acquiring and releasing arbitrary amounts of a resource. Like `QSem`, but `wait` and `signal` take a `Nat` parameter for the number of units.

## API Mapping
| Lean | Haskell | Kind | Signature |
|------|---------|------|-----------|
| `QSemN.new` | `newQSemN` | Constructor | `Nat -> BaseIO QSemN` |
| `QSemN.wait` | `waitQSemN` | Async op | `QSemN -> Nat -> BaseIO (Task Unit)` |
| `QSemN.signal` | `signalQSemN` | Function | `QSemN -> Nat -> BaseIO Unit` |
| `QSemN.withSemN` | *(bracket pattern)* | Combinator | `QSemN -> Nat -> IO a -> IO a` |

## Proofs & Guarantees

### Non-Negative Count
The count is `Nat` by construction -- it cannot underflow below zero.

### Structural Invariant

```
count >= n  =>  no waiter requesting <= n is queued
```

When `signal` adds resources, it greedily wakes FIFO-ordered waiters whose requested amount can be satisfied.

### Greedy FIFO Wakeup
`signal` calls `wakeWaiters`, which iterates from the front of the queue and wakes each waiter whose `needed` amount is less than or equal to the current count. It stops at the first waiter that cannot be satisfied (head-of-line blocking, matching Haskell semantics).

### No Lost Wakeups
`signal` always either wakes one or more waiters or leaves the increased count for future `wait` calls. The `wakeWaiters` loop is exhaustive up to the first unsatisfiable request.

### Exception Safety
`withSemN` uses try/finally to ensure `signal n` is called even if the action throws.

## Example
```lean
import LeanStd.Control.Concurrent.QSemN

open LeanStd

-- Create a semaphore with 100 units (e.g., bytes of bandwidth)
let sem <- QSemN.new 100

-- Acquire 30 units
let task <- sem.wait 30
IO.wait task

-- Release 30 units
sem.signal 30

-- Bracket pattern: acquire n, run, release n
let result <- sem.withSemN 50 do
  -- up to 100 units can be held concurrently
  pure "done"
```

## Greedy Wakeup Detail

When `signal n` is called, the internal `wakeWaiters` function runs:

1. Peek at the front waiter `(needed, promise)`.
2. If `count >= needed`, subtract `needed` from `count`, resolve `promise`, and repeat from step 1.
3. If `count < needed`, stop. The waiter remains queued (head-of-line blocking).
4. If the queue is empty, stop.

This means a large request at the front of the queue can block smaller requests behind it, even if enough resources are available for the smaller ones. This matches Haskell's `QSemN` semantics.

## Performance Notes
- **Promise-based blocking:** A `wait` on an exhausted semaphore creates a dormant promise. No OS thread is consumed while waiting.
- **`withSemN` blocks an OS thread** via `IO.wait` for the initial acquire. For fully non-blocking usage, call `wait` directly and chain with `BaseIO.bindTask`.
- **Wakeup cost:** `signal` may wake multiple waiters in a single call (greedy loop), all within a single `Std.Mutex.atomically` block.
- **Head-of-line blocking:** A large request at the front of the queue prevents smaller requests behind it from being satisfied. Consider whether this is acceptable for your workload.
