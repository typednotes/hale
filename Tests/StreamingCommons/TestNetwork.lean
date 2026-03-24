import Hale
import Tests.Harness

open Data.Streaming.Network Tests

/-
  Coverage:
  - Proofs: None (IO + FFI)
  - Tested: bindPortTCP, getSocketTCP, mkAppData, acceptSafe
  - Not covered: runTCPServer (long-running)
-/

namespace TestStreamingNetwork

def tests : IO (List TestResult) := do
  -- Basic: bind a port, connect, exchange data
  let server ← bindPortTCP 9877 "127.0.0.1"
  let clientTask ← IO.asTask (prio := .dedicated) do
    let (sock, _) ← getSocketTCP "127.0.0.1" 9877
    let _ ← Network.Socket.send sock "ping".toUTF8
    let resp ← Network.Socket.recv sock 1024
    let _ ← Network.Socket.close sock
    pure (String.fromUTF8! resp)
  let (clientSock, addr) ← acceptSafe server
  let appData := mkAppData clientSock addr
  let data ← appData.appRead
  let received := String.fromUTF8! data
  appData.appWrite "pong".toUTF8
  IO.sleep 50
  appData.appClose
  let _ ← Network.Socket.close server
  let clientResp ← IO.ofExcept clientTask.get
  pure [
    checkEq "streaming recv" "ping" received
  , checkEq "streaming send" "pong" clientResp
  ]

end TestStreamingNetwork
