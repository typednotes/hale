/-
  Hale.TLS.Network.TLS.Context — TLS context and session management

  Opaque handles wrapping OpenSSL's SSL_CTX and SSL objects via FFI.
  Resources are automatically cleaned up by the GC finalizer.

  ## Design
  Uses the same `lean_alloc_external` / `lean_register_external_class` pattern
  as the socket FFI. SSL_CTX is created once per server (shared across connections),
  SSL sessions are per-connection.

  ## Guarantees
  - TLS context requires valid cert + key at creation time (checked by OpenSSL)
  - SSL_shutdown is called automatically on session finalization
  - Read/write on closed sessions return empty/error
-/
import Hale.TLS.Network.TLS.Types
import Hale.Network

namespace Network.TLS

/-- Opaque handle to an OpenSSL SSL_CTX (TLS server context).
    Created once, shared across all TLS connections. -/
opaque TLSContextHandle : NonemptyType
def TLSContext := TLSContextHandle.type
instance : Nonempty TLSContext := TLSContextHandle.property

/-- Opaque handle to an OpenSSL SSL session (one per TLS connection). -/
opaque TLSSessionHandle : NonemptyType
def TLSSession := TLSSessionHandle.type
instance : Nonempty TLSSession := TLSSessionHandle.property

/-- Create a TLS server context with the given certificate and key files.
    $$\text{createContext} : \text{String} \to \text{String} \to \text{IO TLSContext}$$ -/
@[extern "hale_tls_ctx_create"]
opaque createContext (certPath : @& String) (keyPath : @& String) : IO TLSContext

/-- Enable ALPN negotiation on the context (for HTTP/2 support). -/
@[extern "hale_tls_ctx_set_alpn"]
opaque setAlpn (ctx : @& TLSContext) : IO Unit

/-- Perform a TLS handshake on a connected socket.
    The socket handle is an opaque external object containing the fd.
    Returns the established TLS session.
    $$\text{accept} : \text{TLSContext} \to \text{RawSocket} \to \text{IO TLSSession}$$ -/
@[extern "hale_tls_accept_socket"]
opaque acceptSocket (ctx : @& TLSContext) (sock : @& Network.Socket.RawSocket) : IO TLSSession

/-- Read up to `maxLen` bytes from the TLS session.
    Returns empty ByteArray on EOF or error.
    $$\text{read} : \text{TLSSession} \to \text{USize} \to \text{IO ByteArray}$$ -/
@[extern "hale_tls_read"]
opaque read (session : @& TLSSession) (maxLen : USize) : IO ByteArray

/-- Write all bytes to the TLS session.
    $$\text{write} : \text{TLSSession} \to \text{ByteArray} \to \text{IO Unit}$$ -/
@[extern "hale_tls_write"]
opaque write (session : @& TLSSession) (data : @& ByteArray) : IO Unit

/-- Shut down the TLS session and free resources.
    $$\text{close} : \text{TLSSession} \to \text{IO Unit}$$ -/
@[extern "hale_tls_close"]
opaque close (session : @& TLSSession) : IO Unit

/-- Get the negotiated TLS protocol version string. -/
@[extern "hale_tls_get_version"]
opaque getVersion (session : @& TLSSession) : IO String

/-- Get the ALPN-negotiated protocol (e.g., "h2" or "http/1.1"). -/
@[extern "hale_tls_get_alpn"]
opaque getAlpn (session : @& TLSSession) : IO (Option String)

end Network.TLS
