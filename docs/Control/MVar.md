# MVar
**Lean:** `LeanStd.Control.Concurrent.MVar` | **Haskell:** `Control.Concurrent.MVar`

## Overview
A synchronisation variable that is either empty or holds a value of type `a`. All blocking is promise-based: waiting tasks are dormant `IO.Promise` values, not blocked OS threads. This allows scaling to millions of concurrent tasks.

MVar is the fundamental building block for all other concurrency primitives in lean-std (`Chan`, `QSem`, `QSemN`).

## Concurrent Type Alias

```
abbrev Concurrent (a : Type) := BaseIO (Task a)
```

Any function returning `Concurrent a` is non-blocking by construction. Compose with `BaseIO.bindTask`:

```lean
let task <- mv.take        -- Concurrent a = BaseIO (Task a)
BaseIO.bindTask task fun val => ...
```

## API Mapping
| Lean | Haskell | Kind | Signature |
|------|---------|------|-----------|
| `MVar.new` | `newMVar` | Constructor | `a -> BaseIO (MVar a)` |
| `MVar.newEmpty` | `newEmptyMVar` | Constructor | `BaseIO (MVar a)` |
| `MVar.take` | `takeMVar` | Async op | `MVar a -> BaseIO (Task a)` |
| `MVar.put` | `putMVar` | Async op | `MVar a -> a -> BaseIO (Task Unit)` |
| `MVar.read` | `readMVar` | Async op | `MVar a -> BaseIO (Task a)` |
| `MVar.swap` | `swapMVar` | Async op | `MVar a -> a -> BaseIO (Task a)` |
| `MVar.withMVar` | `withMVar` | Combinator | `MVar a -> (a -> BaseIO (a x b)) -> BaseIO (Task b)` |
| `MVar.modify` | `modifyMVar` | Combinator | `MVar a -> (a -> BaseIO (a x b)) -> BaseIO (Task b)` |
| `MVar.modify_` | `modifyMVar_` | Combinator | `MVar a -> (a -> BaseIO a) -> BaseIO (Task Unit)` |
| `MVar.tryTake` | `tryTakeMVar` | Non-blocking | `MVar a -> BaseIO (Option a)` |
| `MVar.tryPut` | `tryPutMVar` | Non-blocking | `MVar a -> a -> BaseIO Bool` |
| `MVar.tryRead` | `tryReadMVar` | Non-blocking | `MVar a -> BaseIO (Option a)` |
| `MVar.isEmpty` | `isEmptyMVar` | Query | `MVar a -> BaseIO Bool` |
| `MVar.takeSync` | *(N/A)* | Sync wrapper | `MVar a -> BaseIO a` |
| `MVar.putSync` | *(N/A)* | Sync wrapper | `MVar a -> a -> BaseIO Unit` |
| `MVar.readSync` | *(N/A)* | Sync wrapper | `MVar a -> BaseIO a` |

## Constraint: `[Nonempty a]`

Blocking operations (`take`, `read`, `swap`, `withMVar`, `modify`, `modify_`) require `[Nonempty a]` for `IO.Promise` construction. Non-blocking `try*` operations do not require this constraint.

## Proofs & Guarantees

### Structural Invariant
Maintained by all operations:
- If `value.isSome`, then `takers` is empty (no one waits when a value exists).
- If `value.isNone`, then `putters` is empty (no one waits to put when empty).

### FIFO Fairness
Waiters are queued in `Std.Queue` and dequeued in insertion order. Both takers and putters are served FIFO.

### No Lost Wakeups
- Every `put` on an empty MVar with a taker wakes exactly one taker.
- Every `take` on a full MVar with a putter wakes exactly one putter.
- Proof by case analysis on the match branches in `take`/`put`.

### Axiom-Dependent Properties (documented, not machine-checked)
- **Linearizability** -- depends on `Std.Mutex` providing mutual exclusion.
- **Starvation-freedom** -- depends on Lean's task scheduler being eventually fair and on complementary operations eventually occurring.
- **Progress** -- follows from no-lost-wakeups + mutex correctness.

## Example
```lean
import LeanStd.Control.Concurrent.MVar

open LeanStd

-- Create an MVar with an initial value
let mv <- MVar.new 42

-- Non-blocking try operations
let val <- mv.tryRead    -- some 42
let ok  <- mv.tryPut 99  -- false (MVar is full)

-- Async take (returns a Task)
let task <- mv.take
let val  <- IO.wait task  -- 42 (MVar is now empty)

-- Async put
let task <- mv.put 100
IO.wait task              -- MVar now holds 100

-- Modify with result
let task <- mv.modify fun x => pure (x + 1, x)
let old  <- IO.wait task  -- 100 (MVar now holds 101)

-- Sync wrappers (block OS thread -- prefer async versions)
let v <- mv.takeSync      -- 101
mv.putSync 200
```

## Performance Notes
- **Promise-based blocking:** Waiters are dormant promises, not spinning or sleeping OS threads. A million waiting tasks consume memory for the promise objects but no OS thread resources.
- **Mutex contention:** All operations go through `Std.Mutex.atomically`. Under extreme contention, this is the bottleneck.
- **Sync wrappers (`takeSync`, `putSync`, `readSync`)** block an OS thread via `IO.wait`. Use them only at top-level or in non-scalable contexts; prefer the async versions for concurrent code.
- **`isEmpty` is a snapshot:** The result may be stale by the time you act on it. Do not use it for synchronisation.
