# TimeManager -- Connection Timeout Management

**Lean:** `Hale.TimeManager` | **Haskell:** `time-manager`

Periodically sweeps registered handles and fires timeout callbacks for expired connections. Uses `IO.asTask` with `.dedicated` priority.

## Guarantees
- `tickle` resets timeout -- O(1)
- `cancel` prevents future firing
- Thread-safe via `IO.Ref` atomicity

## Files
- `Hale/TimeManager/System/TimeManager.lean` -- TimeManager, Handle, tickle, cancel
