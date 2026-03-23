# ResourceT -- Resource Management Monad

**Lean:** `Hale.ResourceT` | **Haskell:** `resourcet`

> **API Reference:** [Hale.ResourceT](../../Hale/ResourceT.html) | [Resource](../../Hale/ResourceT/Control/Monad/Trans/Resource.html)

Ensures cleanup of resources (file handles, connections) even on exceptions.

## Lifecycle

```
  runResourceT ---+
                  |
    allocate(acquire, release)
       | -> (ReleaseKey, resource)
       |
    ... use resource ...
       |
    release(key)  <-- optional early release
       |
  +---- finally: all remaining cleanups run (LIFO order)
```

## Detailed Flow

```
  +---------------------------------------------+
  | runResourceT                                 |
  |                                              |
  |   ref <- IO.mkRef #[]   (cleanup registry)  |
  |                                              |
  |   try                                        |
  |     allocate(open, close)                    |
  |       |  push (key0, close) to registry      |
  |       v                                      |
  |     allocate(connect, disconnect)            |
  |       |  push (key1, disconnect) to registry |
  |       v                                      |
  |     ... user code ...                        |
  |       |                                      |
  |     release(key0)  -- early release          |
  |       |  remove key0 from registry           |
  |       |  run close action                    |
  |       v                                      |
  |     ... more user code ...                   |
  |                                              |
  |   finally                                    |
  |     for (_, cleanup) in registry.reverse:    |
  |       try cleanup catch _ => ()              |
  |       -- key1 (disconnect) runs here         |
  |       -- key0 already released, not in list  |
  +---------------------------------------------+
```

## Core Types

### ResourceT (Monad Transformer)
```lean
def ResourceT (m : Type -> Type) (a : Type) := IO.Ref CleanupMap -> m a
```

### ReleaseKey (Opaque, Single-Use)
```lean
structure ReleaseKey where
  private mk ::
    id : Nat
```

The constructor is private -- only `allocate` can create keys.

## Guarantees
- **LIFO cleanup**: Last allocated = first released
- **Exception-safe**: `try/finally` ensures all cleanups run
- **Single-use keys**: Releasing twice is a no-op (idempotent)
- **Cleanup isolation**: If one cleanup throws, remaining cleanups still run

## Proven Properties (1 theorem)

| Theorem | Statement |
|---------|-----------|
| `releaseKey_eq` | `a = b <-> a.id = b.id` |

## Axiom-Dependent Properties (documented, not machine-checked)
- **Exception safety** depends on `IO.finally` semantics
- **LIFO ordering** depends on `Array` preserving insertion order (which it does)

## Instances
- `Monad (ResourceT m)` (for any `Monad m`)
- `MonadLift IO (ResourceT m)` (for any `MonadLift IO m`)

## Files
- `Hale/ResourceT/Control/Monad/Trans/Resource.lean` -- Full implementation + 1 proof
