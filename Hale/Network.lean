/-
  Hale.Network — Haskell `network` for Lean 4

  POSIX socket API via C FFI. Ports the core of Haskell's `network` package.

  ## Modules

  - `Network.Socket.Types` — Core types (Family, SocketType, SockAddr, Socket)
  - `Network.Socket.FFI` — Low-level C FFI bindings
  - `Network.Socket` — High-level safe socket API
  - `Network.Socket.BS` — ByteArray send/recv helpers
  - `Network.Socket.Blocking` — Blocking convenience wrappers
  - `Network.Socket.EventDispatcher` — Event loop ↔ Green monad bridge
-/
import Hale.Network.Network.Socket.Types
import Hale.Network.Network.Socket.FFI
import Hale.Network.Network.Socket
import Hale.Network.Network.Socket.ByteString
import Hale.Network.Network.Socket.Blocking
import Hale.Network.Network.Socket.EventDispatcher
