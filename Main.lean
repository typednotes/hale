import LeanStd

open Data Data.Function Data.Functor Data.List Data.Tuple Control Control.Concurrent

def main : IO Unit := do
  -- ── Phase 0: Foundational ────────────────────
  IO.println "=== Newtype wrappers ==="
  let s1 : Sum Nat := ⟨3⟩
  let s2 : Sum Nat := ⟨4⟩
  IO.println s!"Sum: {s1} ++ {s2} = {s1 ++ s2}"

  let p1 : Product Nat := ⟨3⟩
  let p2 : Product Nat := ⟨4⟩
  IO.println s!"Product: {p1} ++ {p2} = {p1 ++ p2}"

  let a1 : All := ⟨true⟩
  let a2 : All := ⟨false⟩
  IO.println s!"All: {a1} ++ {a2} = {a1 ++ a2}"

  let o1 : Any := ⟨false⟩
  let o2 : Any := ⟨true⟩
  IO.println s!"Any: {o1} ++ {o2} = {o1 ++ o2}"

  let f1 : First Nat := ⟨none⟩
  let f2 : First Nat := ⟨some 42⟩
  IO.println s!"First: {f1} ++ {f2} = {f1 ++ f2}"

  -- ── Phase 1: Core Abstractions ───────────────
  IO.println "\n=== Identity monad ==="
  let id1 := Identity.mk 42
  let id2 := (· + 1) <$> id1
  IO.println s!"Identity map (+1) on {id1} = {id2}"

  IO.println "\n=== Bifunctor ==="
  let pair := (1, "hello")
  let mapped := Bifunctor.bimap (· * 10) (· ++ "!") pair
  IO.println s!"bimap (*10, ++\"!\") ({pair.1}, \"{pair.2}\") = ({mapped.1}, \"{mapped.2}\")"

  -- ── Phase 2: Data Structures ─────────────────
  IO.println "\n=== NonEmpty ==="
  let ne := NonEmpty.mk 1 [2, 3, 4, 5]
  IO.println s!"NonEmpty: {ne}"
  IO.println s!"  head: {ne.head}"
  IO.println s!"  last: {ne.last}"
  IO.println s!"  length: {ne.length.val}"

  let ne2 := (· * 10) <$> ne
  IO.println s!"  map (*10): {ne2}"

  IO.println "\n=== Either ==="
  let e1 : Either String Nat := .right 42
  let e2 : Either String Nat := .left "error"
  IO.println s!"Right 42: {e1}"
  IO.println s!"Left \"error\": {e2}"
  let e3 := (· + 1) <$> e1
  IO.println s!"map (+1) on Right 42: {e3}"

  let mixed : List (Either String Nat) := [.left "a", .right 1, .right 2, .left "b", .right 3]
  let (ls, rs) := Either.partitionEithers mixed
  IO.println s!"partitionEithers: lefts={ls}, rights={rs}"

  IO.println "\n=== Down (reversed ordering) ==="
  let d1 := Down.mk 3
  let d2 := Down.mk 7
  IO.println s!"compare Down(3) Down(7) = {repr (compare d1 d2)}"
  IO.println s!"compare 3 7 = {repr (compare (3 : Nat) (7 : Nat))}"

  -- ── Phase 4: Numeric Types ───────────────────
  IO.println "\n=== Ratio ==="
  let r1 := Ratio.mk' 1 2 (by omega)
  let r2 := Ratio.mk' 1 3 (by omega)
  let rsum := r1 + r2
  IO.println s!"1/2 + 1/3 = {rsum}"
  let rprod := r1 * r2
  IO.println s!"1/2 * 1/3 = {rprod}"
  IO.println s!"floor(5/3) = {(Ratio.mk' 5 3 (by omega)).floor}"
  IO.println s!"ceil(5/3) = {(Ratio.mk' 5 3 (by omega)).ceil}"

  IO.println "\n=== Complex ==="
  let z1 : Complex Int := ⟨3, 4⟩
  let z2 : Complex Int := ⟨1, -2⟩
  IO.println s!"z1 = {z1}"
  IO.println s!"z2 = {z2}"
  IO.println s!"|z1|² = {z1.magnitudeSquared}"

  IO.println "\n=== Fixed ==="
  let f1 : Fixed 2 := Fixed.fromInt 3
  let f2 : Fixed 2 := ⟨157⟩  -- 1.57
  IO.println s!"Fixed 2: {f1} + {f2} = {f1 + f2}"

  -- ── Phase 6: Concurrency ─────────────────────
  IO.println "\n=== MVar ==="
  let mv ← MVar.new 42
  let v ← mv.takeSync
  IO.println s!"MVar: took {v}"
  mv.putSync 99
  let v2 ← mv.readSync
  IO.println s!"MVar: read {v2} (still full)"

  IO.println "\n=== Chan ==="
  let ch ← Chan.new Nat
  ch.write 1
  ch.write 2
  ch.write 3
  let a ← IO.wait (← ch.read)
  let b ← IO.wait (← ch.read)
  let c ← IO.wait (← ch.read)
  IO.println s!"Chan: read {a}, {b}, {c} (FIFO)"

  IO.println "\n=== QSem ==="
  let sem ← QSem.new 2
  IO.wait (← sem.wait)
  IO.wait (← sem.wait)
  sem.signal
  IO.wait (← sem.wait)
  sem.signal
  sem.signal
  IO.println "QSem: acquire/release cycle OK"

  IO.println "\n=== forkIO ==="
  let flag ← IO.mkRef false
  let tid ← forkIO do flag.set true
  waitThread tid
  let done ← flag.get
  IO.println s!"forkIO: thread completed = {done}"

  IO.println "\nAll smoke tests passed!"
