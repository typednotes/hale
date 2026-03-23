/-
  Hale.TLS.Network.TLS.Types — TLS type definitions

  Core types for the TLS FFI wrapper.
-/
namespace Network.TLS

/-- TLS protocol version. -/
inductive TLSVersion where
  | tls10 | tls11 | tls12 | tls13
deriving BEq, Repr

instance : ToString TLSVersion where
  toString
    | .tls10 => "TLSv1.0"
    | .tls11 => "TLSv1.1"
    | .tls12 => "TLSv1.2"
    | .tls13 => "TLSv1.3"

/-- TLS cipher ID. -/
abbrev CipherID := UInt16

end Network.TLS
