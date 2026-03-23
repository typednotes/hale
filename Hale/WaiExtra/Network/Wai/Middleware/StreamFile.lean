/-
  Network.Wai.Middleware.StreamFile — Convert file responses to streaming

  Converts ResponseFile type responses into ResponseStream type,
  useful when the server doesn't support sendfile(2).
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai

/-- Convert file responses to streaming responses by reading the file content.
    $$\text{streamFile} : \text{Middleware}$$ -/
def streamFile : Middleware :=
  fun app req respond =>
    app req fun resp =>
      match resp with
      | .responseFile status headers path _part =>
        respond (.responseStream status headers fun send flush => do
          let content ← IO.FS.readBinFile path
          send content
          flush)
      | other => respond other

end Network.Wai.Middleware
