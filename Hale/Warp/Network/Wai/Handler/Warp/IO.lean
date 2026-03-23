/-
  Hale.Warp.Network.Wai.Handler.Warp.IO — Low-level I/O helpers

  Provides the core `toBufIOWith` function that renders a ByteArray through
  a write buffer, managing buffer allocation and flushing.
-/
import Hale.Warp.Network.Wai.Handler.Warp.Types

namespace Network.Wai.Handler.Warp

/-- Send a ByteArray through the connection, using the write buffer for
    small payloads and direct sending for large ones.
    $$\text{connSendByteArray} : \text{Connection} \to \text{ByteArray} \to \text{IO Unit}$$ -/
@[inline] def connSendByteArray (conn : Connection) (bs : ByteArray) : IO Unit :=
  conn.connSendAll bs

/-- Send multiple ByteArrays through the connection.
    Concatenates small chunks for efficiency.
    $$\text{connSendByteArrays} : \text{Connection} \to \text{List ByteArray} \to \text{IO Unit}$$ -/
def connSendByteArrays (conn : Connection) (chunks : List ByteArray) : IO Unit :=
  conn.connSendMany chunks

end Network.Wai.Handler.Warp
