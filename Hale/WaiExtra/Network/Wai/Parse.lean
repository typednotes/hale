/-
  Network.Wai.Parse — Request body parsing

  Parses URL-encoded and multipart form data from request bodies.
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai.Parse

open Network.Wai
open Network.HTTP.Types

/-- A parsed form parameter (name, value). -/
abbrev Param := String × String

/-- A parsed file upload. -/
structure FileInfo where
  fileName : String
  fileContentType : String
  fileContent : ByteArray

/-- Backend for handling file uploads. -/
inductive BackEnd where
  | lbs     -- Store in memory as ByteArray
  | tempFile (dir : String)  -- Write to temp files

/-- Parse URL-encoded form body (application/x-www-form-urlencoded).
    $$\text{parseUrlEncoded} : \text{String} \to \text{List Param}$$ -/
def parseUrlEncoded (body : String) : List Param :=
  let pairs := body.splitOn "&"
  pairs.filterMap fun pair =>
    match pair.splitOn "=" with
    | [k, v] => some (urlDecode k, urlDecode v)
    | [k] => some (urlDecode k, "")
    | _ => none
where
  urlDecode (s : String) : String :=
    -- Simple percent-decoding: replace '+' with space, decode %XX
    let s := s.map fun c => if c == '+' then ' ' else c
    -- TODO: full percent-decoding
    s

/-- Parse request body parameters.
    For URL-encoded bodies, parses directly.
    Returns (params, files).
    $$\text{parseRequestBody} : \text{Request} \to \text{IO (List Param × List (String × FileInfo))}$$ -/
def parseRequestBody (req : Request) : IO (List Param × List (String × FileInfo)) := do
  let body ← Network.Wai.getRequestBodyChunk req
  let bodyStr := String.fromUTF8! body
  let ct := req.requestHeaders.find? (fun (n, _) => n == hContentType) |>.map (·.2)
  match ct with
  | some ct' =>
    if ct'.startsWith "application/x-www-form-urlencoded" then
      return (parseUrlEncoded bodyStr, [])
    else if ct'.startsWith "multipart/form-data" then
      -- TODO: full multipart parsing
      return ([], [])
    else
      return ([], [])
  | none => return ([], [])

end Network.Wai.Parse
