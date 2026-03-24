import Hale
import Tests.Harness

open Network.Socket Tests

/-
  Coverage:
  - Proofs: SocketState distinctness (in Types.lean), BEq reflexivity (in Types.lean)
  - Tested: socket creation, bind, listen, connect, accept, send, recv, close (loopback)
  - Not covered: IPv6, UDP, getAddrInfo, non-blocking mode
-/

namespace TestSocket

def tests : IO (List TestResult) := do
  -- Test 1: Socket creation and socket options (fresh state)
  let s1 ← socket .inet .stream
  setReuseAddr s1
  let _ ← close s1

  -- Test 2: Bind + listen + close (state transitions: fresh → bound → listening)
  let s2 ← socket .inet .stream
  setReuseAddr s2
  let s2 ← bind s2 ⟨"127.0.0.1", 9877⟩
  let s2 ← listen s2 5
  let _ ← close s2

  -- Test 3: Full loopback exchange (state machine: fresh→bound→listening, fresh→connected)
  let server ← socket .inet .stream
  setReuseAddr server
  let server ← bind server ⟨"127.0.0.1", 9876⟩
  let server ← listen server 5

  -- Spawn client in background task
  let clientTask ← IO.asTask (prio := .dedicated) do
    let client ← socket .inet .stream
    let client ← connect client ⟨"127.0.0.1", 9876⟩
    let _ ← Network.Socket.send client "hello".toUTF8
    let response ← Network.Socket.recv client 1024
    let _ ← close client
    pure (String.fromUTF8! response)

  -- Accept on server side (returns Socket .connected)
  let (conn, _remoteAddr) ← accept server
  let data ← Network.Socket.recv conn 1024
  let received := String.fromUTF8! data
  let _ ← Network.Socket.send conn "world".toUTF8
  let _ ← close conn
  let _ ← close server

  let clientResponse ← IO.ofExcept clientTask.get

  pure [
    check "socket options" true
  , check "bind+listen+close" true
  , checkEq "server received" "hello" received
  , checkEq "client received" "world" clientResponse
  ]

end TestSocket
