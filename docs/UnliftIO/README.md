# UnliftIO -- MonadUnliftIO

**Lean:** `Hale.UnliftIO` | **Haskell:** `unliftio-core`

Allows running monadic actions in `IO` by "unlifting" them. CPS form avoids universe issues.

## Key Types

```lean
class MonadUnliftIO (m : Type → Type) where
  withRunInIO : ((∀ α, m α → IO α) → IO β) → m β
```

## Laws
- `withRunInIO (fun run => run m) = m` (identity)
- `withRunInIO (fun run => run (liftIO io)) = liftIO io` (lift-run roundtrip)

## Files
- `Hale/UnliftIO/Control/Monad/IO/Unlift.lean` -- MonadUnliftIO class
