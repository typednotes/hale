/-
  Hale.Warp.Network.Wai.Handler.Warp.PackInt — Integer to ByteArray rendering
  $$\text{packInt} : \mathbb{N} \to \text{String}$$
-/
namespace Network.Wai.Handler.Warp

/-- Render a natural number as a decimal string.
    This is used for Content-Length headers and chunk sizes. -/
@[inline] def packInt (n : Nat) : String := toString n

/-- Render a natural number as a hex string (lowercase).
    Used for HTTP chunked transfer encoding. -/
partial def packHex (n : Nat) : String :=
  if n == 0 then "0"
  else go n ""
where
  go (n : Nat) (acc : String) : String :=
    if n == 0 then acc
    else
      let digit := n % 16
      let c := if digit < 10 then Char.ofNat (digit + '0'.toNat)
               else Char.ofNat (digit - 10 + 'a'.toNat)
      go (n / 16) (c.toString ++ acc)

end Network.Wai.Handler.Warp
