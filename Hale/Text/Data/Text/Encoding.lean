/-
  Hale.Text.Data.Text.Encoding — UTF-8 encoding and decoding

  Provides encoding/decoding between `Text` and `ByteString`.

  ## Haskell equivalent
  `Data.Text.Encoding` (https://hackage.haskell.org/package/text/docs/Data-Text-Encoding.html)

  ## Design
  Lean's `String` is internally UTF-8, so `encodeUtf8` simply extracts the bytes
  via `String.toUTF8`. Decoding validates UTF-8 sequences and reports errors.

  $$\text{encodeUtf8} : \text{Text} \to \text{ByteString}$$
  $$\text{decodeUtf8'} : \text{ByteString} \to \text{Except}\ \text{UnicodeError}\ \text{Text}$$
-/

import Hale.Text.Data.Text
import Hale.ByteString.Data.ByteString

namespace Data.Text

namespace Encoding

open Data.ByteString (ByteString)

/-- Error type for Unicode decoding failures.
    $$\text{UnicodeError} = \{ \text{reason} : \text{String} \}$$ -/
structure UnicodeError where
  /-- Human-readable description of the decoding error. -/
  reason : String
  deriving Repr, BEq

instance : ToString UnicodeError where
  toString e := s!"UnicodeError: {e.reason}"

/-- Error handler type for decoding. Given an error description and the failing
    byte (if available), produce a replacement character or `none` to skip.
    $$\text{OnDecodeError} : \text{String} \to \text{Option}\ \text{UInt8} \to \text{Option}\ \text{Char}$$ -/
def OnDecodeError := String → Option UInt8 → Option Char

/-- The Unicode replacement character U+FFFD. -/
private def replacementChar : Char := Char.ofNat 0xFFFD

/-- Default error handler: replace invalid bytes with the Unicode replacement character U+FFFD.
    $$\text{lenientDecode}(\_,\_) = \text{some}(\text{U+FFFD})$$ -/
def lenientDecode : OnDecodeError :=
  fun _ _ => some replacementChar

/-- Strict error handler: always returns `none`, causing `decodeUtf8With` to
    skip invalid bytes.
    $$\text{strictDecode}(\_,\_) = \text{none}$$ -/
def strictDecode : OnDecodeError :=
  fun _ _ => none

-- ── Helpers for UTF-8 validation ─────────────────

/-- Check if a byte is a valid UTF-8 continuation byte (10xxxxxx). -/
private def isContinuation (b : UInt8) : Bool :=
  (b &&& 0xC0) == 0x80

/-- Decode a single UTF-8 code point starting at position `i` in the byte array.
    Returns `(char, bytesConsumed)` or `none` on invalid sequence. -/
private def decodeOneUtf8 (data : ByteArray) (off i len : Nat) : Option (Char × Nat) :=
  if i >= len then none
  else
    let b0 := data.get! (off + i)
    if b0 < 0x80 then
      -- 1-byte: 0xxxxxxx
      some (Char.ofNat b0.toNat, 1)
    else if b0 < 0xC0 then
      -- Unexpected continuation byte
      none
    else if b0 < 0xE0 then
      -- 2-byte: 110xxxxx 10xxxxxx
      if i + 1 >= len then none
      else
        let b1 := data.get! (off + i + 1)
        if !isContinuation b1 then none
        else
          let cp := ((b0.toNat &&& 0x1F) <<< 6) ||| (b1.toNat &&& 0x3F)
          if cp < 0x80 then none  -- overlong
          else some (Char.ofNat cp, 2)
    else if b0 < 0xF0 then
      -- 3-byte: 1110xxxx 10xxxxxx 10xxxxxx
      if i + 2 >= len then none
      else
        let b1 := data.get! (off + i + 1)
        let b2 := data.get! (off + i + 2)
        if !isContinuation b1 || !isContinuation b2 then none
        else
          let cp := ((b0.toNat &&& 0x0F) <<< 12) |||
                    ((b1.toNat &&& 0x3F) <<< 6) |||
                    (b2.toNat &&& 0x3F)
          if cp < 0x800 then none  -- overlong
          else if cp >= 0xD800 && cp <= 0xDFFF then none  -- surrogate
          else some (Char.ofNat cp, 3)
    else if b0 < 0xF8 then
      -- 4-byte: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
      if i + 3 >= len then none
      else
        let b1 := data.get! (off + i + 1)
        let b2 := data.get! (off + i + 2)
        let b3 := data.get! (off + i + 3)
        if !isContinuation b1 || !isContinuation b2 || !isContinuation b3 then none
        else
          let cp := ((b0.toNat &&& 0x07) <<< 18) |||
                    ((b1.toNat &&& 0x3F) <<< 12) |||
                    ((b2.toNat &&& 0x3F) <<< 6) |||
                    (b3.toNat &&& 0x3F)
          if cp < 0x10000 then none  -- overlong
          else if cp > 0x10FFFF then none  -- out of range
          else some (Char.ofNat cp, 4)
    else
      none

-- ── Encoding ─────────────────────────────────────

/-- Encode `Text` as a UTF-8 `ByteString`. O(n).
    Lean's `String` is already UTF-8, so this extracts the raw bytes.
    $$\text{encodeUtf8}(t).\text{bytes} = \text{UTF-8}(t)$$ -/
def encodeUtf8 (t : Data.Text) : ByteString :=
  let arr := t.toUTF8
  ⟨arr, 0, arr.size, by omega⟩

-- ── Decoding ─────────────────────────────────────

/-- Decode a UTF-8 `ByteString` into `Text`, returning an error on invalid input.
    Uses fuel-based termination (fuel = remaining bytes).
    $$\text{decodeUtf8'}(bs) = \begin{cases} \text{ok}(t) & \text{if valid UTF-8} \\ \text{error}(e) & \text{otherwise} \end{cases}$$ -/
def decodeUtf8' (bs : ByteString) : Except UnicodeError Data.Text :=
  go 0 bs.len []
where
  go (i fuel : Nat) (acc : List Char) : Except UnicodeError Data.Text :=
    if i >= bs.len then
      .ok (Data.Text.pack acc.reverse)
    else match fuel with
    | 0 => .ok (Data.Text.pack acc.reverse)
    | fuel + 1 =>
      match decodeOneUtf8 bs.data bs.off i bs.len with
      | some (c, consumed) => go (i + consumed) fuel (c :: acc)
      | none => .error ⟨s!"Invalid UTF-8 byte at offset {i}"⟩

/-- Decode a UTF-8 `ByteString` using a custom error handler.
    Invalid bytes are replaced according to `onError`.
    Uses fuel-based termination (fuel = remaining bytes).
    $$\text{decodeUtf8With}(\text{onError}, bs)$$ -/
def decodeUtf8With (onError : OnDecodeError) (bs : ByteString) : Data.Text :=
  go 0 bs.len []
where
  go (i fuel : Nat) (acc : List Char) : Data.Text :=
    if i >= bs.len then
      Data.Text.pack acc.reverse
    else match fuel with
    | 0 => Data.Text.pack acc.reverse
    | fuel + 1 =>
      match decodeOneUtf8 bs.data bs.off i bs.len with
      | some (c, consumed) => go (i + consumed) fuel (c :: acc)
      | none =>
        let byte := if i < bs.len then
          some (bs.data.get! (bs.off + i))
        else none
        match onError "Invalid UTF-8 byte sequence" byte with
        | some replacement => go (i + 1) fuel (replacement :: acc)
        | none => go (i + 1) fuel acc

/-- Decode a UTF-8 `ByteString`, replacing invalid bytes with U+FFFD.
    $$\text{decodeUtf8Lenient}(bs)$$ -/
def decodeUtf8Lenient (bs : ByteString) : Data.Text :=
  decodeUtf8With lenientDecode bs

/-- Decode a Latin-1 (ISO 8859-1) encoded `ByteString` to `Text`.
    Each byte maps directly to the corresponding Unicode code point.
    $$\text{decodeLatin1}(bs) = \text{pack}([b_0, b_1, \ldots])$$ where each $b_i$ is
    interpreted as a Unicode code point. -/
def decodeLatin1 (bs : ByteString) : Data.Text :=
  Data.Text.pack (go bs.off bs.len [])
where
  go (i remaining : Nat) (acc : List Char) : List Char :=
    match remaining with
    | 0 => acc.reverse
    | n + 1 =>
      let b := bs.data.get! i
      go (i + 1) n (Char.ofNat b.toNat :: acc)

end Encoding

end Data.Text
