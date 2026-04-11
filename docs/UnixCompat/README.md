# UnixCompat -- POSIX Compatibility

**Lean:** `Hale.UnixCompat` | **Haskell:** `unix-compat`

Subset of POSIX operations needed by Warp: file descriptor operations and close-on-exec.

## Key Types

| Type | Description |
|------|-------------|
| `Fd` | File descriptor (`UInt32`) |
| `FileStatus` | File size and type |

## API

| Function | Description |
|----------|-------------|
| `closeFd` | Close a file descriptor |

## Files
- `Hale/UnixCompat/System/Posix/Compat.lean` -- Fd, FileStatus, closeFd
