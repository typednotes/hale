/-
  Hale.Control.Concurrent — Thread management primitives

  Provides `ThreadId`, `forkIO`, `forkFinally`, `threadDelay`, `yield`, and
  `killThread`, modelled after Haskell's `Control.Concurrent`.

  ## Design — Green threads via M:N scheduling

  `forkIO` enqueues an action on a shared run queue (O(1), heap-only).
  A small fixed pool of OS worker threads dequeues and executes green threads,
  inspired by GHC's capability model.

  ## Differences from GHC

  * **Cancellation is cooperative.**  `killThread` sets a `CancellationToken`;
    a CPU-bound thread that never checks the token will not be interrupted.
    GHC uses asynchronous exceptions which can interrupt at (almost) any point.
  * **No preemption.**  Green threads run to completion or until they
    voluntarily yield/block.  GHC preempts via timer interrupts.
  * **No stack switching.**  A green thread that calls `IO.wait` blocks its
    worker OS thread (same as a GHC bound thread blocking a capability).

  ## Type-level guarantees

  * `ThreadId.id` is unique by construction (monotonic counter).
  * `forkFinally` guarantees the finaliser runs regardless of success/failure.
-/

import Hale.Base.Control.Concurrent.MVar
import Hale.Base.Control.Concurrent.Scheduler
import Hale.Base.Control.Concurrent.Green
import Std.Sync.CancellationToken

namespace Control.Concurrent

/-! ### ThreadId -/

/-- A positive natural number.  Used for `ThreadId.id` to encode at the type
level that thread IDs are always $\ge 1$.

$$\text{PosNat} := \{n : \mathbb{N} \mid n > 0\}$$ -/
def PosNat := { n : Nat // n > 0 }

instance : Nonempty PosNat := ⟨⟨1, by omega⟩⟩
instance : BEq PosNat where beq a b := a.val == b.val
instance : Hashable PosNat where hash p := hash p.val
instance : ToString PosNat where toString p := toString p.val
instance : Repr PosNat where reprPrec p n := reprPrec p.val n

/-- Global monotonic counter for unique thread IDs.  Starts at $1$. -/
private initialize nextThreadId : IO.Ref PosNat ← IO.mkRef ⟨1, by omega⟩

/-- A handle to a forked concurrent thread.

* `id : PosNat` — unique identifier, $\ge 1$ by construction (monotonic counter).
* `task` — the underlying `Task` so we can `IO.wait` on it.
* `cancelToken` — cooperative cancellation via `Std.CancellationToken`.

The `id` field is never reused within a process (monotonic counter). -/
structure ThreadId where
  private mk ::
  id : PosNat
  private task : Task (Except IO.Error Unit)
  private cancelToken : Std.CancellationToken

instance : BEq ThreadId where beq a b := a.id == b.id
instance : Hashable ThreadId where hash t := hash t.id
instance : ToString ThreadId where toString t := s!"ThreadId({t.id})"
instance : Repr ThreadId where reprPrec t _ := s!"ThreadId({t.id})"

/-- Allocate a fresh unique thread ID (internal).

Atomically increments the global counter and returns the previous value,
which is $\ge 1$ since the counter starts at $1$ and only increases.

$$\text{freshThreadId} : \text{BaseIO}\ \text{PosNat}$$ -/
private def freshThreadId : BaseIO PosNat :=
  nextThreadId.modifyGet fun ⟨n, h⟩ => (⟨n, h⟩, ⟨n + 1, by omega⟩)

/-! ### Forking -/

/-- Fork a new green thread.  The action is submitted to Lean's thread pool
via `IO.asTask` (default priority) — O(1), no dedicated OS thread spawned.
Millions of green threads can be active simultaneously.

$$\text{forkIO} : \text{IO}\ \text{Unit} \to \text{IO}\ \text{ThreadId}$$

```
let tid ← forkIO do
  IO.println "hello from green thread"
```

The returned `ThreadId` can be used with `killThread` for cooperative
cancellation, or with `waitThread` to join. -/
def forkIO (action : IO Unit) : IO ThreadId := do
  let tid ← freshThreadId
  let token ← Std.CancellationToken.new
  let schedTid : Scheduler.PosNat := ⟨tid.val, tid.property⟩
  let thread : Scheduler.GreenThread := {
    id := schedTid
    action := action
    token := token
  }
  let task ← Scheduler.schedule thread
  pure { id := tid, task := task, cancelToken := token }

/-- Fork a green thread that calls `finally` with the outcome, whether the
action succeeded or threw.

$$\text{forkFinally} : \text{IO}\ \alpha \to (\text{Except}\ \text{IO.Error}\ \alpha \to \text{IO}\ \text{Unit}) \to \text{IO}\ \text{ThreadId}$$

Modelled after Haskell's `forkFinally`. -/
def forkFinally {α : Type} (action : IO α) (finally_ : Except IO.Error α → IO Unit) : IO ThreadId := do
  forkIO do
    try
      let a ← action
      finally_ (.ok a)
    catch e =>
      finally_ (.error e)

/-! ### Thread control -/

/-- Cooperatively cancel a thread.  Sets the thread's `CancellationToken`.

$$\text{killThread} : \text{ThreadId} \to \text{BaseIO}\ \text{Unit}$$

**Note:** Unlike GHC's `killThread`, this is cooperative.  The target thread
must check `Std.CancellationToken.isCancelled` or use cancellation-aware
primitives to actually stop. -/
def killThread (tid : ThreadId) : BaseIO Unit :=
  tid.cancelToken.cancel .cancel

/-- Suspend the current thread for at least $\mu s$ microseconds.

$$\text{threadDelay} : \mathbb{N} \to \text{BaseIO}\ \text{Unit}$$

Maps to `IO.sleep` (millisecond granularity, so we round up:
$\text{ms} = \lceil \mu s / 1000 \rceil$). -/
def threadDelay (μs : Nat) : BaseIO Unit :=
  IO.sleep (((μs + 999) / 1000).toUInt32)

/-- Yield execution to other threads.  Equivalent to `IO.sleep 0`.

$$\text{yield} : \text{BaseIO}\ \text{Unit}$$ -/
def yield : BaseIO Unit := IO.sleep 0

/-! ### Fair green threads -/

/-- Fork a fair green thread.  The `Green` computation never blocks pool
threads when awaiting — suspensions use `BaseIO.bindTask` to register
continuations, freeing the pool thread for other work.

$$\text{forkGreen} : \text{Green}\ \text{Unit} \to \text{IO}\ \text{ThreadId}$$

Use `Green.await`, `Green.takeMVar`, etc. inside the action to suspend
without blocking.

See `Hale.Control.Concurrent.Green` for termination, liveness, and
fairness guarantees. -/
def forkGreen (action : Green.Green Unit) : IO ThreadId := do
  let tid ← freshThreadId
  let token ← Std.CancellationToken.new
  let task ← Green.Green.run action token
  pure { id := tid, task := task, cancelToken := token }

/-- Await a thread's completion inside a `Green` computation, without
blocking the pool thread.

$$\text{waitThreadGreen} : \text{ThreadId} \to \text{Green.Green}\ \text{Unit}$$ -/
def waitThreadGreen (tid : ThreadId) : Green.Green Unit :=
  Green.Green.await tid.task >>= fun
    | .ok ()   => pure ()
    | .error e => throw e

/-! ### Waiting -/

/-- Wait for a thread to finish and return its result.  Re-throws if the
thread threw an exception.

$$\text{waitThread} : \text{ThreadId} \to \text{IO}\ \text{Unit}$$ -/
def waitThread (tid : ThreadId) : IO Unit := do
  match ← IO.wait tid.task with
  | .ok () => pure ()
  | .error e => throw e

end Control.Concurrent
