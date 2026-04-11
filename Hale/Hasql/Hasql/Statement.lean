/-
  Hale.Hasql.Hasql.Statement — Type-safe parameterized SQL statements

  A `Statement params result` pairs a SQL query with a parameter encoder
  and a result decoder, ensuring at the type level that the encoder and
  decoder match the expected types.

  ## Haskell source
  - `Hasql.Statement` (hasql package)

  ## Design
  The phantom type parameters `params` and `result` ensure that:
  - The encoder converts `params` to SQL parameter arrays
  - The decoder converts raw `PgResult` rows into `result`
  - Mismatches are caught at compile time
-/

import Hale.Hasql.Hasql.Session
import Hale.Hasql.Database.PostgreSQL.LibPQ

namespace Hasql.Statement

open Database.PostgreSQL.LibPQ
open Hasql.Session
open Hasql.Connection

-- ────────────────────────────────────────────────────────────────────
-- Encoder / Decoder types
-- ────────────────────────────────────────────────────────────────────

/-- An encoder converts a Lean value to an array of SQL parameter strings.
    `None` represents SQL NULL. -/
def Encoder (params : Type) := params → Array (Option String)

/-- A decoder converts a raw `PgResult` into a typed Lean value. -/
def Decoder (result : Type) := PgResult → IO (Except SessionError result)

-- ────────────────────────────────────────────────────────────────────
-- Statement
-- ────────────────────────────────────────────────────────────────────

/-- A type-safe parameterized SQL statement.
    $$\text{Statement}\ p\ r = \{ \text{sql} : \text{String},\
      \text{encode} : p \to \text{Array (Option String)},\
      \text{decode} : \text{PgResult} \to \text{IO (Except SessionError}\ r) \}$$

    The `prepared` flag controls whether the statement uses PostgreSQL
    prepared statements (faster for repeated execution). -/
structure Statement (params : Type) (result : Type) where
  sql : String
  encode : Encoder params
  decode : Decoder result
  prepared : Bool := true

namespace Statement

/-- Run a statement within a session, encoding parameters and decoding results.
    $$\text{run} : \text{Statement}\ p\ r \to p \to \text{Session}\ r$$ -/
def run (stmt : Statement params result) (p : params) : Session result := fun conn => do
  let sqlParams := stmt.encode p
  let pgResult ← if stmt.prepared then
    -- For prepared statements, prepare on first use then execute
    -- Simplified: always use execParams for now
    execParams conn.raw stmt.sql sqlParams
  else
    execParams conn.raw stmt.sql sqlParams
  let st ← resultStatus pgResult
  if st.isOk then
    stmt.decode pgResult
  else
    let msg ← resultErrorMessage pgResult
    return .error (.queryError st msg)

/-- Create a statement that returns no result (INSERT, UPDATE, DELETE, etc.). -/
def command (sql : String) (encode : Encoder params) : Statement params Unit :=
  { sql, encode, decode := fun _ => return .ok (), prepared := true }

/-- Create a statement that expects no parameters and returns no result. -/
def sql_ (sql : String) : Statement Unit Unit :=
  command sql (fun () => #[])

/-- Map the result type of a statement. -/
def mapResult (f : α → β) (stmt : Statement params α) : Statement params β :=
  { stmt with decode := fun res => do
    match ← stmt.decode res with
    | .ok a => return .ok (f a)
    | .error e => return .error e }

/-- Contramap the parameter type of a statement. -/
def contramapParams (f : β → α) (stmt : Statement α result) : Statement β result :=
  { stmt with encode := fun b => stmt.encode (f b) }

end Statement
end Hasql.Statement
