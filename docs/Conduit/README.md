# Conduit -- Stream Processing

**Lean:** `Hale.Conduit` | **Haskell:** `conduit`

Composable streaming data pipelines. `ConduitT i o m r` is a CPS wrapper over `Pipe` with O(1) monadic bind.

## Key Types

| Type | Description |
|------|-------------|
| `ConduitT i o m r` | Stream processor (input `i`, output `o`, monad `m`, result `r`) |
| `Source m o` | Producer (`ConduitT () o m ()`) |
| `Sink i m r` | Consumer (`ConduitT i Void m r`) |

## API

| Function | Description |
|----------|-------------|
| `await` | Request next input |
| `yield` | Produce output |
| `leftoverC` | Push back unconsumed input |
| `awaitForever` | Process all inputs |
| `pipe` / `.\|` | Fuse two conduits |
| `runConduit` | Execute a pipeline |
| `bracketP` | Resource-safe bracket |

## Files
- `Hale/Conduit/Data/Conduit.lean` -- Re-exports
- `Hale/Conduit/Data/Conduit/Internal/Pipe.lean` -- Pipe type
- `Hale/Conduit/Data/Conduit/Internal/Conduit.lean` -- ConduitT, fusion
- `Hale/Conduit/Data/Conduit/Combinators.lean` -- Standard combinators
