# HttpDate -- HTTP Date Parsing

**Lean:** `Hale.HttpDate` | **Haskell:** `http-date`

HTTP date parsing and formatting per RFC 7231. Supports IMF-fixdate, RFC 850, and asctime formats. Fields carry bounded proofs (month 1-12, day 1-31, hour 0-23, etc.).

## Key Types

```lean
structure HTTPDate where
  year   : Nat
  month  : Nat  -- 1-12
  day    : Nat  -- 1-31
  hour   : Nat  -- 0-23
  minute : Nat  -- 0-59
  second : Nat  -- 0-60 (leap second)
```

## Files
- `Hale/HttpDate/Network/HTTP/Date.lean` -- HTTPDate type, parser, formatter
