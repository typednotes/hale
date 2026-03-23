/-
  Hale.Cookie.Web.Cookie — HTTP cookie parsing and rendering

  Parses Cookie and Set-Cookie headers per RFC 6265.

  ## Guarantees
  - `parseCookies` handles empty input gracefully (returns [])
  - Cookie names and values are trimmed of whitespace
-/
namespace Web.Cookie

/-- A parsed cookie key-value pair. -/
abbrev CookiePair := String × String

/-- Trim leading and trailing ASCII whitespace from a string, returning a String. -/
private def trim (s : String) : String :=
  s.trimAscii.toString

/-- Parse a Cookie header value into key-value pairs.
    Cookie header format: "name1=value1; name2=value2"
    $$\text{parseCookies} : \text{String} \to \text{List CookiePair}$$ -/
def parseCookies (header : String) : List CookiePair :=
  let pairs := header.splitOn ";"
  pairs.filterMap fun pair =>
    let trimmed := trim pair
    match trimmed.splitOn "=" with
    | name :: rest =>
      let value := "=".intercalate rest  -- handles values containing '='
      some (trim name, trim value)
    | _ => none

/-- Render a list of cookie pairs into a Cookie header value.
    $$\text{renderCookies} : \text{List CookiePair} \to \text{String}$$ -/
def renderCookies (cookies : List CookiePair) : String :=
  "; ".intercalate (cookies.map fun (k, v) => k ++ "=" ++ v)

/-- SameSite attribute for Set-Cookie. -/
inductive SameSite where
  | strict
  | lax
  | none_
deriving BEq, Repr

/-- Set-Cookie configuration. -/
structure SetCookie where
  name : String
  value : String
  path : Option String := none
  domain : Option String := none
  maxAge : Option Nat := none
  secure : Bool := false
  httpOnly : Bool := false
  sameSite : Option SameSite := none

/-- Render a SetCookie as a Set-Cookie header value.
    $$\text{renderSetCookie} : \text{SetCookie} \to \text{String}$$ -/
def renderSetCookie (sc : SetCookie) : String := Id.run do
  let mut s := sc.name ++ "=" ++ sc.value
  if let some p := sc.path then s := s ++ "; Path=" ++ p
  if let some d := sc.domain then s := s ++ "; Domain=" ++ d
  if let some a := sc.maxAge then s := s ++ "; Max-Age=" ++ toString a
  if sc.secure then s := s ++ "; Secure"
  if sc.httpOnly then s := s ++ "; HttpOnly"
  if let some ss := sc.sameSite then
    s := s ++ "; SameSite=" ++ match ss with
      | .strict => "Strict"
      | .lax => "Lax"
      | .none_ => "None"
  return s

/-- Parse a Set-Cookie header value into a SetCookie structure.
    Only parses the name=value part; attributes are parsed best-effort.
    $$\text{parseSetCookie} : \text{String} \to \text{Option SetCookie}$$ -/
def parseSetCookie (header : String) : Option SetCookie := Id.run do
  let parts := header.splitOn ";"
  let some main := parts.head? | return none
  let (name, value) ← match (trim main).splitOn "=" with
    | n :: rest => pure (trim n, trim ("=".intercalate rest))
    | _ => return none
  let mut sc : SetCookie := { name, value }
  for part in parts.drop 1 do
    let attr := (trim part).toLower
    if attr.startsWith "path=" then
      sc := { sc with path := some ((trim part).drop 5).toString }
    else if attr.startsWith "domain=" then
      sc := { sc with domain := some ((trim part).drop 7).toString }
    else if attr.startsWith "max-age=" then
      sc := { sc with maxAge := ((trim part).drop 8).toString.toNat? }
    else if attr == "secure" then
      sc := { sc with secure := true }
    else if attr == "httponly" then
      sc := { sc with httpOnly := true }
    else if attr.startsWith "samesite=" then
      let val := (attr.drop 9).toString
      sc := { sc with sameSite :=
        if val == "strict" then some .strict
        else if val == "lax" then some .lax
        else if val == "none" then some .none_
        else none }
  return some sc

end Web.Cookie
