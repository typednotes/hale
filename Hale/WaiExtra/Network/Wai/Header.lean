/-
  Network.Wai.Header — Header parsing utilities for WAI
-/
import Hale.WAI
import Hale.HttpTypes

namespace Network.Wai

open Network.HTTP.Types

/-- Extract the Content-Length header value as a Nat. -/
def contentLength (req : Request) : Option Nat :=
  match req.requestHeaders.find? (fun (n, _) => n == hContentLength) with
  | some (_, v) => v.toNat?
  | none => none

/-- Check if the request has a content type that matches. -/
def hasContentType (ct : String) (req : Request) : Bool :=
  match req.requestHeaders.find? (fun (n, _) => n == hContentType) with
  | some (_, v) => v.startsWith ct
  | none => false

end Network.Wai
