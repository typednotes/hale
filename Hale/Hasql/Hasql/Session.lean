/-
  Hale.Hasql.Hasql.Session — Database session monad

  A `Session` is a computation that runs against a PostgreSQL connection,
  producing either a result or a `SessionError`.  Sessions compose via
  standard monadic operations and can execute `Statement` values.

  ## Haskell source
  - `Hasql.Session` (hasql package)

  ## Design
  `Session α := ReaderT Connection (ExceptT SessionError IO) α`

  This gives us:
  - Access to the connection via `ReaderT`
  - Typed error handling via `ExceptT`
  - IO for actual database calls
-/

import Hale.Hasql.Hasql.Connection
import Hale.Hasql.Database.PostgreSQL.LibPQ

namespace Hasql.Session

open Database.PostgreSQL.LibPQ
open Hasql.Connection

-- ────────────────────────────────────────────────────────────────────
-- Session errors
-- ────────────────────────────────────────────────────────────────────

/-- Errors that can occur during a database session. -/
inductive SessionError where
  /-- Query returned an error from PostgreSQL. -/
  | queryError (status : ExecStatus) (message : String)
  /-- A result decoding error (wrong type, unexpected null, etc.). -/
  | resultError (message : String)
  /-- The connection was lost. -/
  | connectionError (message : String)
  /-- A client-side error (e.g. bad parameters). -/
  | clientError (message : String)
  deriving BEq, Repr

instance : ToString SessionError where
  toString
    | .queryError st msg => s!"QueryError({repr st}): {msg}"
    | .resultError msg => s!"ResultError: {msg}"
    | .connectionError msg => s!"ConnectionError: {msg}"
    | .clientError msg => s!"ClientError: {msg}"

-- ────────────────────────────────────────────────────────────────────
-- Session monad
-- ────────────────────────────────────────────────────────────────────

/-- A database session: a computation with access to a `Connection`
    that may fail with `SessionError`.
    $$\text{Session}\ \alpha := \text{ReaderT Connection}\ (\text{ExceptT SessionError IO})\ \alpha$$ -/
def Session (α : Type) := Connection → IO (Except SessionError α)

namespace Session

/-- Lift a pure value into a session. -/
def pure (a : α) : Session α := fun _ => .ok a |> Pure.pure

/-- Sequence two sessions. -/
def bind (ma : Session α) (f : α → Session β) : Session β := fun conn => do
  match ← ma conn with
  | .error e => return .error e
  | .ok a => f a conn

instance : Monad Session where
  pure := Session.pure
  bind := Session.bind

instance : MonadLift IO Session where
  monadLift action := fun _ => do
    let a ← action
    return .ok a

/-- Throw a session error. -/
def throw (e : SessionError) : Session α := fun _ => return .error e

/-- Catch a session error. -/
def tryCatch (ma : Session α) (handler : SessionError → Session α) : Session α :=
  fun conn => do
    match ← ma conn with
    | .ok a => return .ok a
    | .error e => handler e conn

/-- Get the raw libpq connection from the session. -/
def getConnection : Session Connection := fun conn => return .ok conn

/-- Get the raw PgConn from the session. -/
def getRawConnection : Session PgConn := fun conn => return .ok conn.raw

-- ────────────────────────────────────────────────────────────────────
-- SQL execution within a session
-- ────────────────────────────────────────────────────────────────────

/-- Execute a simple SQL statement (no parameters, no result decoding). -/
def sql (query : String) : Session Unit := fun conn => do
  let result ← exec conn.raw query
  let st ← resultStatus result
  if st.isOk then
    return .ok ()
  else
    let msg ← resultErrorMessage result
    return .error (.queryError st msg)

/-- Execute a parameterized SQL query, returning the raw `PgResult`.
    This is the low-level escape hatch; prefer `Statement.run` for
    type-safe parameter encoding and result decoding. -/
def query (queryStr : String) (params : Array (Option String)) : Session PgResult :=
  fun conn => do
    let result ← execParams conn.raw queryStr params
    let st ← resultStatus result
    if st.isOk then
      return .ok result
    else
      let msg ← resultErrorMessage result
      return .error (.queryError st msg)

-- ────────────────────────────────────────────────────────────────────
-- Transaction helpers
-- ────────────────────────────────────────────────────────────────────

/-- Run a session inside a transaction.  Rolls back on error. -/
def transaction (action : Session α) : Session α := fun conn => do
  let _ ← exec conn.raw "BEGIN"
  match ← action conn with
  | .ok a =>
    let _ ← exec conn.raw "COMMIT"
    return .ok a
  | .error e =>
    let _ ← exec conn.raw "ROLLBACK"
    return .error e

-- ────────────────────────────────────────────────────────────────────
-- Running a session
-- ────────────────────────────────────────────────────────────────────

/-- Run a session against a connection.
    $$\text{run} : \text{Session}\ \alpha \to \text{Connection}
      \to \text{IO}\ (\text{Except SessionError}\ \alpha)$$ -/
def run (session : Session α) (conn : Connection) : IO (Except SessionError α) :=
  session conn

-- ────────────────────────────────────────────────────────────────────
-- Session monad laws
-- ────────────────────────────────────────────────────────────────────

-- The Session monad is defined as `Connection → IO (Except SessionError α)`.
-- Since IO is opaque, we cannot prove extensional equality of IO actions.
-- However, we can state the monad laws as comments documenting the intended
-- algebraic identities:
--
-- **Left identity**: `bind (pure a) f = f a`
--   Holds because `pure a` returns `.ok a`, so `bind` feeds `a` to `f`.
--
-- **Right identity**: `bind m pure = m`
--   Holds because for any result `.ok a`, `pure a` returns `.ok a`,
--   and for `.error e`, bind short-circuits.
--
-- **Associativity**: `bind (bind m f) g = bind m (fun a => bind (f a) g)`
--   Holds because both sides propagate errors identically and
--   compose the success paths.
--
-- These cannot be proven as Lean theorems due to IO opacity, but the
-- definitions are structurally correct (standard ExceptT over ReaderT over IO).

end Session
end Hasql.Session
