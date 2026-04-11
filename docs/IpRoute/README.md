# IpRoute -- IP Address Types

**Lean:** `Hale.IpRoute` | **Haskell:** `iproute`

IP addresses (IPv4, IPv6) and CIDR ranges with decidable membership predicate.

## Key Types

| Type | Description |
|------|-------------|
| `IPv4` | 32-bit address |
| `IPv6` | Pair of UInt64 |
| `AddrRange` | CIDR range with prefix length |

## API

| Function | Signature |
|----------|-----------|
| `ofOctets` | `(UInt8, UInt8, UInt8, UInt8) → IPv4` |
| `toOctets` | `IPv4 → (UInt8, UInt8, UInt8, UInt8)` |
| `isMatchedTo` | Decidable CIDR membership |

## Files
- `Hale/IpRoute/Data/IP.lean` -- IPv4, IPv6, CIDR ranges
