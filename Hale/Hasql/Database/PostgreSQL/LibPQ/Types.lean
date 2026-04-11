/-
  Hale.Hasql.Database.PostgreSQL.LibPQ.Types — Low-level libpq opaque handles

  Opaque types wrapping libpq's `PGconn*` and `PGresult*` via Lean's external
  object mechanism.  GC finalizers call `PQfinish` and `PQclear` respectively,
  preventing connection/result leaks even when exceptions are thrown.

  ## Design
  Each handle is an opaque external object registered with
  `lean_register_external_class`.  The Lean runtime owns the pointer; C
  finalizers release it.  This mirrors the pattern established in
  `Hale.Network.Network.Socket.FFI` and `Hale.TLS.Network.TLS.Types`.

  ## Haskell source
  - `Database.PostgreSQL.LibPQ` (postgresql-libpq package)

  ## Guarantees
  - Resources are released exactly once (via GC finalizer)
  - All FFI entry points return `IO`, never crash
-/

namespace Database.PostgreSQL.LibPQ

-- ────────────────────────────────────────────────────────────────────
-- Opaque connection handle (wraps PGconn*)
-- ────────────────────────────────────────────────────────────────────

/-- Opaque PostgreSQL connection handle.
    $$\text{PgConn} : \text{NonemptyType}$$
    Wraps libpq's `PGconn*`.  The GC finalizer calls `PQfinish`. -/
opaque PgConnHandle : NonemptyType

/-- A live (or formerly-live) PostgreSQL connection. -/
def PgConn : Type := PgConnHandle.type

instance : Nonempty PgConn := PgConnHandle.property

-- ────────────────────────────────────────────────────────────────────
-- Opaque result handle (wraps PGresult*)
-- ────────────────────────────────────────────────────────────────────

/-- Opaque PostgreSQL result handle.
    $$\text{PgResult} : \text{NonemptyType}$$
    Wraps libpq's `PGresult*`.  The GC finalizer calls `PQclear`. -/
opaque PgResultHandle : NonemptyType

/-- A query result set. -/
def PgResult : Type := PgResultHandle.type

instance : Nonempty PgResult := PgResultHandle.property

-- ────────────────────────────────────────────────────────────────────
-- Connection status (mirrors PQstatus / ConnStatusType)
-- ────────────────────────────────────────────────────────────────────

/-- Connection status returned by `PQstatus`.
    $$\text{ConnStatus} \in \{\text{ok}, \text{bad}, \text{other}\}$$ -/
inductive ConnStatus where
  | ok
  | bad
  | other (code : UInt8)
  deriving BEq, Repr, Inhabited

/-- Decode a raw `PQstatus` integer into `ConnStatus`. -/
def ConnStatus.ofUInt8 : UInt8 → ConnStatus
  | 0 => .ok
  | 1 => .bad
  | n => .other n

-- ────────────────────────────────────────────────────────────────────
-- Exec status (mirrors PQresultStatus / ExecStatusType)
-- ────────────────────────────────────────────────────────────────────

/-- Result status returned by `PQresultStatus`.
    $$\text{ExecStatus} \in \{\text{emptyQuery}, \text{commandOk}, \ldots\}$$ -/
inductive ExecStatus where
  | emptyQuery
  | commandOk
  | tuplesOk
  | copyOut
  | copyIn
  | badResponse
  | nonfatalError
  | fatalError
  | copyBoth
  | singleTuple
  | pipelineSync
  | pipelineAbort
  | other (code : UInt8)
  deriving BEq, Repr, Inhabited

/-- Decode a raw `PQresultStatus` integer. -/
def ExecStatus.ofUInt8 : UInt8 → ExecStatus
  | 0 => .emptyQuery
  | 1 => .commandOk
  | 2 => .tuplesOk
  | 3 => .copyOut
  | 4 => .copyIn
  | 5 => .badResponse
  | 6 => .nonfatalError
  | 7 => .fatalError
  | 8 => .copyBoth
  | 9 => .singleTuple
  | 10 => .pipelineSync
  | 11 => .pipelineAbort
  | n  => .other n

/-- Is this a successful exec status? -/
def ExecStatus.isOk : ExecStatus → Bool
  | .commandOk | .tuplesOk | .singleTuple | .emptyQuery => true
  | _ => false

-- Theorems: the "ok" statuses are exactly {commandOk, tuplesOk, singleTuple, emptyQuery}
theorem ExecStatus.commandOk_isOk : ExecStatus.commandOk.isOk = true := rfl
theorem ExecStatus.tuplesOk_isOk : ExecStatus.tuplesOk.isOk = true := rfl
theorem ExecStatus.singleTuple_isOk : ExecStatus.singleTuple.isOk = true := rfl
theorem ExecStatus.emptyQuery_isOk : ExecStatus.emptyQuery.isOk = true := rfl
theorem ExecStatus.badResponse_not_isOk : ExecStatus.badResponse.isOk = false := rfl
theorem ExecStatus.fatalError_not_isOk : ExecStatus.fatalError.isOk = false := rfl
theorem ExecStatus.nonfatalError_not_isOk : ExecStatus.nonfatalError.isOk = false := rfl

-- ────────────────────────────────────────────────────────────────────
-- Transaction status
-- ────────────────────────────────────────────────────────────────────

/-- Transaction status returned by `PQtransactionStatus`. -/
inductive TransactionStatus where
  | idle
  | active
  | inTrans
  | inError
  | unknown
  deriving BEq, Repr, Inhabited

/-- Decode raw transaction status. -/
def TransactionStatus.ofUInt8 : UInt8 → TransactionStatus
  | 0 => .idle
  | 1 => .active
  | 2 => .inTrans
  | 3 => .inError
  | _ => .unknown

-- ────────────────────────────────────────────────────────────────────
-- PostgreSQL error
-- ────────────────────────────────────────────────────────────────────

/-- A PostgreSQL error returned from libpq. -/
structure PgError where
  message : String
  status : ExecStatus
  deriving BEq, Repr

instance : ToString PgError where
  toString e := s!"PgError({e.status |> repr}): {e.message}"

/-- A LISTEN/NOTIFY notification from PostgreSQL. -/
structure PgNotification where
  channel : String
  payload : String
  pid : UInt32
  deriving BEq, Repr

end Database.PostgreSQL.LibPQ
