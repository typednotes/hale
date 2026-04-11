# DataFrame -- Tabular Data

**Lean:** `Hale.DataFrame` | **Haskell:** `dataframe` (adapted)

Tabular data structure with typed columns, supporting subset, sort, join, aggregation, statistics, and CSV I/O.

## Modules

| Module | Description |
|--------|-------------|
| `Internal.Types` | Core DataFrame/Column types |
| `Internal.Column` | Column operations |
| `Operations.Subset` | Row/column selection |
| `Operations.Sort` | Sorting |
| `Operations.Aggregation` | Group-by and aggregation |
| `Operations.Join` | Inner/outer joins |
| `Operations.Statistics` | Mean, std, quantiles |
| `Operations.Transform` | Map, filter, apply |
| `IO.CSV` | CSV read/write |
| `Display` | Pretty-printing |

## Files
- `Hale/DataFrame/DataFrame.lean` -- Re-exports
- `Hale/DataFrame/DataFrame/Internal/Types.lean` -- Core types
- `Hale/DataFrame/DataFrame/Internal/Column.lean` -- Column operations
- `Hale/DataFrame/DataFrame/Operations/*.lean` -- Operations
- `Hale/DataFrame/DataFrame/IO/CSV.lean` -- CSV I/O
- `Hale/DataFrame/DataFrame/Display.lean` -- Display
