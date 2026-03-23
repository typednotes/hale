/-
  Hale.Network.Network.Socket — High-level socket API

  Provides a safe, high-level API for POSIX sockets.
  All resources are managed; `withSocket` ensures proper cleanup.

  ## Design

  Wraps the raw FFI bindings with a clean API matching Haskell's `Network.Socket`.
  Supports IPv4, IPv6, UDP, and event multiplexing (kqueue/epoll).

  Socket and EventLoop are opaque types backed by `lean_alloc_external`.
  The GC finalizer automatically closes file descriptors, but explicit
  `close` is preferred for deterministic resource management.

  ## Guarantees

  - `withSocket` ensures sockets are closed even on exceptions (try/finally)
  - `withEventLoop` ensures event loops are closed even on exceptions
  - SO_REUSEADDR is set by default for server sockets via `listenTCP`
  - All IO errors from POSIX calls are surfaced as `IO.Error`
-/

import Hale.Network.Network.Socket.FFI

namespace Network.Socket

open Network.Socket.FFI

-- ══════════════════════════════════════════════════════════════
-- Socket creation and lifecycle
-- ══════════════════════════════════════════════════════════════

/-- Create a new socket.
    $$\text{socket} : \text{Family} \to \text{SocketType} \to \text{IO}(\text{Socket})$$ -/
def socket (fam : Family) (typ : SocketType) : IO Socket :=
  socketCreate fam.toUInt8 typ.toUInt8

/-- Close a socket. The fd is also closed by the GC finalizer, but
    explicit close is preferred for deterministic resource release.
    $$\text{close} : \text{Socket} \to \text{IO}(\text{Unit})$$ -/
@[inline] def close (s : Socket) : IO Unit :=
  socketClose s

/-- Run an action with a socket, ensuring it is closed afterwards.
    $$\text{withSocket} : \text{Family} \to \text{SocketType} \to (\text{Socket} \to \text{IO}(\alpha)) \to \text{IO}(\alpha)$$ -/
def withSocket (fam : Family) (typ : SocketType) (f : Socket → IO α) : IO α := do
  let s ← socket fam typ
  try
    f s
  finally
    close s

-- ══════════════════════════════════════════════════════════════
-- Core socket operations
-- ══════════════════════════════════════════════════════════════

/-- Bind a socket to an address.
    $$\text{bind} : \text{Socket} \to \text{SockAddr} \to \text{IO}(\text{Unit})$$ -/
@[inline] def bind (s : Socket) (addr : SockAddr) : IO Unit :=
  socketBind s addr.host addr.port

/-- Start listening for connections.
    $$\text{listen} : \text{Socket} \to \mathbb{N} \to \text{IO}(\text{Unit})$$ -/
@[inline] def listen (s : Socket) (backlog : Nat := 128) : IO Unit :=
  socketListen s backlog.toUSize

/-- Accept a connection. Returns the client socket and remote address.
    $$\text{accept} : \text{Socket} \to \text{IO}(\text{Socket} \times \text{SockAddr})$$ -/
def accept (s : Socket) : IO (Socket × SockAddr) := do
  let clientSock ← socketAccept s
  let host ← FFI.getPeerNameHost clientSock
  let port ← FFI.getPeerNamePort clientSock
  pure (clientSock, ⟨host, port⟩)

/-- Connect to a remote address.
    $$\text{connect} : \text{Socket} \to \text{SockAddr} \to \text{IO}(\text{Unit})$$ -/
@[inline] def connect (s : Socket) (addr : SockAddr) : IO Unit :=
  socketConnect s addr.host addr.port

/-- Send a ByteArray on the socket. Returns bytes sent.
    $$\text{send} : \text{Socket} \to \text{ByteArray} \to \text{IO}(\mathbb{N})$$ -/
@[inline] def send (s : Socket) (data : ByteArray) : IO Nat := do
  let n ← socketSend s data
  pure n.toNat

/-- Receive up to `maxlen` bytes from the socket.
    $$\text{recv} : \text{Socket} \to \mathbb{N} \to \text{IO}(\text{ByteArray})$$ -/
@[inline] def recv (s : Socket) (maxlen : Nat := 4096) : IO ByteArray :=
  socketRecv s maxlen.toUSize

/-- Shutdown a socket for reading, writing, or both.
    $$\text{shutdown} : \text{Socket} \to \text{ShutdownHow} \to \text{IO}(\text{Unit})$$ -/
@[inline] def shutdown (s : Socket) (how : ShutdownHow) : IO Unit :=
  socketShutdown s how.toUInt8

-- ══════════════════════════════════════════════════════════════
-- Socket options
-- ══════════════════════════════════════════════════════════════

/-- Set the SO_REUSEADDR option. -/
@[inline] def setReuseAddr (s : Socket) (enable : Bool := true) : IO Unit :=
  FFI.setReuseAddr s (if enable then 1 else 0)

/-- Set the TCP_NODELAY option. -/
@[inline] def setNoDelay (s : Socket) (enable : Bool := true) : IO Unit :=
  FFI.setNoDelay s (if enable then 1 else 0)

/-- Set non-blocking mode. -/
@[inline] def setNonBlocking (s : Socket) (enable : Bool := true) : IO Unit :=
  FFI.setNonBlocking s (if enable then 1 else 0)

/-- Set the SO_KEEPALIVE option. -/
@[inline] def setKeepAlive (s : Socket) (enable : Bool := true) : IO Unit :=
  FFI.setKeepAlive s (if enable then 1 else 0)

/-- Set the SO_LINGER option.
    When enabled, `close` will block for up to `seconds` to flush pending data. -/
@[inline] def setLinger (s : Socket) (enable : Bool) (seconds : Nat := 0) : IO Unit :=
  FFI.setLinger s (if enable then 1 else 0) seconds.toUSize

/-- Set the receive buffer size (SO_RCVBUF). -/
@[inline] def setRecvBufSize (s : Socket) (size : Nat) : IO Unit :=
  FFI.setRecvBuf s size.toUSize

/-- Set the send buffer size (SO_SNDBUF). -/
@[inline] def setSendBufSize (s : Socket) (size : Nat) : IO Unit :=
  FFI.setSendBuf s size.toUSize

-- ══════════════════════════════════════════════════════════════
-- Address introspection
-- ══════════════════════════════════════════════════════════════

/-- Get the remote peer's address.
    $$\text{getPeerName} : \text{Socket} \to \text{IO}(\text{SockAddr})$$ -/
def getPeerName (s : Socket) : IO SockAddr := do
  let host ← FFI.getPeerNameHost s
  let port ← FFI.getPeerNamePort s
  pure ⟨host, port⟩

/-- Get the socket's locally-bound address.
    $$\text{getSockName} : \text{Socket} \to \text{IO}(\text{SockAddr})$$ -/
def getSockName (s : Socket) : IO SockAddr := do
  let host ← FFI.getSockNameHost s
  let port ← FFI.getSockNamePort s
  pure ⟨host, port⟩

-- ══════════════════════════════════════════════════════════════
-- DNS resolution
-- ══════════════════════════════════════════════════════════════

/-- Resolve a hostname and service to a list of addresses.
    $$\text{getAddrInfo} : \text{String} \to \text{String} \to \text{IO}(\text{List}\ \text{AddrInfo})$$ -/
def getAddrInfo (host : String) (service : String) : IO (List AddrInfo) := do
  let results ← FFI.getAddrInfo host service
  pure (results.map fun (fam, h, p) =>
    { family := Family.ofUInt8 fam.toNat.toUInt8
    , host := h
    , port := p.toNat })

-- ══════════════════════════════════════════════════════════════
-- Convenience: TCP server
-- ══════════════════════════════════════════════════════════════

/-- Create a TCP server socket: socket + reuseaddr + bind + listen.
    $$\text{listenTCP} : \text{String} \to \text{UInt16} \to \text{IO}(\text{Socket})$$ -/
def listenTCP (host : String) (port : UInt16) (backlog : Nat := 128) : IO Socket := do
  let s ← socket .inet .stream
  setReuseAddr s
  bind s ⟨host, port⟩
  listen s backlog
  pure s

/-- Create a TCP server socket with IPv6 support.
    $$\text{listenTCP6} : \text{String} \to \text{UInt16} \to \text{IO}(\text{Socket})$$ -/
def listenTCP6 (host : String) (port : UInt16) (backlog : Nat := 128) : IO Socket := do
  let s ← socket .inet6 .stream
  setReuseAddr s
  bind s ⟨host, port⟩
  listen s backlog
  pure s

-- ══════════════════════════════════════════════════════════════
-- Event loop (kqueue / epoll)
-- ══════════════════════════════════════════════════════════════

namespace EventLoop

/-- Create a new event loop.
    $$\text{create} : \text{IO}(\text{EventLoop})$$ -/
def create : IO EventLoop :=
  FFI.eventLoopCreate

/-- Close an event loop.
    $$\text{close} : \text{EventLoop} \to \text{IO}(\text{Unit})$$ -/
@[inline] def close (el : EventLoop) : IO Unit :=
  FFI.eventLoopClose el

/-- Register interest in events for a socket.
    $$\text{add} : \text{EventLoop} \to \text{Socket} \to \text{EventType} \to \text{IO}(\text{Unit})$$ -/
@[inline] def add (el : EventLoop) (s : Socket) (events : EventType) : IO Unit :=
  FFI.eventLoopAdd el s events.flags

/-- Unregister a socket from the event loop.
    $$\text{del} : \text{EventLoop} \to \text{Socket} \to \text{IO}(\text{Unit})$$ -/
@[inline] def del (el : EventLoop) (s : Socket) : IO Unit :=
  FFI.eventLoopDel el s

/-- Wait for events with a timeout (in milliseconds).
    Returns a list of ready events.
    $$\text{wait} : \text{EventLoop} \to \text{Nat} \to \text{IO}(\text{List}\ \text{ReadyEvent})$$ -/
def wait (el : EventLoop) (timeoutMs : Nat := 1000) : IO (List ReadyEvent) := do
  let results ← FFI.eventLoopWait el timeoutMs.toUSize
  pure (results.map fun (fd, evts) => ⟨fd, ⟨evts⟩⟩)

end EventLoop

/-- Run an action with an event loop, ensuring it is closed afterwards.
    $$\text{withEventLoop} : (\text{EventLoop} \to \text{IO}(\alpha)) \to \text{IO}(\alpha)$$ -/
def withEventLoop (f : EventLoop → IO α) : IO α := do
  let el ← EventLoop.create
  try
    f el
  finally
    EventLoop.close el

end Network.Socket
