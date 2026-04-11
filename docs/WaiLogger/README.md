# WaiLogger -- WAI Request Logging

**Lean:** `Hale.WaiLogger` | **Haskell:** `wai-logger`

Formats HTTP request/response data in Apache Combined Log Format: `host - - [date] "method path version" status size`.

## API

| Function | Signature |
|----------|-----------|
| `apacheFormat` | `Request → Status → Option Nat → String` |

## Files
- `Hale/WaiLogger/Network/Wai/Logger.lean` -- apacheFormat
