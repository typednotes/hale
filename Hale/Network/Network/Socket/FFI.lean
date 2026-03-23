/-
  Hale.Network.Network.Socket.FFI — C FFI bindings for POSIX sockets

  Low-level extern declarations mapping to the C shim in `ffi/network.c`.
  These are not intended for direct use; see `Network.Socket` for the safe API.

  ## Design

  Socket and EventLoop are opaque external objects (lean_alloc_external).
  All FFI functions receive them as borrowed references (@& Socket / @& EventLoop).
  The external classes are registered at initialization time via `hale_socket_initialize`.

  ## Encoding conventions

  - Pairs are nested: `(A × B × C)` = `(A × (B × C))` = `ctor(0,2,0)[a, ctor(0,2,0)[b, c]]`
  - Lists use `ctor(1,2,0)` for cons, `box(0)` for nil
  - USize values are boxed/unboxed with `lean_box`/`lean_unbox`
  - All functions return `IO` (lean_io_result_mk_ok / lean_io_result_mk_error)
-/

import Hale.Network.Network.Socket.Types

namespace Network.Socket.FFI

open Network.Socket

-- ── RecvBuffer: buffered reader for HTTP request parsing ──
-- Reads socket data in 4KB chunks, scans for CRLF entirely in C.
-- The RecvBuffer borrows the socket fd — the Socket must outlive it.

/-- Opaque buffered reader handle. -/
opaque RecvBufferHandle : NonemptyType
/-- A buffered reader over a socket. Reads in 4KB chunks, scans for CRLF in C.
    **Invariant (axiom-dependent):** the Socket must outlive the RecvBuffer. -/
def RecvBuffer : Type := RecvBufferHandle.type
instance : Nonempty RecvBuffer := RecvBufferHandle.property

/-- Create a buffered reader for a socket.
    $$\text{recvBufCreate} : \text{Socket} \to \text{IO}(\text{RecvBuffer})$$ -/
@[extern "hale_recvbuf_create"]
opaque recvBufCreate (sock : @& Socket) : IO RecvBuffer

/-- Read a CRLF-terminated line. Returns the line without the CRLF.
    Returns empty string on EOF. The scan loop runs entirely in C.
    $$\text{recvBufReadLine} : \text{RecvBuffer} \to \text{IO}(\text{String})$$ -/
@[extern "hale_recvbuf_readline"]
opaque recvBufReadLine (buf : @& RecvBuffer) : IO String

/-- Read exactly n bytes. For reading request bodies with known Content-Length.
    $$\text{recvBufReadN} : \text{RecvBuffer} \to \text{USize} \to \text{IO}(\text{ByteArray})$$ -/
@[extern "hale_recvbuf_readn"]
opaque recvBufReadN (buf : @& RecvBuffer) (n : USize) : IO ByteArray

-- ── Socket creation and management ──
-- Note: External classes for Socket and EventLoop are lazily initialized
-- in the C FFI (hale_ensure_classes_initialized) on first use.

/-- Create a socket. Returns an opaque Socket handle.
    $$\text{socketCreate} : \text{UInt8} \to \text{UInt8} \to \text{IO}(\text{Socket})$$ -/
@[extern "hale_socket_create"]
opaque socketCreate (domain : UInt8) (socktype : UInt8) : IO Socket

/-- Close a socket. The fd is also closed by the GC finalizer, but
    explicit close is preferred for deterministic resource release.
    $$\text{socketClose} : \text{Socket} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_close"]
opaque socketClose (sock : @& Socket) : IO Unit

/-- Bind a socket to an address (IPv4/IPv6 via getaddrinfo).
    $$\text{socketBind} : \text{Socket} \to \text{String} \to \text{UInt16} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_bind"]
opaque socketBind (sock : @& Socket) (host : @& String) (port : UInt16) : IO Unit

/-- Listen for connections.
    $$\text{socketListen} : \text{Socket} \to \text{USize} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_listen"]
opaque socketListen (sock : @& Socket) (backlog : USize) : IO Unit

/-- Accept a connection. Returns the client socket.
    $$\text{socketAccept} : \text{Socket} \to \text{IO}\ \text{Socket}$$ -/
@[extern "hale_socket_accept"]
opaque socketAccept (sock : @& Socket) : IO Socket

/-- Connect to a remote address (IPv4/IPv6 via getaddrinfo).
    $$\text{socketConnect} : \text{Socket} \to \text{String} \to \text{UInt16} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_connect"]
opaque socketConnect (sock : @& Socket) (host : @& String) (port : UInt16) : IO Unit

-- ── Send / Recv (TCP) ──

/-- Send data. Returns bytes sent.
    $$\text{socketSend} : \text{Socket} \to \text{ByteArray} \to \text{IO}(\text{USize})$$ -/
@[extern "hale_socket_send"]
opaque socketSend (sock : @& Socket) (data : @& ByteArray) : IO USize

/-- Receive data. Returns received bytes.
    $$\text{socketRecv} : \text{Socket} \to \text{USize} \to \text{IO}(\text{ByteArray})$$ -/
@[extern "hale_socket_recv"]
opaque socketRecv (sock : @& Socket) (maxlen : USize) : IO ByteArray

/-- Send all data, looping until complete. Implemented in C to avoid
    Lean compiler issues with Prod containing scalar loop state.
    $$\text{socketSendAll} : \text{Socket} \to \text{ByteArray} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_sendall"]
opaque socketSendAll (sock : @& Socket) (data : @& ByteArray) : IO Unit

-- ── UDP: sendto / recvfrom ──

/-- Send data to a specific address (UDP).
    $$\text{socketSendTo} : \text{Socket} \to \text{ByteArray} \to \text{String} \to \text{UInt16} \to \text{IO}(\text{USize})$$ -/
@[extern "hale_socket_sendto"]
opaque socketSendTo (sock : @& Socket) (data : @& ByteArray) (host : @& String) (port : UInt16) : IO USize

/-- Receive data with sender address (UDP).
    Returns `(data, (host, port))`.
    $$\text{socketRecvFrom} : \text{Socket} \to \text{USize} \to \text{IO}(\text{ByteArray} \times (\text{String} \times \text{USize}))$$ -/
@[extern "hale_socket_recvfrom"]
opaque socketRecvFrom (sock : @& Socket) (maxlen : USize) : IO (ByteArray × String × USize)

-- ── Socket options ──

/-- Set SO_REUSEADDR option.
    $$\text{setReuseAddr} : \text{Socket} \to \text{UInt8} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_set_reuseaddr"]
opaque setReuseAddr (sock : @& Socket) (enable : UInt8) : IO Unit

/-- Set TCP_NODELAY option.
    $$\text{setNoDelay} : \text{Socket} \to \text{UInt8} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_set_nodelay"]
opaque setNoDelay (sock : @& Socket) (enable : UInt8) : IO Unit

/-- Set non-blocking mode.
    $$\text{setNonBlocking} : \text{Socket} \to \text{UInt8} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_set_nonblocking"]
opaque setNonBlocking (sock : @& Socket) (enable : UInt8) : IO Unit

/-- Set SO_KEEPALIVE option.
    $$\text{setKeepAlive} : \text{Socket} \to \text{UInt8} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_set_keepalive"]
opaque setKeepAlive (sock : @& Socket) (enable : UInt8) : IO Unit

/-- Set SO_LINGER option.
    $$\text{setLinger} : \text{Socket} \to \text{UInt8} \to \text{USize} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_set_linger"]
opaque setLinger (sock : @& Socket) (enable : UInt8) (seconds : USize) : IO Unit

/-- Set SO_RCVBUF size.
    $$\text{setRecvBuf} : \text{Socket} \to \text{USize} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_set_recvbuf"]
opaque setRecvBuf (sock : @& Socket) (size : USize) : IO Unit

/-- Set SO_SNDBUF size.
    $$\text{setSendBuf} : \text{Socket} \to \text{USize} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_set_sendbuf"]
opaque setSendBuf (sock : @& Socket) (size : USize) : IO Unit

/-- Shutdown a socket (read, write, or both).
    $$\text{socketShutdown} : \text{Socket} \to \text{UInt8} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_socket_shutdown"]
opaque socketShutdown (sock : @& Socket) (how : UInt8) : IO Unit

/-- Get peer address host string.
    $$\text{getPeerNameHost} : \text{Socket} \to \text{IO}(\text{String})$$ -/
@[extern "hale_socket_getpeername_host"]
opaque getPeerNameHost (sock : @& Socket) : IO String

/-- Get peer address port.
    $$\text{getPeerNamePort} : \text{Socket} \to \text{IO}(\text{UInt16})$$ -/
@[extern "hale_socket_getpeername_port"]
opaque getPeerNamePort (sock : @& Socket) : IO UInt16

/-- Get local address host string.
    $$\text{getSockNameHost} : \text{Socket} \to \text{IO}(\text{String})$$ -/
@[extern "hale_socket_getsockname_host"]
opaque getSockNameHost (sock : @& Socket) : IO String

/-- Get local address port.
    $$\text{getSockNamePort} : \text{Socket} \to \text{IO}(\text{UInt16})$$ -/
@[extern "hale_socket_getsockname_port"]
opaque getSockNamePort (sock : @& Socket) : IO UInt16

-- ── DNS resolution ──

/-- Resolve a hostname. Returns list of `(family, (host, port))`.
    $$\text{getAddrInfo} : \text{String} \to \text{String} \to \text{IO}(\text{List}(\text{USize} \times (\text{String} \times \text{USize})))$$ -/
@[extern "hale_getaddrinfo"]
opaque getAddrInfo (node : @& String) (service : @& String) : IO (List (USize × String × USize))

-- ── Event multiplexing (kqueue/epoll) ──

/-- Create an event loop (kqueue on macOS, epoll on Linux).
    $$\text{eventLoopCreate} : \text{IO}(\text{EventLoop})$$ -/
@[extern "hale_event_loop_create"]
opaque eventLoopCreate : IO EventLoop

/-- Register interest in events for a socket.
    $$\text{eventLoopAdd} : \text{EventLoop} \to \text{Socket} \to \text{USize} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_event_loop_add"]
opaque eventLoopAdd (loop : @& EventLoop) (sock : @& Socket) (events : USize) : IO Unit

/-- Unregister a socket from the event loop.
    $$\text{eventLoopDel} : \text{EventLoop} \to \text{Socket} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_event_loop_del"]
opaque eventLoopDel (loop : @& EventLoop) (sock : @& Socket) : IO Unit

/-- Wait for events. Returns `List (fd × events)`.
    timeout is in milliseconds; pass a very large value for indefinite blocking.
    $$\text{eventLoopWait} : \text{EventLoop} \to \text{USize} \to \text{IO}(\text{List}(\text{USize} \times \text{USize}))$$ -/
@[extern "hale_event_loop_wait"]
opaque eventLoopWait (loop : @& EventLoop) (timeoutMs : USize) : IO (List (USize × USize))

/-- Close the event loop. The fd is also closed by the GC finalizer, but
    explicit close is preferred for deterministic resource release.
    $$\text{eventLoopClose} : \text{EventLoop} \to \text{IO}(\text{Unit})$$ -/
@[extern "hale_event_loop_close"]
opaque eventLoopClose (loop : @& EventLoop) : IO Unit

end Network.Socket.FFI
