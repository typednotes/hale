/-
  Network.Wai.Middleware.AddHeaders — Add headers to every response
  @since 3.0.3
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Middleware

open Network.Wai
open Network.HTTP.Types

/-- Add the given headers to all responses.
    $$\text{addHeaders} : \text{ResponseHeaders} \to \text{Middleware}$$ -/
def addHeaders (hdrs : ResponseHeaders) : Middleware :=
  fun app req respond =>
    app req fun resp =>
      respond (resp.mapResponseHeaders (· ++ hdrs))

/-- Adding empty headers preserves response headers for builder responses.
    $$\text{mapResponseHeaders}(\cdot \mathbin{+\!\!+} []) \circ \text{responseBuilder}(s, h, b) = \text{responseBuilder}(s, h, b)$$ -/
theorem addHeaders_nil_builder (s : Status) (h : ResponseHeaders) (b : ByteArray) :
    (Response.responseBuilder s h b).mapResponseHeaders (· ++ ([] : ResponseHeaders))
      = .responseBuilder s h b := by
  simp [Response.mapResponseHeaders, List.append_nil]

/-- Adding empty headers preserves response headers for file responses. -/
theorem addHeaders_nil_file (s : Status) (h : ResponseHeaders) (p : String)
    (fp : Option Network.Sendfile.FilePart) :
    (Response.responseFile s h p fp).mapResponseHeaders (· ++ ([] : ResponseHeaders))
      = .responseFile s h p fp := by
  simp [Response.mapResponseHeaders, List.append_nil]

/-- Adding empty headers preserves response headers for stream responses. -/
theorem addHeaders_nil_stream (s : Status) (h : ResponseHeaders) (b : StreamingBody) :
    (Response.responseStream s h b).mapResponseHeaders (· ++ ([] : ResponseHeaders))
      = .responseStream s h b := by
  simp [Response.mapResponseHeaders, List.append_nil]

end Network.Wai.Middleware
