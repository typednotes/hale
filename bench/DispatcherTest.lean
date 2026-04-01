import Hale.Network
import Hale.Base.Control.Concurrent
import Hale.Base.Control.Concurrent.Green

open Network.Socket
open Control.Concurrent.Green

def main : IO Unit := do
  IO.println "Step 1: Create server"
  let sock ← Network.Socket.socket .inet .stream
  setReuseAddr sock
  let sock ← Network.Socket.bind sock ⟨"127.0.0.1", 9877⟩
  let sock ← Network.Socket.listen sock 128
  setNonBlocking sock

  IO.println "Step 2: Create EventDispatcher"
  let disp ← EventDispatcher.create

  IO.println "Step 3: Spawn client"
  let _ ← Control.Concurrent.forkIO do
    IO.sleep 300
    let csock ← Network.Socket.socket .inet .stream
    FFI.socketConnect csock.raw "127.0.0.1" 9877
    IO.println "  client: connected"
    let _ ← Network.Socket.close csock

  IO.println "Step 4: Green.block with waitReadable + accept"
  let token ← Std.CancellationToken.new
  Green.block (do
    IO.println "  green: waiting for readable..."
    disp.waitReadable sock
    IO.println "  green: readable! accepting..."
    let outcome ← (Network.Socket.accept sock : IO _)
    match outcome with
    | .accepted clientSock addr =>
      IO.println s!"  green: accepted from {addr}"
      let _ ← (Network.Socket.close clientSock : IO _)
    | .wouldBlock =>
      IO.println "  green: wouldBlock"
    | .error e =>
      IO.println s!"  green: error: {e}"
    : Green Unit) token

  IO.println "Step 5: Shutdown"
  disp.shutdown
  let _ ← Network.Socket.close sock
  IO.println "All done!"
