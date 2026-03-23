# Std project

This library provides functionalities heavily inspired by haskell popular libraries but with a maximalist stance on typing.

## Typing approach

**Mantra: Extensive typing/proving with no compromise on performance.**

We'd like our implementations to explicitly state and prove the guarantees they provide.

Ideally the types give information about
- correctness
- useful properties and invariants
- performance guarantees
- algorithmic complexity
- resource usage

when proofs are feasible.

## Lazy vs Strict Evaluation

Haskell is lazily evaluated while Lean is strictly evaluated. When porting Haskell code, be aware that some idioms rely on laziness (e.g., infinite lists, guarded recursion, lazy fields in data types). Use `Stream` or `Thunk` in Lean to emulate Haskell's lazy behavior when necessary.

## Haskell → Lean Module Mapping

Reference: https://hackage.haskell.org/package/base

| Lean Module | Haskell Module |
|---|---|
| `Hale.Base.Data.Void` | `Data.Void` |
| `Hale.Base.Data.Function` | `Data.Function` |
| `Hale.Base.Data.Newtype` | `Data.Monoid` / `Data.Semigroup` |
| `Hale.Base.Data.Bool` | `Data.Bool` |
| `Hale.Base.Data.Maybe` | `Data.Maybe` |
| `Hale.Base.Data.Char` | `Data.Char` |
| `Hale.Base.Data.String` | `Data.String` |
| `Hale.Base.Data.List` | `Data.List` |
| `Hale.Base.Data.Proxy` | `Data.Proxy` |
| `Hale.Base.Data.Unique` | `Data.Unique` |
| `Hale.Base.Data.IORef` | `Data.IORef` |
| `Hale.Base.Data.Bits` | `Data.Bits` |
| `Hale.Base.Data.Ix` | `Data.Ix` |
| `Hale.Base.Data.Bifunctor` | `Data.Bifunctor` |
| `Hale.Base.Data.Functor.Contravariant` | `Data.Functor.Contravariant` |
| `Hale.Base.Data.Functor.Const` | `Data.Functor.Const` |
| `Hale.Base.Data.Functor.Identity` | `Data.Functor.Identity` |
| `Hale.Base.Data.Functor.Compose` | `Data.Functor.Compose` |
| `Hale.Base.Data.Functor.Product` | `Data.Functor.Product` |
| `Hale.Base.Data.Functor.Sum` | `Data.Functor.Sum` |
| `Hale.Base.Control.Category` | `Control.Category` |
| `Hale.Base.Control.Applicative` | `Control.Applicative` |
| `Hale.Base.Control.Monad` | `Control.Monad` |
| `Hale.Base.Control.Exception` | `Control.Exception` |
| `Hale.Base.Data.List.NonEmpty` | `Data.List.NonEmpty` |
| `Hale.Base.Data.Either` | `Data.Either` |
| `Hale.Base.Data.Ord` | `Data.Ord` |
| `Hale.Base.Data.Tuple` | `Data.Tuple` + `Prelude` |
| `Hale.Base.Data.Foldable` | `Data.Foldable` |
| `Hale.Base.Data.Traversable` | `Data.Traversable` |
| `Hale.Base.Data.Ratio` | `Data.Ratio` |
| `Hale.Base.Data.Complex` | `Data.Complex` |
| `Hale.Base.Data.Fixed` | `Data.Fixed` |
| `Hale.Base.Control.Arrow` | `Control.Arrow` |
| `Hale.Base.Control.Concurrent` | `Control.Concurrent` |
| `Hale.Base.Control.Concurrent.MVar` | `Control.Concurrent.MVar` |
| `Hale.Base.Control.Concurrent.Chan` | `Control.Concurrent.Chan` |
| `Hale.Base.Control.Concurrent.QSem` | `Control.Concurrent.QSem` |
| `Hale.Base.Control.Concurrent.QSemN` | `Control.Concurrent.QSemN` |
| `Hale.Base.System.IO` | `System.IO` |
| `Hale.Base.System.Exit` | `System.Exit` |
| `Hale.Base.System.Environment` | `System.Environment` |

Reference: https://hackage.haskell.org/package/bytestring

| Lean Module | Haskell Module |
|---|---|
| `Hale.ByteString.Data.ByteString.Internal` | `Data.ByteString.Internal` |
| `Hale.ByteString.Data.ByteString` | `Data.ByteString` |
| `Hale.ByteString.Data.ByteString.Char8` | `Data.ByteString.Char8` |
| `Hale.ByteString.Data.ByteString.Short` | `Data.ByteString.Short` |
| `Hale.ByteString.Data.ByteString.Lazy.Internal` | `Data.ByteString.Lazy.Internal` |
| `Hale.ByteString.Data.ByteString.Lazy` | `Data.ByteString.Lazy` |
| `Hale.ByteString.Data.ByteString.Lazy.Char8` | `Data.ByteString.Lazy.Char8` |
| `Hale.ByteString.Data.ByteString.Builder` | `Data.ByteString.Builder` |

Reference: https://hackage.haskell.org/package/time

| Lean Module | Haskell Module |
|---|---|
| `Hale.Time.Data.Time.Clock` | `Data.Time.Clock` |

Reference: https://hackage.haskell.org/package/word8

| Lean Module | Haskell Module |
|---|---|
| `Hale.Word8.Data.Word8` | `Data.Word8` |

Reference: https://hackage.haskell.org/package/case-insensitive

| Lean Module | Haskell Module |
|---|---|
| `Hale.CaseInsensitive.Data.CaseInsensitive` | `Data.CaseInsensitive` |

Reference: https://hackage.haskell.org/package/vault

| Lean Module | Haskell Module |
|---|---|
| `Hale.Vault.Data.Vault` | `Data.Vault.Lazy` |

Reference: https://hackage.haskell.org/package/stm

| Lean Module | Haskell Module |
|---|---|
| `Hale.STM.Control.Monad.STM` | `Control.Monad.STM` |
| `Hale.STM.Control.Concurrent.STM.TVar` | `Control.Concurrent.STM.TVar` |
| `Hale.STM.Control.Concurrent.STM.TMVar` | `Control.Concurrent.STM.TMVar` |
| `Hale.STM.Control.Concurrent.STM.TQueue` | `Control.Concurrent.STM.TQueue` |

Reference: https://hackage.haskell.org/package/auto-update

| Lean Module | Haskell Module |
|---|---|
| `Hale.AutoUpdate.Control.AutoUpdate` | `Control.AutoUpdate` |

Reference: https://hackage.haskell.org/package/unliftio-core

| Lean Module | Haskell Module |
|---|---|
| `Hale.UnliftIO.Control.Monad.IO.Unlift` | `Control.Monad.IO.Unlift` |

Reference: https://hackage.haskell.org/package/network

| Lean Module | Haskell Module |
|---|---|
| `Hale.Network.Network.Socket.Types` | `Network.Socket` (types) |
| `Hale.Network.Network.Socket.FFI` | `Network.Socket` (FFI) |
| `Hale.Network.Network.Socket` | `Network.Socket` |
| `Hale.Network.Network.Socket.ByteString` | `Network.Socket.ByteString` |

Reference: https://hackage.haskell.org/package/iproute

| Lean Module | Haskell Module |
|---|---|
| `Hale.IpRoute.Data.IP` | `Data.IP` |

Reference: https://hackage.haskell.org/package/recv

| Lean Module | Haskell Module |
|---|---|
| `Hale.Recv.Network.Socket.Recv` | `Network.Socket.Recv` |

Reference: https://hackage.haskell.org/package/http-types

| Lean Module | Haskell Module |
|---|---|
| `Hale.HttpTypes.Network.HTTP.Types.Version` | `Network.HTTP.Types.Version` |
| `Hale.HttpTypes.Network.HTTP.Types.Method` | `Network.HTTP.Types.Method` |
| `Hale.HttpTypes.Network.HTTP.Types.Status` | `Network.HTTP.Types.Status` |
| `Hale.HttpTypes.Network.HTTP.Types.Header` | `Network.HTTP.Types.Header` |
| `Hale.HttpTypes.Network.HTTP.Types.URI` | `Network.HTTP.Types.URI` |

Reference: https://hackage.haskell.org/package/http-date

| Lean Module | Haskell Module |
|---|---|
| `Hale.HttpDate.Network.HTTP.Date` | `Network.HTTP.Date` |

Reference: https://hackage.haskell.org/package/bsb-http-chunked

| Lean Module | Haskell Module |
|---|---|
| `Hale.BsbHttpChunked.Network.HTTP.Chunked` | `Network.HTTP.Chunked` |

Reference: https://hackage.haskell.org/package/time-manager

| Lean Module | Haskell Module |
|---|---|
| `Hale.TimeManager.System.TimeManager` | `System.TimeManager` |

Reference: https://hackage.haskell.org/package/streaming-commons

| Lean Module | Haskell Module |
|---|---|
| `Hale.StreamingCommons.Data.Streaming.Network` | `Data.Streaming.Network` |

Reference: https://hackage.haskell.org/package/simple-sendfile

| Lean Module | Haskell Module |
|---|---|
| `Hale.SimpleSendfile.Network.Sendfile` | `Network.Sendfile` |

Reference: https://hackage.haskell.org/package/unix-compat

| Lean Module | Haskell Module |
|---|---|
| `Hale.UnixCompat.System.Posix.Compat` | `System.Posix` |

Reference: https://hackage.haskell.org/package/wai

| Lean Module | Haskell Module |
|---|---|
| `Hale.WAI.Network.Wai.Internal` | `Network.Wai.Internal` |
| `Hale.WAI.Network.Wai` | `Network.Wai` |

Reference: https://hackage.haskell.org/package/http2

| Lean Module | Haskell Module |
|---|---|
| `Hale.Http2.Network.HTTP2.Frame.Types` | `Network.HTTP2.Frame.Types` |
| `Hale.Http2.Network.HTTP2.Frame.Encode` | `Network.HTTP2.Frame.Encode` |
| `Hale.Http2.Network.HTTP2.Frame.Decode` | `Network.HTTP2.Frame.Decode` |
| `Hale.Http2.Network.HTTP2.HPACK.Table` | `Network.HTTP2.HPACK.Table` |
| `Hale.Http2.Network.HTTP2.HPACK.Huffman` | `Network.HTTP2.HPACK.Huffman` |
| `Hale.Http2.Network.HTTP2.HPACK.Encode` | `Network.HTTP2.HPACK.Encode` |
| `Hale.Http2.Network.HTTP2.HPACK.Decode` | `Network.HTTP2.HPACK.Decode` |
| `Hale.Http2.Network.HTTP2.Types` | `Network.HTTP2.Types` |
| `Hale.Http2.Network.HTTP2.Stream` | `Network.HTTP2.Stream` |
| `Hale.Http2.Network.HTTP2.FlowControl` | `Network.HTTP2.FlowControl` |
| `Hale.Http2.Network.HTTP2.Server` | `Network.HTTP2.Server` |

Reference: https://hackage.haskell.org/package/warp

| Lean Module | Haskell Module |
|---|---|
| `Hale.Warp.Network.Wai.Handler.Warp.Settings` | `Network.Wai.Handler.Warp.Settings` |
| `Hale.Warp.Network.Wai.Handler.Warp.Request` | `Network.Wai.Handler.Warp.Request` |
| `Hale.Warp.Network.Wai.Handler.Warp.Response` | `Network.Wai.Handler.Warp.Response` |
| `Hale.Warp.Network.Wai.Handler.Warp.Run` | `Network.Wai.Handler.Warp.Run` |
| `Hale.Warp.Network.Wai.Handler.Warp` | `Network.Wai.Handler.Warp` |

Reference: https://hackage.haskell.org/package/quic

| Lean Module | Haskell Module |
|---|---|
| `Hale.QUIC.Network.QUIC.Types` | `Network.QUIC` (types) |
| `Hale.QUIC.Network.QUIC.Config` | `Network.QUIC` (config) |
| `Hale.QUIC.Network.QUIC.Connection` | `Network.QUIC` (connection) |
| `Hale.QUIC.Network.QUIC.Stream` | `Network.QUIC` (streams) |
| `Hale.QUIC.Network.QUIC.Server` | `Network.QUIC.Server` |
| `Hale.QUIC.Network.QUIC.Client` | `Network.QUIC.Client` |

Reference: https://hackage.haskell.org/package/http3

| Lean Module | Haskell Module |
|---|---|
| `Hale.Http3.Network.HTTP3.Frame` | `Network.HTTP3` (frames) |
| `Hale.Http3.Network.HTTP3.Error` | `Network.HTTP3` (errors) |
| `Hale.Http3.Network.HTTP3.QPACK.Table` | `Network.QPACK` (tables) |
| `Hale.Http3.Network.HTTP3.QPACK.Encode` | `Network.QPACK` (encode) |
| `Hale.Http3.Network.HTTP3.QPACK.Decode` | `Network.QPACK` (decode) |
| `Hale.Http3.Network.HTTP3.Server` | `Network.HTTP3` (server) |

Reference: https://hackage.haskell.org/package/warp-quic

| Lean Module | Haskell Module |
|---|---|
| `Hale.WarpQUIC.Network.Wai.Handler.WarpQUIC` | `Network.Wai.Handler.WarpQUIC` |

Reference: https://hackage.haskell.org/package/warp (internal modules)

| Lean Module | Haskell Module |
|---|---|
| `Hale.Warp.Network.Wai.Handler.Warp.Types` | `Network.Wai.Handler.Warp.Types` |
| `Hale.Warp.Network.Wai.Handler.Warp.Internal` | `Network.Wai.Handler.Warp.Internal` |
| `Hale.Warp.Network.Wai.Handler.Warp.Date` | `Network.Wai.Handler.Warp.Date` |
| `Hale.Warp.Network.Wai.Handler.Warp.Header` | `Network.Wai.Handler.Warp.Header` |
| `Hale.Warp.Network.Wai.Handler.Warp.Buffer` | `Network.Wai.Handler.Warp.Buffer` |
| `Hale.Warp.Network.Wai.Handler.Warp.File` | `Network.Wai.Handler.Warp.File` |
| `Hale.Warp.Network.Wai.Handler.Warp.FdCache` | `Network.Wai.Handler.Warp.FdCache` |
| `Hale.Warp.Network.Wai.Handler.Warp.FileInfoCache` | `Network.Wai.Handler.Warp.FileInfoCache` |
| `Hale.Warp.Network.Wai.Handler.Warp.HTTP1` | `Network.Wai.Handler.Warp.HTTP1` |
| `Hale.Warp.Network.Wai.Handler.Warp.HTTP2` | `Network.Wai.Handler.Warp.HTTP2` |
| `Hale.Warp.Network.Wai.Handler.Warp.HTTP2.Request` | `Network.Wai.Handler.Warp.HTTP2.Request` |
| `Hale.Warp.Network.Wai.Handler.Warp.HTTP2.Response` | `Network.Wai.Handler.Warp.HTTP2.Response` |
| `Hale.Warp.Network.Wai.Handler.Warp.HTTP2.Types` | `Network.Wai.Handler.Warp.HTTP2.Types` |
| `Hale.Warp.Network.Wai.Handler.Warp.Counter` | `Network.Wai.Handler.Warp.Counter` |
| `Hale.Warp.Network.Wai.Handler.Warp.Conduit` | `Network.Wai.Handler.Warp.Conduit` |
| `Hale.Warp.Network.Wai.Handler.Warp.ReadInt` | `Network.Wai.Handler.Warp.ReadInt` |
| `Hale.Warp.Network.Wai.Handler.Warp.PackInt` | `Network.Wai.Handler.Warp.PackInt` |
| `Hale.Warp.Network.Wai.Handler.Warp.RequestHeader` | `Network.Wai.Handler.Warp.RequestHeader` |
| `Hale.Warp.Network.Wai.Handler.Warp.ResponseHeader` | `Network.Wai.Handler.Warp.ResponseHeader` |
| `Hale.Warp.Network.Wai.Handler.Warp.SendFile` | `Network.Wai.Handler.Warp.SendFile` |
| `Hale.Warp.Network.Wai.Handler.Warp.IO` | `Network.Wai.Handler.Warp.IO` |
| `Hale.Warp.Network.Wai.Handler.Warp.HashMap` | `Network.Wai.Handler.Warp.HashMap` |
| `Hale.Warp.Network.Wai.Handler.Warp.WithApplication` | `Network.Wai.Handler.Warp.WithApplication` |

Reference: https://hackage.haskell.org/package/warp-tls

| Lean Module | Haskell Module |
|---|---|
| `Hale.WarpTLS.Network.Wai.Handler.WarpTLS` | `Network.Wai.Handler.WarpTLS` |
| `Hale.WarpTLS.Network.Wai.Handler.WarpTLS.Internal` | `Network.Wai.Handler.WarpTLS.Internal` |

Reference: https://hackage.haskell.org/package/mime-types

| Lean Module | Haskell Module |
|---|---|
| `Hale.MimeTypes.Network.Mime` | `Network.Mime` |

Reference: https://hackage.haskell.org/package/wai-extra

| Lean Module | Haskell Module |
|---|---|
| `Hale.WaiExtra.Network.Wai.Header` | `Network.Wai.Header` |
| `Hale.WaiExtra.Network.Wai.Request` | `Network.Wai.Request` |
| `Hale.WaiExtra.Network.Wai.Parse` | `Network.Wai.Parse` |
| `Hale.WaiExtra.Network.Wai.Test` | `Network.Wai.Test` |
| `Hale.WaiExtra.Network.Wai.Test.Internal` | `Network.Wai.Test.Internal` |
| `Hale.WaiExtra.Network.Wai.UrlMap` | `Network.Wai.UrlMap` |
| `Hale.WaiExtra.Network.Wai.EventSource` | `Network.Wai.EventSource` |
| `Hale.WaiExtra.Network.Wai.EventSource.EventStream` | `Network.Wai.EventSource.EventStream` |
| `Hale.WaiExtra.Network.Wai.Handler.CGI` | `Network.Wai.Handler.CGI` |
| `Hale.WaiExtra.Network.Wai.Handler.SCGI` | `Network.Wai.Handler.SCGI` |
| `Hale.WaiExtra.Network.Wai.Middleware.AcceptOverride` | `Network.Wai.Middleware.AcceptOverride` |
| `Hale.WaiExtra.Network.Wai.Middleware.AddHeaders` | `Network.Wai.Middleware.AddHeaders` |
| `Hale.WaiExtra.Network.Wai.Middleware.Approot` | `Network.Wai.Middleware.Approot` |
| `Hale.WaiExtra.Network.Wai.Middleware.Autohead` | `Network.Wai.Middleware.Autohead` |
| `Hale.WaiExtra.Network.Wai.Middleware.CleanPath` | `Network.Wai.Middleware.CleanPath` |
| `Hale.WaiExtra.Network.Wai.Middleware.CombineHeaders` | `Network.Wai.Middleware.CombineHeaders` |
| `Hale.WaiExtra.Network.Wai.Middleware.ForceDomain` | `Network.Wai.Middleware.ForceDomain` |
| `Hale.WaiExtra.Network.Wai.Middleware.ForceSSL` | `Network.Wai.Middleware.ForceSSL` |
| `Hale.WaiExtra.Network.Wai.Middleware.Gzip` | `Network.Wai.Middleware.Gzip` |
| `Hale.WaiExtra.Network.Wai.Middleware.HealthCheckEndpoint` | `Network.Wai.Middleware.HealthCheckEndpoint` |
| `Hale.WaiExtra.Network.Wai.Middleware.HttpAuth` | `Network.Wai.Middleware.HttpAuth` |
| `Hale.WaiExtra.Network.Wai.Middleware.Jsonp` | `Network.Wai.Middleware.Jsonp` |
| `Hale.WaiExtra.Network.Wai.Middleware.Local` | `Network.Wai.Middleware.Local` |
| `Hale.WaiExtra.Network.Wai.Middleware.MethodOverride` | `Network.Wai.Middleware.MethodOverride` |
| `Hale.WaiExtra.Network.Wai.Middleware.MethodOverridePost` | `Network.Wai.Middleware.MethodOverridePost` |
| `Hale.WaiExtra.Network.Wai.Middleware.RealIp` | `Network.Wai.Middleware.RealIp` |
| `Hale.WaiExtra.Network.Wai.Middleware.RequestLogger` | `Network.Wai.Middleware.RequestLogger` |
| `Hale.WaiExtra.Network.Wai.Middleware.RequestLogger.JSON` | `Network.Wai.Middleware.RequestLogger.JSON` |
| `Hale.WaiExtra.Network.Wai.Middleware.RequestSizeLimit` | `Network.Wai.Middleware.RequestSizeLimit` |
| `Hale.WaiExtra.Network.Wai.Middleware.RequestSizeLimit.Internal` | `Network.Wai.Middleware.RequestSizeLimit.Internal` |
| `Hale.WaiExtra.Network.Wai.Middleware.Rewrite` | `Network.Wai.Middleware.Rewrite` |
| `Hale.WaiExtra.Network.Wai.Middleware.Routed` | `Network.Wai.Middleware.Routed` |
| `Hale.WaiExtra.Network.Wai.Middleware.Select` | `Network.Wai.Middleware.Select` |
| `Hale.WaiExtra.Network.Wai.Middleware.StreamFile` | `Network.Wai.Middleware.StreamFile` |
| `Hale.WaiExtra.Network.Wai.Middleware.StripHeaders` | `Network.Wai.Middleware.StripHeaders` |
| `Hale.WaiExtra.Network.Wai.Middleware.Timeout` | `Network.Wai.Middleware.Timeout` |
| `Hale.WaiExtra.Network.Wai.Middleware.ValidateHeaders` | `Network.Wai.Middleware.ValidateHeaders` |
| `Hale.WaiExtra.Network.Wai.Middleware.Vhost` | `Network.Wai.Middleware.Vhost` |

Reference: https://hackage.haskell.org/package/wai-http2-extra

| Lean Module | Haskell Module |
|---|---|
| `Hale.WaiHttp2Extra.Network.Wai.Middleware.Push.Referer` | `Network.Wai.Middleware.Push.Referer` |
| `Hale.WaiHttp2Extra.Network.Wai.Middleware.Push.Referer.Types` | `Network.Wai.Middleware.Push.Referer` (types) |
| `Hale.WaiHttp2Extra.Network.Wai.Middleware.Push.Referer.LRU` | `Network.Wai.Middleware.Push.Referer` (LRU) |
| `Hale.WaiHttp2Extra.Network.Wai.Middleware.Push.Referer.Manager` | `Network.Wai.Middleware.Push.Referer` (manager) |
| `Hale.WaiHttp2Extra.Network.Wai.Middleware.Push.Referer.ParseURL` | `Network.Wai.Middleware.Push.Referer` (URL parsing) |

Reference: Transitive dependencies (new)

| Lean Module | Haskell Module |
|---|---|
| `Hale.TLS.Network.TLS.Context` | `Network.TLS` (context, via OpenSSL FFI) |
| `Hale.TLS.Network.TLS.Config` | `Network.TLS` (config) |
| `Hale.TLS.Network.TLS.Types` | `Network.TLS` (types) |
| `Hale.DataDefault.Data.Default` | `Data.Default` |
| `Hale.Cookie.Web.Cookie` | `Web.Cookie` |
| `Hale.FastLogger.System.Log.FastLogger` | `System.Log.FastLogger` |
| `Hale.WaiLogger.Network.Wai.Logger` | `Network.Wai.Logger` |
| `Hale.ResourceT.Control.Monad.Trans.Resource` | `Control.Monad.Trans.Resource` |
| `Hale.Base64.Data.ByteString.Base64` | `Data.ByteString.Base64` |
| `Hale.AnsiTerminal.System.Console.ANSI` | `System.Console.ANSI` |
| `Hale.PSQueues.Data.IntPSQ` | `Data.IntPSQ` |

Reference: https://hackage.haskell.org/package/websockets

| Lean Module | Haskell Module |
|---|---|
| `Hale.WebSockets.Network.WebSockets.Types` | `Network.WebSockets` (types) |
| `Hale.WebSockets.Network.WebSockets.Frame` | `Network.WebSockets` (framing) |
| `Hale.WebSockets.Network.WebSockets.Handshake` | `Network.WebSockets` (handshake) |
| `Hale.WebSockets.Network.WebSockets.Connection` | `Network.WebSockets.Connection` |

Reference: https://hackage.haskell.org/package/wai-websockets

| Lean Module | Haskell Module |
|---|---|
| `Hale.WaiWebSockets.Network.Wai.Handler.WebSockets` | `Network.Wai.Handler.WebSockets` |

Reference: https://hackage.haskell.org/package/wai-app-static

| Lean Module | Haskell Module |
|---|---|
| `Hale.WaiAppStatic.WaiAppStatic.Types` | `WaiAppStatic.Types` |
| `Hale.WaiAppStatic.WaiAppStatic.Storage.Filesystem` | `WaiAppStatic.Storage.Filesystem` |
| `Hale.WaiAppStatic.Network.Wai.Application.Static` | `Network.Wai.Application.Static` |

## Folder Organization Policy

The `Hale` project ports multiple Haskell libraries. Each Haskell library gets its own **top-level folder** named after the library (Lean naming convention). Within that folder, the **subfolder path mirrors the Haskell module path** exactly.

```
Hale/
  Base/                                  ← Haskell `base` library
    Data/
      Void.lean                          ← Data.Void
      Function.lean                      ← Data.Function
      Functor/
        Const.lean                       ← Data.Functor.Const
        Identity.lean                    ← Data.Functor.Identity
        Compose.lean                     ← Data.Functor.Compose
        Contravariant.lean               ← Data.Functor.Contravariant
      List/
        NonEmpty.lean                    ← Data.List.NonEmpty
      ...
    Control/
      Category.lean                      ← Control.Category
      Arrow.lean                         ← Control.Arrow
      Concurrent.lean                    ← Control.Concurrent
      Concurrent/
        MVar.lean                        ← Control.Concurrent.MVar
        Chan.lean                        ← Control.Concurrent.Chan
        ...
  Containers/                            ← Haskell `containers` (future)
    Data/
      Map.lean                           ← Data.Map
      Set.lean                           ← Data.Set
      ...
  Text/                                  ← Haskell `text` (future)
    Data/
      Text.lean                          ← Data.Text
      ...
```

**Rules:**
1. **Top-level folder = Haskell library name** in Lean naming convention (`Base` for `base`, `Containers` for `containers`, etc.)
2. **Subfolder path = Haskell module path** exactly (`Data/Functor/Const.lean` for `Data.Functor.Const`)
3. **Namespace = Haskell module path** — namespaces mirror the Haskell hierarchy, NOT the library name. Examples:
   - `Hale/Base/Data/Ratio.lean` → `namespace Data` (outer), `namespace Ratio` (inner for methods)
   - `Hale/Base/Data/Functor/Const.lean` → `namespace Data.Functor` (outer), `namespace Const` (inner)
   - `Hale/Base/Control/Concurrent/MVar.lean` → `namespace Control.Concurrent` (outer), `namespace MVar` (inner)
   - Users write `open Data` or `open Control.Concurrent` to access types, just like Haskell `import Data.Ratio` or `import Control.Concurrent.MVar`
4. **Sub-namespaces for methods** — use `namespace Ratio` within `namespace Data` for dot-notation methods (e.g., `Ratio.floor`)
5. **Re-export file** — each library has a re-export file (`Hale/Base.lean`) that imports all its modules

**Tests** mirror the Haskell module structure: `Tests/Control/TestMVar.lean` for `Control.Concurrent.MVar`.

**Docs** mirror the Haskell module structure: `docs/Control/MVar.md` for `Control.Concurrent.MVar`.

## Module Organization

- **Foundational:** Basic types and combinators — `Void`, `Function`, `Newtype`
- **Core Abstractions:** Functor variants and composition — `Bifunctor`, `Contravariant`, `Const`, `Identity`, `Compose`, `Category`
- **Data Structures:** Concrete data types — `NonEmpty`, `Either`, `Ord`, `Tuple`
- **Traversals:** Fold and traverse abstractions — `Foldable`, `Traversable`
- **Numeric Types:** Exact arithmetic — `Ratio`, `Complex`, `Fixed`
- **Advanced Abstractions:** Arrow computations — `Arrow`
- **Concurrency:** Thread management and synchronisation — `Concurrent`, `MVar`, `Chan`, `QSem`, `QSemN`

## Build & Test

```bash
# Build the library
lake build

# Run smoke tests
lake exe hale

# Build and run the test suite
lake build hale-tests
lake exe hale-tests

# Run Haskell cross-verification (requires GHC)
bash tests/cross-check/run-all.sh
```

## Porting Approach

When porting a Haskell library:

1. **Same API, adapted implementation.** Port the same public API surface. Use the same implementation approach unless Lean's standard library provides a better backing (e.g., `ByteArray`, `HashMap`, `Array`, `IO.FS`) or language differences (lazy vs strict evaluation) make a different implementation more appropriate.
2. **Port the value-add:** Focus on typed invariants, O(1) slicing, algebraic proofs, and API surface that Lean lacks.
3. **Port transitive dependencies first.** If the Haskell library depends on another unported Haskell library, port that dependency before proceeding.
4. **Lean stdlib preference:** When Lean's stdlib already provides equivalent functionality, use it as the backing implementation and provide Haskell-compatible naming on top.
5. **Cross-platform C FFI / glibc wrappers:** When porting libraries that wrap OS/glibc facilities (sockets, file I/O, signals, etc.), get inspiration from **both** Haskell's implementation and **Lean's standard library** (`Init.System`, `Std.Internal`). Use `#ifdef` guards for platform-specific code (macOS/kqueue, Linux/epoll). Target macOS and Linux first; Windows support can be added later. Always return proper `IO.Error` from C FFI — never crash or segfault.
6. **FFI preferred for glibc, implementation preferred otherwise:** C FFI should be the default approach for wrapping glibc/OS system calls (sockets, file descriptors, signals, process management, etc.) — these are inherently C APIs and FFI gives the best fidelity. For everything else (protocol logic, data structures, algorithms, type-level guarantees), prefer a native Lean implementation. This gives us proofs, type safety, and platform independence where it matters most.
7. **Maximalist typing for FFI protocols:** When an FFI-wrapped resource implements a protocol (TCP, QUIC, HTTP/2, etc.), the Lean types should encode the main constraints and guarantees of the protocol. For example: a socket in LISTEN state should have a different type than a connected socket; a QUIC stream ID should carry its directionality (client/server, bidi/uni) in the type; an HTTP/2 stream should encode its lifecycle state. Use opaque types, phantom type parameters, and proof obligations to make protocol violations unrepresentable.
8. **Align with official Lean FFI patterns:** Follow the Lean 4 standard library's C FFI conventions exactly. Reference implementation: [Std.Internal.Async.TCP](https://github.com/leanprover/lean4/blob/8f6411ad576cc0bec3e9a891c60df223da300a71/stage0/stdlib/Std/Internal/Async/TCP.c#L58). Key patterns:
   - Use `lean_alloc_external` with `lean_register_external_class` for opaque OS handles (sockets, file descriptors, event loops) — NOT `lean_box(fd)` / `USize`
   - Register a finalizer that closes the resource on GC (e.g., `close(fd)`)
   - Use `lean_get_external_data` to extract the handle in C functions
   - Declare the Lean type as `opaque FooHandle : NonemptyType` / `def Foo := FooHandle.type`
   - FFI functions take `@& Foo` (borrowed reference) or `Foo` (owned)

## Haskell Cross-Verification

Every ported module must be cross-verified against Haskell's actual behavior:

1. **Haskell reference program:** `Tests/cross-check/haskell/<Module>.hs` — exercises key operations and prints deterministic output.
2. **Lean smoke test:** `Main.lean` (or a dedicated exe) produces identical output lines.
3. **Shell script:** `Tests/cross-check/check-<module>.sh` compares the outputs.
4. **Coverage targets:** construction, basic operations, edge cases (empty input, single element, boundaries), typeclass behavior (Eq, Ord, Monoid), and I/O roundtrips.
5. **Run all:** `bash Tests/cross-check/run-all.sh`

## For Downstream Porters

To port a Haskell library that depends on `base`, depend on `hale` for the base types. The mapping table above shows which Lean module corresponds to each Haskell `base` module.

## Adding Missing Modules or Functions

When porting a Haskell package that depends on `base` or on an already-ported package, you may discover that a module or function is missing from `hale`. In that case, add it directly to the appropriate dependency (`hale` for `base`, or the corresponding ported package) with the same level of rigor:

1. **Maximalist typing:** Encode correctness proofs, invariants, and guarantees in the types (see "Typing approach" above)
2. **Lawful instances:** If adding a typeclass instance, prove the relevant laws (identity, composition, associativity, etc.)
3. **Lean tests:** Add tests in `Tests/<HaskellPath>/Test<Module>.lean` covering construction, operations, instance behavior, and edge cases (e.g., `Tests/Control/TestMVar.lean` for `Control.Concurrent.MVar`)
4. **Documentation:** Add or update the corresponding `docs/<HaskellPath>/<Module>.md` with API mapping, instances, proofs, and examples (e.g., `docs/Control/MVar.md`)
5. **Cross-check (when applicable):** If the function has observable output, add a Haskell cross-verification script in `tests/cross-check/`
6. **Update the mapping table:** Keep the Haskell-to-Lean mapping in this file and in `README.md` up to date

Do not add the missing functionality in the downstream package — always contribute it back to the ported dependency so all downstream consumers benefit.

## Documentation Standards

Every public definition and module must be documented:

1. **Module-level docstring:** Purpose, design rationale, typing guarantees, axiom-dependent properties
2. **Definition-level docstring:** Include LaTeX equations for the type signature (e.g., `$$\text{take} : \text{MVar}\ \alpha \to \text{BaseIO}\ (\text{Task}\ \alpha)$$`)
3. **Docs folder:** Each module gets a corresponding `docs/<HaskellPath>/<Module>.md` with:
   - Haskell-to-Lean API mapping table
   - Instance documentation
   - Proof/invariant documentation
   - Usage examples
   - Performance/scalability notes

## Strict Typing Review

Before finalising any module, review every definition for stricter types:

1. **Return types:** Can the return type carry a proof? (e.g., `{n : Nat // n > 0}` instead of `Nat`)
2. **Arguments:** Can arguments be constrained? (e.g., `(n : Nat) (h : n > 0)` instead of bare `Nat`)
3. **Structures:** Can fields carry invariants? (e.g., state invariants as proof obligations)
4. **Type aliases:** Do they encode meaningful guarantees? (e.g., `Concurrent α := BaseIO (Task α)` encodes non-blocking)

When proofs are infeasible due to opaque runtime primitives (e.g., `Std.Mutex`, `IO.Promise`), document the invariant as an axiom-dependent property.

## Proofs on Objects, Not Wrapper Types

**Principle:** Proofs and invariants must be added directly to the original type, not by creating a new wrapper type that carries the original plus a proof. Lean 4 erases proof terms at compile time, so proof fields on structures are zero-cost.

**Good (proof ON the object):**
```lean
structure Settings where
  settingsTimeout : Nat := 30
  timeout_pos : settingsTimeout > 0 := by omega   -- proof field, erased at runtime
```

```lean
structure Socket (state : SocketState) where        -- phantom param on original type
  raw : RawSocket
```

**Bad (wrapper carrying proof ABOUT another object):**
```lean
-- DON'T: creates a separate type just to pair an object with a proof
structure ValidSettings where
  settings : Settings
  timeout_pos : settings.settingsTimeout > 0
```

**Rationale:**
- Wrapper types obscure invariants by placing them outside the primary type
- They force users to unwrap (`.settings`, `.headers`) to access the data
- They duplicate the type surface (users must choose between `Settings` and `ValidSettings`)
- Proofs embedded directly in the structure are guaranteed by construction — no separate validation step
- This matches the established pattern in `Ratio` (`den_pos`, `coprime` are fields) and `Socket` (`SocketState` is a phantom parameter)

**When the original type is opaque or external:** use phantom type parameters (e.g., `Socket (state : SocketState)`) or standalone theorems about the type (e.g., `theorem status200_valid`). Never wrap it.

## Code Simplification Review

Before finalising any module, review for simplification:

1. **Factor common patterns:** If two functions share >50% of their logic, extract a shared helper
2. **Avoid redundant state copies:** Use `modify` over `get`/`set` when the entire state changes
3. **Prefer `Std.Mutex.atomically` with direct state operations** over manual lock/unlock
4. **Minimise `sorry` and `panic!`:** Every `sorry` must have a tracking comment; every `panic!` must be unreachable by construction

## Standard Test Porting Procedure

### Port upstream Haskell tests

Every ported module must also port the corresponding Haskell test suite. The upstream tests are the primary source of test coverage — they define what behavior the port must match. Ported Haskell tests become part of the validation harness and must pass during generation.

### Proofs over tests

When porting a Haskell test, always ask: **can this test be expressed as a proof embedded in the types?** A type-checking theorem is strictly stronger than a runtime test — it holds for all inputs, not just the tested ones, and never needs to be run.

**Preference hierarchy:**
1. **Proof in source** (theorem in the module) — strongest, covers all cases, verified at compile time
2. **Runtime test in `Tests/`** — for IO, opaque primitives, or properties that are infeasible to prove
3. **`sorry`-marked theorem** with tracking comment — for invariants that should be provable but aren't yet

**Examples of tests that become proofs:**
- "map id = id" → `theorem map_id (x : F α) : id <$> x = x := rfl`
- "pure a >>= f = f a" → `theorem pure_bind ...`
- "conjugate (conjugate z) = z" → `theorem conjugate_conjugate ...`
- "partition preserves length" → `theorem partitionEithers_length ...`

**Tests that stay as tests:**
- IO roundtrips (write then read back)
- Opaque ByteArray operations
- Concrete numeric edge cases (overflow, rounding)
- Thunk/lazy evaluation behavior

### Coverage rule

Every public `def`, `instance`, `structure`, `class`, or `theorem` must be covered by either a proof or a runtime test.

**Coverage table:**

| Category | Required |
|---|---|
| Typeclass instance | All laws (identity, composition, associativity) — prefer as proofs |
| Algebraic operation | Identity, commutativity, associativity, inverse — prefer as proofs |
| Constructor | Construction + accessor roundtrip |
| Conversion | Roundtrip identity (`pack`/`unpack`, `toStrict`/`fromStrict`) — prove when possible |
| Predicate | True case, false case, empty-input edge case |
| Fold/traversal | Empty, singleton, multi-element |

**Coverage header comment** required in each test file listing:
- Proofs in source (covered by type-checking)
- Tested here (runtime tests)
- Not yet covered (tracking gaps)

**`proofCovered` helper:** Use `proofCovered` in `Tests/Harness.lean` to record proof-based coverage in test output — a theorem in source always passes, but appears in the report.