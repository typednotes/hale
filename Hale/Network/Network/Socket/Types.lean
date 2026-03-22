/-
  Hale.Network.Network.Socket.Types — Socket type definitions

  Core types for the network socket abstraction.
  Ports Haskell's `Network.Socket.Types` from the `network` package.

  ## Types

  - `Family`: AF_INET, AF_INET6, AF_UNIX
  - `SocketType`: SOCK_STREAM, SOCK_DGRAM, SOCK_RAW
  - `ShutdownHow`: SHUT_RD, SHUT_WR, SHUT_RDWR
  - `EventType`: readable, writable, error flags
  - `EventLoop`: opaque event multiplexing handle (kqueue/epoll)
  - `SockAddr`: host + port
  - `Socket`: opaque socket handle (lean_alloc_external)

  ## Design

  Socket and EventLoop are opaque types backed by POSIX file descriptors
  managed via `lean_alloc_external` with automatic cleanup on GC.
  This follows the same pattern as Lean's `IO.FS.Handle`.
-/

namespace Network.Socket

/-- Address family.
    $$\text{Family} = \text{inet} \mid \text{inet6} \mid \text{unixDomain}$$ -/
inductive Family where
  | inet : Family        -- AF_INET (IPv4)
  | inet6 : Family       -- AF_INET6 (IPv6)
  | unixDomain : Family  -- AF_UNIX
deriving BEq, Repr

/-- Encode a Family to the UInt8 tag expected by the C FFI.
    $$\text{Family.toUInt8} : \text{Family} \to \text{UInt8}$$
    - 0 = AF_INET, 1 = AF_INET6, 2 = AF_UNIX -/
def Family.toUInt8 : Family → UInt8
  | .inet => 0
  | .inet6 => 1
  | .unixDomain => 2

/-- Decode a UInt8 tag from the C FFI to a Family. -/
def Family.ofUInt8 : UInt8 → Family
  | 0 => .inet
  | 1 => .inet6
  | 2 => .unixDomain
  | _ => .inet

/-- Socket type.
    $$\text{SocketType} = \text{stream} \mid \text{datagram} \mid \text{raw}$$ -/
inductive SocketType where
  | stream : SocketType    -- SOCK_STREAM (TCP)
  | datagram : SocketType  -- SOCK_DGRAM (UDP)
  | raw : SocketType       -- SOCK_RAW
deriving BEq, Repr

/-- Encode a SocketType to the UInt8 tag expected by the C FFI.
    $$\text{SocketType.toUInt8} : \text{SocketType} \to \text{UInt8}$$
    - 0 = SOCK_STREAM, 1 = SOCK_DGRAM, 2 = SOCK_RAW -/
def SocketType.toUInt8 : SocketType → UInt8
  | .stream => 0
  | .datagram => 1
  | .raw => 2

/-- How to shut down a socket.
    $$\text{ShutdownHow} = \text{read} \mid \text{write} \mid \text{both}$$ -/
inductive ShutdownHow where
  | read : ShutdownHow   -- SHUT_RD
  | write : ShutdownHow  -- SHUT_WR
  | both : ShutdownHow   -- SHUT_RDWR
deriving BEq, Repr

/-- Encode ShutdownHow to the UInt8 expected by the C FFI.
    - 0 = SHUT_RD, 1 = SHUT_WR, 2 = SHUT_RDWR -/
def ShutdownHow.toUInt8 : ShutdownHow → UInt8
  | .read => 0
  | .write => 1
  | .both => 2

/-- Event type flags for event multiplexing.
    $$\text{EventType} = \{ \text{flags} : \text{USize} \}$$

    Bitmask:
    - bit 0 (1) = readable
    - bit 1 (2) = writable
    - bit 2 (4) = error / hangup -/
structure EventType where
  flags : USize
deriving BEq, Repr

namespace EventType

/-- Readable event flag (bit 0). -/
def readable : EventType := ⟨1⟩

/-- Writable event flag (bit 1). -/
def writable : EventType := ⟨2⟩

/-- Error/hangup event flag (bit 2). -/
def error : EventType := ⟨4⟩

/-- Combine event flags. -/
def merge (a b : EventType) : EventType := ⟨a.flags ||| b.flags⟩

instance : OrOp EventType where
  or := merge

/-- Test if a specific flag is set. -/
def hasReadable (e : EventType) : Bool := (e.flags &&& 1) != 0
def hasWritable (e : EventType) : Bool := (e.flags &&& 2) != 0
def hasError (e : EventType) : Bool := (e.flags &&& 4) != 0

end EventType

/-- Opaque event loop handle (kqueue on macOS, epoll on Linux).
    Backed by a POSIX file descriptor managed via `lean_alloc_external`
    with automatic cleanup on GC.

    Following the same pattern as Lean's `IO.FS.Handle`. -/
opaque EventLoopHandle : NonemptyType
def EventLoop : Type := EventLoopHandle.type
instance : Nonempty EventLoop := EventLoopHandle.property

/-- A ready event: which socket fd became ready, and what events fired. -/
structure ReadyEvent where
  socketFd : USize
  events : EventType
deriving Repr

/-- A socket address: host string + port.
    $$\text{SockAddr} = \{ \text{host} : \text{String},\; \text{port} : \text{UInt16} \}$$ -/
structure SockAddr where
  host : String
  port : UInt16
deriving BEq, Repr

instance : ToString SockAddr where
  toString sa := s!"{sa.host}:{sa.port}"

/-- Address info returned by getAddrInfo.
    $$\text{AddrInfo} = \{ \text{family} : \text{Family},\; \text{host} : \text{String},\; \text{port} : \mathbb{N} \}$$ -/
structure AddrInfo where
  family : Family
  host : String
  port : Nat
deriving Repr

/-- Opaque socket handle. Backed by a POSIX file descriptor managed via
    `lean_alloc_external` with automatic cleanup on GC.

    Following the same pattern as Lean's `IO.FS.Handle`. -/
opaque SocketHandle : NonemptyType
def Socket : Type := SocketHandle.type
instance : Nonempty Socket := SocketHandle.property

end Network.Socket
