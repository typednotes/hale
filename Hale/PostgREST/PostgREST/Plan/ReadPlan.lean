/-
  Hale.PostgREST.PostgREST.Plan.ReadPlan -- Read plan (SELECT queries)

  A read plan represents a resolved SELECT query with possible embedded
  sub-queries (resource embedding).  Each embedded read becomes a lateral
  join in the generated SQL.

  ## Haskell source
  - `PostgREST.Plan.ReadPlan` (postgrest package)

  ## Design
  - `NonnegRange` captures pagination: an offset and optional limit, both
    non-negative by construction (using `Nat`):
    $$\text{NonnegRange} = \{ \text{offset} : \mathbb{N},\;
      \text{limit} : \mathbb{N}? \}$$
  - `ReadPlan` is recursive via `rpRelationships`, where each embedded
    relationship produces a lateral sub-query:
    $$\text{ReadPlan} = \{ \text{select},\; \text{from},\; \text{where},\;
      \text{order},\; \text{range},\; \text{embeds} : [(\text{Rel}, \text{ReadPlan})] \}$$
-/

import Hale.PostgREST.PostgREST.Plan.Types
import Hale.PostgREST.PostgREST.SchemaCache.Identifiers
import Hale.PostgREST.PostgREST.SchemaCache.Relationship

namespace PostgREST.Plan

open PostgREST.SchemaCache.Identifiers
open PostgREST.SchemaCache

-- ────────────────────────────────────────────────────────────────────
-- Pagination range
-- ────────────────────────────────────────────────────────────────────

/-- A non-negative pagination range.
    $$\text{NonnegRange} = \{ \text{offset} : \mathbb{N},\;
      \text{limit} : \mathbb{N}? \}$$
    Both offset and limit are guaranteed non-negative by using `Nat`. -/
structure NonnegRange where
  rangeOffset : Nat := 0
  rangeLimit : Option Nat := none
  deriving BEq, Repr, Inhabited

/-- The total number of rows this range can produce (if limit is known). -/
def NonnegRange.maxRows (r : NonnegRange) : Option Nat :=
  r.rangeLimit

/-- Whether this range is unbounded (no limit). -/
def NonnegRange.isUnbounded (r : NonnegRange) : Bool :=
  r.rangeLimit.isNone

/-- The default range: offset 0, no limit. -/
def NonnegRange.allRows : NonnegRange :=
  { rangeOffset := 0, rangeLimit := none }

-- ────────────────────────────────────────────────────────────────────
-- Read plan
-- ────────────────────────────────────────────────────────────────────

/-- A read plan represents a SELECT query with possible embedded sub-queries.
    $$\text{ReadPlan} = \{ \text{select} : [\text{SelectField}],\;
      \text{from} : \text{QI},\; \text{where} : [\text{Filter}],\;
      \text{order} : [\text{OrderTerm}],\; \text{range} : \text{NonnegRange},\;
      \text{embeds} : [(\text{Rel}, \text{ReadPlan})],\;
      \text{isInner} : \text{Bool} \}$$

    - `rpSelect`: columns and expressions to select
    - `rpFrom`: the source table or view
    - `rpWhere`: filter conditions
    - `rpOrder`: ordering specification
    - `rpRange`: pagination (offset/limit)
    - `rpRelationships`: embedded reads via lateral joins
    - `rpIsInner`: whether the embed uses INNER (true) or LEFT (false) join
    - `rpAlias`: optional alias for this read in the query -/
structure ReadPlan where
  rpSelect : Array CoercibleSelectField
  rpFrom : QualifiedIdentifier
  rpWhere : Array CoercibleFilter
  rpOrder : Array CoercibleOrderTerm
  rpRange : NonnegRange := {}
  rpRelationships : Array (Relationship × ReadPlan) := #[]
  rpIsInner : Bool := false
  rpAlias : Option String := none
  deriving Repr

/-- Whether this read plan has any embedded sub-queries. -/
def ReadPlan.hasEmbeds (rp : ReadPlan) : Bool :=
  !rp.rpRelationships.isEmpty

/-- The number of embedded sub-queries. -/
def ReadPlan.embedCount (rp : ReadPlan) : Nat :=
  rp.rpRelationships.size

/-- Whether this read plan applies any filters. -/
def ReadPlan.hasFilters (rp : ReadPlan) : Bool :=
  !rp.rpWhere.isEmpty

/-- Whether this read plan specifies an ordering. -/
def ReadPlan.hasOrdering (rp : ReadPlan) : Bool :=
  !rp.rpOrder.isEmpty

end PostgREST.Plan
