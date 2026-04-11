# AutoUpdate -- Periodic Cached Values

**Lean:** `Hale.AutoUpdate` | **Haskell:** `auto-update`

Periodically updated cached values. Runs an IO action in a background task and caches the result for consumers. Uses `IO.asTask` with `.dedicated` priority and `Std.CancellationToken` for lifecycle management.

## Key Types

```lean
structure UpdateSettings (α : Type) where
  interval : Nat      -- update interval in microseconds
  action   : IO α     -- action to run periodically
```

## Files
- `Hale/AutoUpdate/Control/AutoUpdate.lean` -- UpdateSettings, mkAutoUpdate
