# Time -- Clock and Time Types

**Lean:** `Hale.Time` | **Haskell:** `time`

UTC time and durations. Wraps Lean's `IO.monoNanosNow` for high-resolution monotonic timing.

## Key Types

```lean
structure NominalDiffTime where
  nanoseconds : Int
```

## Files
- `Hale/Time/Data/Time/Clock.lean` -- NominalDiffTime, UTCTime
