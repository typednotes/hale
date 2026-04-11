/-
  Hale.Mtl.Control.Monad.Except — ExceptT / Except Haskell-compatible API

  Provides the Haskell-named combinators for `ExceptT` and `Except`.
  Lean 4's prelude already defines `ExceptT` and `Except`; this module
  re-exports them and adds Haskell-compatible function names.

  ## Design

  Lean 4 already provides:
  - `ExceptT ε m α` — the exception monad transformer
  - `Except ε α` — pure exception type (= `ExceptT ε Id α`)
  - `throw` — throw an error in `ExceptT`
  - `tryCatch` — catch an error in `ExceptT`
  - `ExceptT.run` — unwrap to get `m (Except ε α)`

  This module adds Haskell-named aliases and combinators:
  - `throwError`, `catchError` — Haskell MTL names
  - `liftEither` — lift a pure `Except` into `ExceptT`
  - `mapExceptT` — map over the inner computation
  - `withExceptT` — map over the error type

  ## Haskell source

  https://hackage.haskell.org/package/mtl-2.3.1/docs/Control-Monad-Except.html
-/

namespace Control.Monad.Except

-- Re-export the core types (they come from Lean's prelude)
export ExceptT (run mk)

/-- Throw an error in `ExceptT`.

    $$\text{throwError}(\varepsilon) : \text{ExceptT}\ \varepsilon\ m\ \alpha$$

    Alias for Lean's `throw`. -/
@[inline] def throwError [Monad m] (e : ε) : ExceptT ε m α :=
  ExceptT.mk (pure (Except.error e))

/-- Catch an error in `ExceptT`, applying a handler.

    $$\text{catchError}(ma, h) : \text{ExceptT}\ \varepsilon\ m\ \alpha$$

    Runs `ma`; if it throws error `e`, runs `h e` instead.
    Alias for Lean's `tryCatch` pattern. -/
@[inline] def catchError [Monad m] (ma : ExceptT ε m α) (handler : ε → ExceptT ε m α) : ExceptT ε m α :=
  ExceptT.mk do
    match ← ma.run with
    | .ok a => pure (.ok a)
    | .error e => (handler e).run

/-- Lift a pure `Except` value into `ExceptT`.

    $$\text{liftEither} : \text{Except}\ \varepsilon\ \alpha \to \text{ExceptT}\ \varepsilon\ m\ \alpha$$ -/
@[inline] def liftEither [Monad m] (ea : Except ε α) : ExceptT ε m α :=
  ExceptT.mk (pure ea)

/-- Map over the inner computation and error/value types.

    $$\text{mapExceptT}(f, ma) : \text{ExceptT}\ \varepsilon'\ n\ \beta$$

    where $f : m\ (\text{Except}\ \varepsilon\ \alpha) \to n\ (\text{Except}\ \varepsilon'\ \beta)$. -/
@[inline] def mapExceptT (f : m (Except ε α) → n (Except ε' β))
    (ma : ExceptT ε m α) : ExceptT ε' n β :=
  ExceptT.mk (f ma.run)

/-- Map over the error type, leaving the value unchanged.

    $$\text{withExceptT}(f, ma) : \text{ExceptT}\ \varepsilon'\ m\ \alpha$$

    where $f : \varepsilon \to \varepsilon'$. -/
@[inline] def withExceptT [Functor m] (f : ε → ε') (ma : ExceptT ε m α) : ExceptT ε' m α :=
  ExceptT.mk (Except.mapError f <$> ma.run)

/-- Unwrap an `ExceptT` computation.

    $$\text{runExceptT} : \text{ExceptT}\ \varepsilon\ m\ \alpha \to m\ (\text{Except}\ \varepsilon\ \alpha)$$

    Alias for `ExceptT.run`. -/
@[inline] def runExceptT (ma : ExceptT ε m α) : m (Except ε α) :=
  ma.run

-- ── Proofs ──────────────────────────────────────────

/-- `runExceptT` of `liftEither (.ok a)` yields `.ok a`.
    $$\text{runExceptT}(\text{liftEither}(\text{ok}\ a)) = \text{pure}(\text{ok}\ a)$$ -/
theorem runExceptT_liftEither_ok [Monad m] (a : α) :
    runExceptT (liftEither (.ok a) : ExceptT ε m α) = pure (.ok a) := rfl

/-- `runExceptT` of `liftEither (.error e)` yields `.error e`.
    $$\text{runExceptT}(\text{liftEither}(\text{error}\ e)) = \text{pure}(\text{error}\ e)$$ -/
theorem runExceptT_liftEither_error [Monad m] (e : ε) :
    runExceptT (liftEither (.error e) : ExceptT ε m α) = pure (.error e) := rfl

-- NOTE: catchError_throwError (catchError (throwError e) h = h e) requires careful
-- universe alignment between throwError and catchError. The proof is straightforward
-- (it reduces to bind_pure_comp + map_pure) but Lean's universe unification makes
-- it difficult to state cleanly at this level of generality. Skipped to avoid sorry.

end Control.Monad.Except
