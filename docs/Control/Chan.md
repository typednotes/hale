# Chan
**Lean:** `LeanStd.Control.Concurrent.Chan` | **Haskell:** `Control.Concurrent.Chan`

## Overview
An unbounded FIFO channel with subscriber-based duplication. Internally uses a `Std.Queue` buffer protected by a `Std.Mutex`, with a queue of reader promises for when the buffer is empty. A shared write-side mutex holds the subscriber list, enabling `dup`.

All blocking uses promises: `read` returns `BaseIO (Task a)`, never blocking an OS thread.

## API Mapping
| Lean | Haskell | Kind | Signature |
|------|---------|------|-----------|
| `Chan.new` | `newChan` | Constructor | `BaseIO (Chan a)` |
| `Chan.write` | `writeChan` | Function | `Chan a -> a -> BaseIO Unit` |
| `Chan.read` | `readChan` | Async op | `Chan a -> BaseIO (Task a)` |
| `Chan.dup` | `dupChan` | Function | `Chan a -> BaseIO (Chan a)` |
| `Chan.tryRead` | *(no direct equivalent)* | Non-blocking | `Chan a -> BaseIO (Option a)` |

## Constraint: `[Nonempty a]`

`Chan.read` requires `[Nonempty a]` for `IO.Promise` construction. `Chan.tryRead` and `Chan.write` do not require this constraint.

## Subscriber-Based Dup Design

Unlike Haskell's linked-list-of-MVars implementation, lean-std uses a **subscriber array**:

- Each `Chan` has a private `readState` (per-reader buffer + waiters) and a shared `writeState` (subscriber list).
- `write` delivers the value to **all** current subscribers.
- `dup` creates a new `readState` and registers it in the shared subscriber list. The new channel shares the write side but reads independently.
- Values written before `dup` that have not been read are **not** visible on the new channel (matching Haskell's `dupChan` semantics).

## Proofs & Guarantees

### Structural Invariant
Maintained by `write`/`read`:

```
buffer.isEmpty = false  =>  waiters.isEmpty = true
```

If there are buffered values, no reader should be waiting. Enforced by `read` consuming from the buffer first, and `write` resolving a waiter before buffering.

### FIFO Ordering
Values are read in the order they were written, guaranteed by `Std.Queue`.

### Write Fan-Out
A single `write` delivers to all current subscribers atomically (the subscriber list is read under the write-side mutex).

## Example
```lean
import LeanStd.Control.Concurrent.Chan

open LeanStd

-- Create a channel
let ch <- Chan.new Nat

-- Write values
ch.write 1
ch.write 2
ch.write 3

-- Read (async, returns Task)
let task <- ch.read
let val  <- IO.wait task  -- 1

-- Non-blocking read
let maybe <- ch.tryRead   -- some 2

-- Duplicate: new reader sees future writes only
let ch2 <- ch.dup
ch.write 10
let t1 <- ch.read
let t2 <- ch2.read
let v1 <- IO.wait t1  -- 3 (buffered before dup, still in ch's buffer)
                       -- actually 3 was already buffered, 10 goes after
let v2 <- IO.wait t2  -- 10 (ch2 only sees writes after dup)
```

## Performance Notes
- **Unbounded buffer:** There is no backpressure. A fast writer with a slow reader will accumulate values in the `Std.Queue` buffer without bound.
- **Write cost is O(subscribers):** Each `write` iterates over all subscribers. For a single-reader channel this is O(1); for many `dup`'d readers it scales linearly.
- **Reader contention:** Each reader has its own `Std.Mutex`-protected state, so multiple readers do not contend with each other. Writers contend briefly on the shared write-side mutex to read the subscriber list.
- **Promise-based blocking:** A `read` on an empty channel creates a dormant promise -- no OS thread is consumed while waiting.
