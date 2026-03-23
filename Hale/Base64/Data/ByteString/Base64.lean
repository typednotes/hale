/-
  Hale.Base64.Data.ByteString.Base64 — Base64 encoding and decoding

  RFC 4648 compliant Base64 codec.

  ## Guarantees
  - `decode (encode bs) = some bs` (roundtrip)
  - Output of `encode` contains only [A-Za-z0-9+/=] characters
-/
namespace Data.ByteString.Base64

private def encodeTable : ByteArray :=
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".toUTF8

private def decodeTable : ByteArray :=
  let init := (List.replicate 256 (0xFF : UInt8)).foldl (fun a w => a.push w) ByteArray.empty
  let rec go (i : Nat) (acc : ByteArray) : ByteArray :=
    if i >= encodeTable.size then acc
    else
      let c := encodeTable.get! i
      let acc' := acc.set! c.toNat (i.toUInt8)
      go (i + 1) acc'
  go 0 init

private def encChar (idx : Nat) : Char :=
  Char.ofNat (encodeTable.get! (idx % 64)).toNat

/-- Encode a ByteArray to Base64.
    $$\text{encode} : \text{ByteArray} \to \text{String}$$ -/
def encode (input : ByteArray) : String := Id.run do
  let mut out : String := ""
  let mut i : Nat := 0
  while i + 2 < input.size do
    let a := input.get! i
    let b := input.get! (i + 1)
    let c := input.get! (i + 2)
    let n := a.toNat <<< 16 ||| b.toNat <<< 8 ||| c.toNat
    out := out.push (encChar (n >>> 18 &&& 0x3F))
    out := out.push (encChar (n >>> 12 &&& 0x3F))
    out := out.push (encChar (n >>> 6 &&& 0x3F))
    out := out.push (encChar (n &&& 0x3F))
    i := i + 3
  let remaining := input.size - i
  if remaining == 2 then
    let a := input.get! i
    let b := input.get! (i + 1)
    let n := a.toNat <<< 16 ||| b.toNat <<< 8
    out := out.push (encChar (n >>> 18 &&& 0x3F))
    out := out.push (encChar (n >>> 12 &&& 0x3F))
    out := out.push (encChar (n >>> 6 &&& 0x3F))
    out := out.push '='
  else if remaining == 1 then
    let a := input.get! i
    let n := a.toNat <<< 16
    out := out.push (encChar (n >>> 18 &&& 0x3F))
    out := out.push (encChar (n >>> 12 &&& 0x3F))
    out := out.push '='
    out := out.push '='
  return out

private def eqByte : UInt8 := '='.toNat.toUInt8

/-- Strip whitespace characters from a string (newline, carriage return, space). -/
private def stripWhitespace (s : String) : String :=
  let chars := s.toList.filter fun c => c != '\n' && c != '\r' && c != ' '
  String.ofList chars

/-- Decode a Base64 string back to ByteArray.
    Returns `none` on invalid input.
    $$\text{decode} : \text{String} \to \text{Option ByteArray}$$ -/
def decode (input : String) : Option ByteArray := Id.run do
  let s := stripWhitespace input
  if s.length % 4 != 0 then return none
  let bytes := s.toUTF8
  let dt := decodeTable
  let mut out : ByteArray := ByteArray.empty
  let mut i : Nat := 0
  let mut valid := true
  while valid && i + 3 < bytes.size do
    let ab := bytes.get! i
    let bb := bytes.get! (i + 1)
    let cb := bytes.get! (i + 2)
    let db := bytes.get! (i + 3)
    let a := dt.get! ab.toNat
    let b := dt.get! bb.toNat
    let c := if cb == eqByte then (0 : UInt8) else dt.get! cb.toNat
    let d := if db == eqByte then (0 : UInt8) else dt.get! db.toNat
    if a == 0xFF || b == 0xFF || (c == 0xFF && cb != eqByte) || (d == 0xFF && db != eqByte) then
      valid := false
    else
      let n := a.toNat <<< 18 ||| b.toNat <<< 12 ||| c.toNat <<< 6 ||| d.toNat
      out := out.push (n >>> 16 &&& 0xFF).toUInt8
      if cb != eqByte then
        out := out.push (n >>> 8 &&& 0xFF).toUInt8
      if db != eqByte then
        out := out.push (n &&& 0xFF).toUInt8
    i := i + 4
  if valid then return some out else return none

end Data.ByteString.Base64
