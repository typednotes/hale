/-
  Hale.Network.Network.Socket.Blocking — Blocking convenience wrappers

  Thin wrappers around the non-blocking socket API that loop on `wouldBlock`
  and present the old blocking-style signatures. Intended for tests, scripts,
  and code that doesn't need event-loop integration.

  These functions call the underlying non-blocking FFI and simply retry on
  EAGAIN. They are suitable for sockets that are still in blocking mode
  (the default after `socket()`), where EAGAIN should never actually occur,
  but they also work correctly on non-blocking sockets (they'll spin-wait,
  which is inefficient — use the EventDispatcher for production non-blocking I/O).
-/

import Hale.Network.Network.Socket

namespace Network.Socket.Blocking

open Network.Socket

/-- Blocking accept: loops until a connection is accepted or an error occurs.
    $$\text{accept} : \text{Socket .listening} \to \text{IO}(\text{Socket .connected} \times \text{SockAddr})$$ -/
partial def accept (s : Socket .listening) : IO (Socket .connected × SockAddr) := do
  match ← Network.Socket.accept s with
  | .accepted sock addr => pure (sock, addr)
  | .wouldBlock => accept s
  | .error e => throw e

private partial def connectFinishLoop (s : Socket .connecting) : IO (Socket .connected) := do
  match ← Network.Socket.connectFinish s with
  | .connected sock => pure sock
  | .inProgress sock => connectFinishLoop sock
  | .refused e => throw e

/-- Blocking connect: loops until connected or an error occurs.
    $$\text{connect} : \text{Socket .fresh} \to \text{SockAddr} \to \text{IO}(\text{Socket .connected})$$ -/
partial def connect (s : Socket .fresh) (addr : SockAddr) : IO (Socket .connected) := do
  match ← Network.Socket.connect s addr with
  | .connected sock => pure sock
  | .inProgress sock => connectFinishLoop sock
  | .refused e => throw e

/-- Blocking send: returns bytes sent, throws on error.
    $$\text{send} : \text{Socket .connected} \to \text{ByteArray} \to \text{IO Nat}$$ -/
partial def send (s : Socket .connected) (data : ByteArray) : IO Nat := do
  match ← Network.Socket.send s data with
  | .sent n => pure n
  | .wouldBlock => send s data
  | .error e => throw e

/-- Blocking sendAll: sends all bytes, looping on partial writes and wouldBlock.
    $$\text{sendAll} : \text{Socket .connected} \to \text{ByteArray} \to \text{IO Unit}$$ -/
partial def sendAll (s : Socket .connected) (data : ByteArray) : IO Unit := do
  let mut offset := 0
  while offset < data.size do
    match ← Network.Socket.send s (data.extract offset data.size) with
    | .sent n => offset := offset + n
    | .wouldBlock => pure ()
    | .error e => throw e

/-- Blocking recv: returns received bytes, throws on error, returns empty on EOF.
    $$\text{recv} : \text{Socket .connected} \to \text{Nat} \to \text{IO ByteArray}$$ -/
partial def recv (s : Socket .connected) (maxlen : Nat := 4096) : IO ByteArray := do
  match ← Network.Socket.recv s maxlen with
  | .data bytes => pure bytes
  | .wouldBlock => recv s maxlen
  | .eof => pure ByteArray.empty
  | .error e => throw e

end Network.Socket.Blocking
