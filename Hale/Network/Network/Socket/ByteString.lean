/-
  Hale.Network.Network.Socket.ByteString — ByteArray send/recv helpers

  Convenience wrappers for sending and receiving ByteArrays over sockets.
  Provides `sendAll` which loops until all bytes are sent.
  Also provides `sendTo` / `recvFrom` for UDP datagrams.

  All functions require a connected socket (`Socket .connected`).
-/

import Hale.Network.Network.Socket

namespace Network.Socket.BS

open Network.Socket

/-- Send all bytes from a ByteArray on a connected socket.
    Loops until all data is sent or the connection closes.
    Implemented in C FFI for reliability.
    $$\text{sendAll} : \text{Socket}\ \texttt{.connected} \to \text{ByteArray} \to \text{IO}(\text{Unit})$$ -/
@[inline] def sendAll (s : Socket .connected) (data : ByteArray) : IO Unit :=
  FFI.socketSendAll s.raw data

/-- Receive up to `maxlen` bytes as a ByteArray from a connected socket.
    Blocking wrapper: loops on wouldBlock, returns empty on EOF.
    $$\text{recv} : \text{Socket}\ \texttt{.connected} \to \mathbb{N} \to \text{IO}(\text{ByteArray})$$ -/
partial def recv (s : Socket .connected) (maxlen : Nat := 4096) : IO ByteArray := do
  match ← Network.Socket.recv s maxlen with
  | .data bytes => pure bytes
  | .wouldBlock => recv s maxlen
  | .eof => pure ByteArray.empty
  | .error e => throw e

/-- Send a UDP datagram to a specific host and port on a connected socket.
    Returns the number of bytes sent.
    $$\text{sendTo} : \text{Socket}\ \texttt{.connected} \to \text{ByteArray} \to \text{SockAddr} \to \text{IO}(\mathbb{N})$$ -/
def sendTo (s : Socket .connected) (data : ByteArray) (addr : SockAddr) : IO Nat := do
  let n ← FFI.socketSendTo s.raw data addr.host addr.port
  pure n.toNat

/-- Receive a UDP datagram with sender address on a connected socket.
    Returns the data and the sender's address.
    $$\text{recvFrom} : \text{Socket}\ \texttt{.connected} \to \mathbb{N} \to \text{IO}(\text{ByteArray} \times \text{SockAddr})$$ -/
def recvFrom (s : Socket .connected) (maxlen : Nat := 4096) : IO (ByteArray × SockAddr) := do
  let (data, host, port) ← FFI.socketRecvFrom s.raw maxlen.toUSize
  pure (data, ⟨host, port.toNat.toUInt16⟩)

end Network.Socket.BS
