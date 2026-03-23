/-
  Hale.Warp.Network.Wai.Handler.Warp.HashMap — Specialized hash map

  Thin wrapper around Lean's HashMap for header storage.
  In Haskell Warp, this is a custom hash map optimized for small collections.
  In Lean, we use the standard HashMap which is already efficient.
-/
import Std.Data.HashMap

namespace Network.Wai.Handler.Warp

/-- A specialized hash map for string keys.
    Uses Lean's standard HashMap. -/
abbrev HeaderMap := Std.HashMap String String

namespace HeaderMap

/-- Create an empty header map. -/
@[inline] def empty : HeaderMap := {}

/-- Insert a key-value pair. -/
@[inline] def insert' (m : HeaderMap) (k v : String) : HeaderMap :=
  Std.HashMap.insert m k v

/-- Look up a value by key. -/
@[inline] def find? (m : HeaderMap) (k : String) : Option String :=
  Std.HashMap.get? m k

end HeaderMap

end Network.Wai.Handler.Warp
