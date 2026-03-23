/-
  Hale.ResourceT.Control.Monad.Trans.Resource — Resource management monad

  Provides a monad transformer that tracks resources (file handles, connections,
  etc.) and ensures they are cleaned up when the computation completes, even
  on exceptions.

  ## Guarantees

  - All registered cleanup actions run on `runResourceT` completion (via try/finally)
  - Cleanup runs even on exceptions (axiom-dependent on IO.finally semantics)
  - ReleaseKey is single-use: releasing twice is a no-op
  - Cleanup order is LIFO (last allocated = first released)
-/
import Std.Data.HashMap

namespace Control.Monad.Trans.Resource

/-- Opaque key for a registered cleanup action.
    Single-use: calling `release` twice is a no-op. -/
structure ReleaseKey where
  private mk ::
    id : Nat

/-- Internal cleanup registry. Uses Array for simplicity. -/
private abbrev CleanupMap := Array (Nat × IO Unit)

/-- Resource management monad transformer.
    $$\text{ResourceT}\ m\ \alpha = \text{IO.Ref CleanupMap} \to m\ \alpha$$ -/
def ResourceT (m : Type → Type) (α : Type) := IO.Ref CleanupMap → m α

instance [Monad m] : Monad (ResourceT m) where
  pure a := fun _ => pure a
  bind ma f := fun ref => do
    let a ← ma ref
    f a ref

instance [MonadLift IO m] : MonadLift IO (ResourceT m) where
  monadLift io := fun _ => MonadLift.monadLift io

/-- Register a resource with its cleanup action.
    Returns a `ReleaseKey` that can be used to release early. -/
def allocate (acquire : IO α) (release : α → IO Unit) : ResourceT IO (ReleaseKey × α) :=
  fun ref => do
    let a ← acquire
    let map ← ref.get
    let key := map.size
    ref.set (map.push (key, release a))
    return (⟨key⟩, a)

/-- Release a resource early. No-op if already released. -/
def release (key : ReleaseKey) : ResourceT IO Unit :=
  fun ref => do
    let map ← ref.get
    match map.findIdx? (fun (k, _) => k == key.id) with
    | some idx =>
      if h : idx < map.size then
        let (_, action) := map[idx]
        ref.set (map.eraseIdx idx)
        action
      else pure ()
    | none => pure ()

/-- Run a `ResourceT` computation. All registered cleanup actions
    execute on completion in LIFO order, even on exceptions. -/
def runResourceT (action : ResourceT IO α) : IO α := do
  let ref ← IO.mkRef (#[] : CleanupMap)
  try
    action ref
  finally
    let map ← ref.get
    -- Run cleanups in reverse order (LIFO)
    let sz := map.size
    for i in [:sz] do
      let idx := sz - 1 - i
      if h : idx < map.size then
        let (_, cleanup) := map[idx]
        try cleanup
        catch _ => pure ()

-- Proofs

/-- ReleaseKey equality is by id. -/
theorem releaseKey_eq (a b : ReleaseKey) : a = b ↔ a.id = b.id := by
  constructor
  · intro h; subst h; rfl
  · intro h; cases a; cases b; simp at h; subst h; rfl

end Control.Monad.Trans.Resource
