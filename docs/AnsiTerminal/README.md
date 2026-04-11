# AnsiTerminal -- Terminal ANSI Codes

**Lean:** `Hale.AnsiTerminal` | **Haskell:** `ansi-terminal`

ANSI terminal escape codes for colored output.

## Key Types

| Type | Description |
|------|-------------|
| `Color` | `black \| red \| green \| yellow \| blue \| magenta \| cyan \| white` |
| `Intensity` | `bold \| normal` |

## API

| Function | Description |
|----------|-------------|
| `reset` | Reset all attributes |
| `setFg` | Set foreground color |
| `setBg` | Set background color |

## Files
- `Hale/AnsiTerminal/System/Console/ANSI.lean` -- Color, Intensity, escape code helpers
