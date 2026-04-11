# STM -- Software Transactional Memory

**Lean:** `Hale.STM` | **Haskell:** `stm`

Pessimistic STM with global mutex serialization. Provides `TVar`, `TMVar`, and `TQueue` for concurrent programming.

## Key Types

| Type | Description |
|------|-------------|
| `STM α` | Transactional computation |
| `TVar α` | Mutable variable (`IO.Ref α`) |
| `TMVar α` | Synchronization variable (empty or full) |
| `TQueue α` | Unbounded FIFO queue (two-list amortized) |

## API

| Function | Description |
|----------|-------------|
| `atomically` | Execute STM transaction |
| `retry` | Block and retry transaction |
| `orElse` | Alternative transaction |
| `newTVarIO` / `readTVar` / `writeTVar` | TVar operations |
| `newTMVar` / `takeTMVar` / `putTMVar` | TMVar operations |
| `newTQueue` / `readTQueue` / `writeTQueue` | TQueue operations |

## Files
- `Hale/STM/Control/Monad/STM.lean` -- STM monad, atomically, retry, orElse
- `Hale/STM/Control/Concurrent/STM/TVar.lean` -- Transactional variables
- `Hale/STM/Control/Concurrent/STM/TMVar.lean` -- Transactional MVars
- `Hale/STM/Control/Concurrent/STM/TQueue.lean` -- Transactional queues
