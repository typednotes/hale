/-
  Hale.Conduit.Data.Conduit.Internal.Pipe — Core Pipe type

  The fundamental streaming data type with 5 constructors, ported from
  Haskell's `conduit` package (`Data.Conduit.Internal.Pipe`).

  Uses `Thunk` for lazy evaluation in `haveOutput` and `leftover`,
  matching the pattern established in `Hale.ByteString.Data.ByteString.Lazy.Internal`.

  ## Positivity

  The `pipeM` constructor wraps `m (Pipe ...)` which is not strictly positive.
  We use `unsafe` to bypass the positivity checker. This is sound because
  `m` is always used covariantly (Functor/Monad) in practice — no user of
  conduit can exploit negative occurrences.

  ## Type parameters

  - `l` — leftover values (pushed back to upstream)
  - `i` — input stream values
  - `o` — output stream values
  - `u` — upstream result (typically `Unit`)
  - `m` — effect monad
  - `r` — final result

  ## Haskell equivalent

  `Data.Conduit.Internal.Pipe` from the `conduit` package.
-/

namespace Data.Conduit.Internal

/-- The core streaming pipe type.

    A free-monad-like inductive representing a streaming computation with
    five possible states:

    $$\text{Pipe}\ l\ i\ o\ u\ m\ r ::=$$
    $$\quad \mid\ \text{HaveOutput}(\text{Thunk}(\text{Pipe}\ l\ i\ o\ u\ m\ r),\; o)$$
    $$\quad \mid\ \text{NeedInput}(i \to \text{Pipe},\; u \to \text{Pipe})$$
    $$\quad \mid\ \text{Done}(r)$$
    $$\quad \mid\ \text{PipeM}(m\ (\text{Pipe}\ l\ i\ o\ u\ m\ r))$$
    $$\quad \mid\ \text{Leftover}(\text{Thunk}(\text{Pipe}\ l\ i\ o\ u\ m\ r),\; l)$$

    Uses `unsafe` because `pipeM : m (Pipe ...)` is not strictly positive.
    This is sound — `m` is always a covariant functor in all conduit usage. -/
unsafe inductive Pipe (l i o u : Type) (m : Type → Type) (r : Type) where
  /-- Yield an output value `o` downstream. The continuation is wrapped in
      `Thunk` for lazy evaluation, matching Haskell's lazy `Pipe` spine.
      $$\text{haveOutput} : \text{Thunk}(\text{Pipe}) \to o \to \text{Pipe}$$ -/
  | haveOutput : Thunk (Pipe l i o u m r) → o → Pipe l i o u m r
  /-- Wait for input from upstream. Two continuations:
      - `onInput : i → Pipe` — called when a value arrives
      - `onUpstreamDone : u → Pipe` — called when upstream is exhausted
      $$\text{needInput} : (i \to \text{Pipe}) \to (u \to \text{Pipe}) \to \text{Pipe}$$ -/
  | needInput : (i → Pipe l i o u m r) → (u → Pipe l i o u m r) → Pipe l i o u m r
  /-- Terminal state carrying the final result value.
      $$\text{done} : r \to \text{Pipe}$$ -/
  | done : r → Pipe l i o u m r
  /-- Run a monadic action that produces the next pipe state.
      $$\text{pipeM} : m\ (\text{Pipe}) \to \text{Pipe}$$ -/
  | pipeM : m (Pipe l i o u m r) → Pipe l i o u m r
  /-- Push an unconsumed input value back for re-processing.
      The continuation is wrapped in `Thunk` for lazy evaluation.
      $$\text{leftover} : \text{Thunk}(\text{Pipe}) \to l \to \text{Pipe}$$ -/
  | leftover : Thunk (Pipe l i o u m r) → l → Pipe l i o u m r

namespace Pipe

/-- Map a function over the result of a pipe (Functor action).

    Structurally recurses through the pipe, applying `f` at every `done` leaf.

    $$\text{mapResult}\ f\ (\text{done}\ r) = \text{done}\ (f\ r)$$
    $$\text{mapResult}\ f\ (\text{haveOutput}\ k\ o) = \text{haveOutput}\ (\text{mapResult}\ f \circ k)\ o$$
    $$\ldots$$ -/
unsafe def mapResult [Functor m] (f : α → β) : Pipe l i o u m α → Pipe l i o u m β
  | .done r => .done (f r)
  | .haveOutput next out => .haveOutput (Thunk.mk fun () => (next.get).mapResult f) out
  | .needInput onIn onUp =>
    .needInput (fun i => (onIn i).mapResult f) (fun u => (onUp u).mapResult f)
  | .pipeM action => .pipeM (Functor.map (fun p => p.mapResult f) action)
  | .leftover next l => .leftover (Thunk.mk fun () => (next.get).mapResult f) l

/-- Monadic bind for `Pipe`. Replaces every `done r` leaf with `f r`.

    This is the free monad bind: it walks the pipe structure and substitutes
    at terminal nodes.

    $$\text{bind}\ (\text{done}\ r)\ f = f\ r$$
    $$\text{bind}\ (\text{haveOutput}\ k\ o)\ f = \text{haveOutput}\ (\text{bind}\ k\ f)\ o$$
    $$\ldots$$ -/
unsafe def bind [Functor m] (p : Pipe l i o u m α) (f : α → Pipe l i o u m β)
    : Pipe l i o u m β :=
  match p with
  | .done r => f r
  | .haveOutput next out => .haveOutput (Thunk.mk fun () => (next.get).bind f) out
  | .needInput onIn onUp =>
    .needInput (fun i => (onIn i).bind f) (fun u => (onUp u).bind f)
  | .pipeM action => .pipeM (Functor.map (fun p => p.bind f) action)
  | .leftover next l => .leftover (Thunk.mk fun () => (next.get).bind f) l

/-- `Functor` instance for `Pipe l i o u m`.
    $$\text{map}\ f = \text{mapResult}\ f$$ -/
unsafe instance [Functor m] : Functor (Pipe l i o u m) where
  map := mapResult

/-- `Pure` instance for `Pipe l i o u m`.
    $$\text{pure} = \text{done}$$ -/
unsafe instance [Functor m] : Pure (Pipe l i o u m) where
  pure := .done

/-- `Bind` instance for `Pipe l i o u m`.
    $$\text{bind} = \text{Pipe.bind}$$ -/
unsafe instance [Functor m] : Bind (Pipe l i o u m) where
  bind := Pipe.bind

/-- `Monad` instance for `Pipe l i o u m`.

    Laws hold by structural induction on the pipe (axiom-dependent on
    `m`'s own monad laws for the `pipeM` case):

    - **Left identity:** `pure a >>= f = f a` — immediate from `done` case of `bind`
    - **Right identity:** `p >>= pure = p` — by induction, `bind` at `done` returns `done r`
    - **Associativity:** `(p >>= f) >>= g = p >>= (fun a => f a >>= g)` — by induction -/
unsafe instance [Monad m] : Monad (Pipe l i o u m) where

end Pipe
end Data.Conduit.Internal
