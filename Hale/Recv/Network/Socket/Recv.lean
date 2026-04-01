/-
  Hale.Recv.Network.Socket.Recv — Socket recv returning ByteArray

  Thin wrapper around Network.Socket.recv matching Haskell's `recv` package API.
  Requires a connected socket (`Socket .connected`).
-/

import Hale.Network

namespace Network.Socket.Recv

open Network.Socket

/-- Receive up to `maxlen` bytes from a connected socket. Returns empty ByteArray on EOF.
    Uses the blocking wrapper that loops on `wouldBlock`.
    $$\text{recv} : \text{Socket}\ \texttt{.connected} \to \mathbb{N} \to \text{IO}(\text{ByteArray})$$ -/
@[inline] def recv (sock : Socket .connected) (maxlen : Nat := 4096) : IO ByteArray :=
  Network.Socket.Blocking.recv sock maxlen

/-- Receive data as a String (UTF-8 decoded) from a connected socket. -/
@[inline] def recvString (sock : Socket .connected) (maxlen : Nat := 4096) : IO String := do
  let data ← recv sock maxlen
  pure (String.fromUTF8! data)

end Network.Socket.Recv
