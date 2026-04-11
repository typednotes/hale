---
name: haskell-mapping
description: Look up the Haskell-to-Lean module mapping for the hale project. Use when porting a Haskell module, looking up which Lean module corresponds to a Haskell module, adding a new module to the mapping, or understanding the folder organization policy.
compatibility: Designed for Claude Code (or similar products)
metadata:
  author: typednotes
  version: "1.0"
---

# Haskell to Lean Module Mapping

This skill provides the complete mapping between Haskell modules and their Lean ports in the hale project, plus the folder organization rules.

## Folder Organization Policy

The `Hale` project ports multiple Haskell libraries. Each Haskell library gets its own **top-level folder** named after the library (Lean naming convention). Within that folder, the **subfolder path mirrors the Haskell module path** exactly.

```
Hale/
  Base/                    -- Haskell `base` library
    Data/
      Void.lean            -- Data.Void
      Functor/
        Const.lean         -- Data.Functor.Const
    Control/
      Category.lean        -- Control.Category
      Concurrent/
        MVar.lean          -- Control.Concurrent.MVar
  Containers/              -- Haskell `containers`
    Data/
      Map.lean             -- Data.Map
  Text/                    -- Haskell `text`
    Data/
      Text.lean            -- Data.Text
```

**Rules:**
1. **Top-level folder = Haskell library name** in Lean naming convention (`Base` for `base`, `Containers` for `containers`, etc.)
2. **Subfolder path = Haskell module path** exactly (`Data/Functor/Const.lean` for `Data.Functor.Const`)
3. **Namespace = Haskell module path** -- namespaces mirror the Haskell hierarchy, NOT the library name. Examples:
   - `Hale/Base/Data/Ratio.lean` -> `namespace Data` (outer), `namespace Ratio` (inner for methods)
   - `Hale/Base/Data/Functor/Const.lean` -> `namespace Data.Functor` (outer), `namespace Const` (inner)
   - `Hale/Base/Control/Concurrent/MVar.lean` -> `namespace Control.Concurrent` (outer), `namespace MVar` (inner)
   - Users write `open Data` or `open Control.Concurrent` to access types, just like Haskell `import Data.Ratio` or `import Control.Concurrent.MVar`
4. **Sub-namespaces for methods** -- use `namespace Ratio` within `namespace Data` for dot-notation methods (e.g., `Ratio.floor`)
5. **Re-export file** -- each library has a re-export file (`Hale/Base.lean`) that imports all its modules

**Tests** mirror the Haskell module structure: `Tests/Control/TestMVar.lean` for `Control.Concurrent.MVar`.

**Docs** mirror the Haskell module structure: `docs/Control/MVar.md` for `Control.Concurrent.MVar`.

## Module Mapping Tables

The full mapping tables for all ported libraries are in [references/MODULE-MAPPING.md](references/MODULE-MAPPING.md).

To find the Lean module for a given Haskell module, search that file for the Haskell module name.

When adding a new module, update both the mapping table and the AGENTS.md mapping reference.
