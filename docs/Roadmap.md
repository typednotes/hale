# Roadmap

## Completed

- Base library (40+ modules)
- ByteString (strict, lazy, builder, short)
- Networking (POSIX sockets, TLS, QUIC)
- HTTP stack (HTTP/1.x, HTTP/2, HTTP/3)
- WAI ecosystem (Warp, WarpTLS, WarpQUIC, middleware, static files, WebSockets)
- glibc wrappers (sockets, sendfile, POSIX compat)

## Not yet ported

Essential libraries:
- containers (Data.Map, Data.Set, Data.IntMap, Data.Sequence)
- text (Data.Text)
- transformers (Control.Monad.Trans)
- vector (Data.Vector)
- binary (Data.Binary)
- directory (System.Directory)
- filepath (System.FilePath)
- unordered-containers (Data.HashMap, Data.HashSet)

Web development:
- aeson (JSON)
- servant (type-level web API)

Other:
- lens
- attoparsec
- criterion
- deepseq
- async
