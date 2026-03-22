/-
  Hale.Network.Network.Socket.ByteString — ByteArray send/recv helpers

  Convenience wrappers for sending and receiving ByteArrays over sockets.
  Provides `sendAll` which loops until all bytes are sent.
  Also provides `sendTo` / `recvFrom` for UDP datagrams.
-/

import Hale.Network.Network.Socket

namespace Network.Socket.BS

open Network.Socket

/-- Send all bytes from a ByteArray on the socket.
    Loops until all data is sent or the connection closes.
    $$\text{sendAll} : \text{Socket} \to \text{ByteArray} \to \text{IO}(\text{Unit})$$ -/
def sendAll (s : Socket) (data : ByteArray) : IO Unit := do
  let mut sent := 0
  while sent < data.size do
    let slice := data.extract sent data.size
    let n ← Network.Socket.send s slice
    if n == 0 then
      throw (IO.userError "connection closed")
    sent := sent + n

/-- Receive up to `maxlen` bytes as a ByteArray.
    $$\text{recv} : \text{Socket} \to \mathbb{N} \to \text{IO}(\text{ByteArray})$$ -/
def recv (s : Socket) (maxlen : Nat := 4096) : IO ByteArray :=
  Network.Socket.recv s maxlen

/-- Send a UDP datagram to a specific host and port.
    Returns the number of bytes sent.
    $$\text{sendTo} : \text{Socket} \to \text{ByteArray} \to \text{SockAddr} \to \text{IO}(\mathbb{N})$$ -/
def sendTo (s : Socket) (data : ByteArray) (addr : SockAddr) : IO Nat := do
  let n ← FFI.socketSendTo s data addr.host addr.port
  pure n.toNat

/-- Receive a UDP datagram with sender address.
    Returns the data and the sender's address.
    $$\text{recvFrom} : \text{Socket} \to \mathbb{N} \to \text{IO}(\text{ByteArray} \times \text{SockAddr})$$ -/
def recvFrom (s : Socket) (maxlen : Nat := 4096) : IO (ByteArray × SockAddr) := do
  let (data, host, port) ← FFI.socketRecvFrom s maxlen.toUSize
  pure (data, ⟨host, port.toNat.toUInt16⟩)

end Network.Socket.BS
