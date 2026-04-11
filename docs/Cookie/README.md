# Cookie -- HTTP Cookie Parsing

**Lean:** `Hale.Cookie` | **Haskell:** `cookie`

Parse Cookie and Set-Cookie headers per RFC 6265.

## Key Types

| Type | Description |
|------|-------------|
| `CookiePair` | `String × String` (name, value) |

## API

| Function | Signature |
|----------|-----------|
| `parseCookies` | `String → List CookiePair` |

## Files
- `Hale/Cookie/Web/Cookie.lean` -- CookiePair, parseCookies
