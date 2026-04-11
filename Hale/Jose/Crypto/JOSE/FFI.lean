/-
  Hale.Jose.Crypto.JOSE.FFI — FFI declarations for jose.c

  External function declarations for the JOSE crypto operations
  implemented in `ffi/jose.c` using OpenSSL.

  ## FFI
  - Implementation in `ffi/jose.c`
  - Requires OpenSSL headers (shared with `ffi/tls.c`)
-/

namespace Crypto.JOSE.FFI

/-- Compute HMAC using the specified SHA algorithm.
    algorithm: 0=SHA256, 1=SHA384, 2=SHA512 -/
@[extern "hale_jose_hmac"]
opaque hmac (key : @& ByteArray) (data : @& ByteArray)
    (algorithm : UInt8) : IO ByteArray

/-- Verify an RSA signature.
    Returns 1 if valid, 0 if invalid.
    algorithm: 0=SHA256, 1=SHA384, 2=SHA512
    usePss: 1 for PSS padding, 0 for PKCS1v15 -/
@[extern "hale_jose_rsa_verify"]
opaque rsaVerify (pubkeyDer : @& ByteArray) (data : @& ByteArray)
    (signature : @& ByteArray) (algorithm : UInt8) (usePss : UInt8) : IO UInt8

/-- Verify an EC signature.
    Returns 1 if valid, 0 if invalid.
    algorithm: 0=SHA256/P-256, 1=SHA384/P-384, 2=SHA512/P-521 -/
@[extern "hale_jose_ec_verify"]
opaque ecVerify (pubkeyDer : @& ByteArray) (data : @& ByteArray)
    (signature : @& ByteArray) (algorithm : UInt8) : IO UInt8

/-- Build an RSA public key from modulus (n) and exponent (e).
    Returns DER-encoded public key. -/
@[extern "hale_jose_rsa_pubkey_from_components"]
opaque rsaPubkeyFromComponents (n : @& ByteArray) (e : @& ByteArray) : IO ByteArray

/-- Build an EC public key from curve and coordinates.
    Returns DER-encoded public key.
    crv: 0=P-256, 1=P-384, 2=P-521 -/
@[extern "hale_jose_ec_pubkey_from_components"]
opaque ecPubkeyFromComponents (crv : UInt8) (x : @& ByteArray)
    (y : @& ByteArray) : IO ByteArray

/-- Decode base64url-encoded data. -/
@[extern "hale_jose_base64url_decode"]
opaque base64urlDecode (input : @& String) : IO ByteArray

/-- Encode data as base64url. -/
@[extern "hale_jose_base64url_encode"]
opaque base64urlEncode (input : @& ByteArray) : IO String

end Crypto.JOSE.FFI
