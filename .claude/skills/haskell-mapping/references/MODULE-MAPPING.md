# Haskell to Lean Module Mapping Tables

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

Reference: https://hackage.haskell.org/package/http-client (adapted implementation)

| Lean Module | Haskell Module |
|---|---|
| `Hale.HttpClient.Network.HTTP.Client.Types` | `Network.HTTP.Client` (types) |
| `Hale.HttpClient.Network.HTTP.Client.Connection` | `Network.HTTP.Client` (connection) |
| `Hale.HttpClient.Network.HTTP.Client.Request` | `Network.HTTP.Client` (request) |
| `Hale.HttpClient.Network.HTTP.Client.Response` | `Network.HTTP.Client` (response) |
| `Hale.HttpClient.Network.HTTP.Client.Redirect` | `Network.HTTP.Client` (redirect) |

Reference: https://hackage.haskell.org/package/req

| Lean Module | Haskell Module |
|---|---|
| `Hale.Req.Network.HTTP.Req` | `Network.HTTP.Req` |

Reference: https://hackage.haskell.org/package/conduit

| Lean Module | Haskell Module |
|---|---|
| `Hale.Conduit.Data.Conduit` | `Data.Conduit` |
| `Hale.Conduit.Data.Conduit.Internal.Pipe` | `Data.Conduit.Internal` (Pipe) |
| `Hale.Conduit.Data.Conduit.Internal.Conduit` | `Data.Conduit.Internal` (ConduitT) |
| `Hale.Conduit.Data.Conduit.Combinators` | `Data.Conduit.Combinators` |

Reference: https://hackage.haskell.org/package/http-conduit

| Lean Module | Haskell Module |
|---|---|
| `Hale.HttpConduit.Network.HTTP.Client.Conduit` | `Network.HTTP.Client.Conduit` |
| `Hale.HttpConduit.Network.HTTP.Simple` | `Network.HTTP.Simple` |

Reference: Hale-specific (no Haskell equivalent)

| Lean Module | Description |
|---|---|
| `Hale.DataFrame.DataFrame` | Tabular data with typed columns |
| `Hale.DataFrame.DataFrame.Internal.Types` | Core DataFrame/Column types |
| `Hale.DataFrame.DataFrame.Internal.Column` | Column operations |
| `Hale.DataFrame.DataFrame.Operations.Subset` | Row/column selection |
| `Hale.DataFrame.DataFrame.Operations.Sort` | Sorting |
| `Hale.DataFrame.DataFrame.Operations.Aggregation` | Group-by and aggregation |
| `Hale.DataFrame.DataFrame.Operations.Join` | Inner/outer joins |
| `Hale.DataFrame.DataFrame.Operations.Statistics` | Mean, std, quantiles |
| `Hale.DataFrame.DataFrame.Operations.Transform` | Map, filter, apply |
| `Hale.DataFrame.DataFrame.IO.CSV` | CSV read/write |
| `Hale.DataFrame.DataFrame.Display` | Pretty-printing |

Reference: https://hackage.haskell.org/package/containers

| Lean Module | Haskell Module |
|---|---|
| `Hale.Containers.Data.Map` | `Data.Map` |
| `Hale.Containers.Data.Map.Strict` | `Data.Map.Strict` |
| `Hale.Containers.Data.Set` | `Data.Set` |
| `Hale.Containers.Data.IntMap` | `Data.IntMap` |

Reference: https://hackage.haskell.org/package/text

| Lean Module | Haskell Module |
|---|---|
| `Hale.Text.Data.Text` | `Data.Text` |
| `Hale.Text.Data.Text.Encoding` | `Data.Text.Encoding` |

Reference: https://hackage.haskell.org/package/scientific

| Lean Module | Haskell Module |
|---|---|
| `Hale.Scientific.Data.Scientific` | `Data.Scientific` |

Reference: https://hackage.haskell.org/package/vector

| Lean Module | Haskell Module |
|---|---|
| `Hale.Vector.Data.Vector` | `Data.Vector` |

Reference: https://hackage.haskell.org/package/mtl

| Lean Module | Haskell Module |
|---|---|
| `Hale.Mtl.Control.Monad.Except` | `Control.Monad.Except` |
| `Hale.Mtl.Control.Monad.Reader` | `Control.Monad.Reader` |
| `Hale.Mtl.Control.Monad.State` | `Control.Monad.State` |
| `Hale.Mtl.Control.Monad.Trans` | `Control.Monad.Trans` |

Reference: https://hackage.haskell.org/package/optparse-applicative

| Lean Module | Haskell Module |
|---|---|
| `Hale.OptParse.Options.Applicative` | `Options.Applicative` |
| `Hale.OptParse.Options.Applicative.Types` | `Options.Applicative.Types` |
| `Hale.OptParse.Options.Applicative.Builder` | `Options.Applicative.Builder` |
| `Hale.OptParse.Options.Applicative.Extra` | `Options.Applicative.Extra` |

Reference: https://hackage.haskell.org/package/configurator-pg

| Lean Module | Haskell Module |
|---|---|
| `Hale.ConfiguratorPg.Data.Configurator` | `Data.Configurator` |
| `Hale.ConfiguratorPg.Data.Configurator.Types` | `Data.Configurator.Types` |

Reference: https://hackage.haskell.org/package/aeson

| Lean Module | Haskell Module |
|---|---|
| `Hale.Aeson.Data.Aeson` | `Data.Aeson` |
| `Hale.Aeson.Data.Aeson.Types` | `Data.Aeson.Types` |
| `Hale.Aeson.Data.Aeson.Encode` | `Data.Aeson.Encode` |
| `Hale.Aeson.Data.Aeson.Decode` | `Data.Aeson.Parser` |

Reference: https://hackage.haskell.org/package/hasql + https://hackage.haskell.org/package/postgresql-libpq

| Lean Module | Haskell Module |
|---|---|
| `Hale.Hasql.Database.PostgreSQL.LibPQ.Types` | `Database.PostgreSQL.LibPQ` (types) |
| `Hale.Hasql.Database.PostgreSQL.LibPQ` | `Database.PostgreSQL.LibPQ` |
| `Hale.Hasql.Hasql.Connection` | `Hasql.Connection` |
| `Hale.Hasql.Hasql.Session` | `Hasql.Session` |
| `Hale.Hasql.Hasql.Statement` | `Hasql.Statement` |
| `Hale.Hasql.Hasql.Decoders` | `Hasql.Decoders` |
| `Hale.Hasql.Hasql.Encoders` | `Hasql.Encoders` |
| `Hale.Hasql.Hasql.Pool` | `Hasql.Pool` |

Reference: https://hackage.haskell.org/package/jose

| Lean Module | Haskell Module |
|---|---|
| `Hale.Jose.Crypto.JOSE.Types` | `Crypto.JOSE.Types` / `Crypto.JWT` |
| `Hale.Jose.Crypto.JOSE.FFI` | (FFI bindings for OpenSSL crypto) |
| `Hale.Jose.Crypto.JOSE.JWK` | `Crypto.JOSE.JWK` |
| `Hale.Jose.Crypto.JOSE.JWS` | `Crypto.JOSE.JWS` |
| `Hale.Jose.Crypto.JOSE.JWT` | `Crypto.JWT` |

Reference: https://hackage.haskell.org/package/postgrest

| Lean Module | Haskell Module |
|---|---|
| `Hale.PostgREST.PostgREST.Version` | `PostgREST.Version` |
| `Hale.PostgREST.PostgREST.MediaType` | `PostgREST.MediaType` |
| `Hale.PostgREST.PostgREST.Error.Types` | `PostgREST.Error` (types) |
| `Hale.PostgREST.PostgREST.Error` | `PostgREST.Error` |
| `Hale.PostgREST.PostgREST.SchemaCache.Identifiers` | `PostgREST.SchemaCache.Identifiers` |
| `Hale.PostgREST.PostgREST.SchemaCache.Table` | `PostgREST.SchemaCache.Table` |
| `Hale.PostgREST.PostgREST.SchemaCache.Relationship` | `PostgREST.SchemaCache.Relationship` |
| `Hale.PostgREST.PostgREST.SchemaCache.Routine` | `PostgREST.SchemaCache.Routine` |
| `Hale.PostgREST.PostgREST.SchemaCache.Representations` | `PostgREST.SchemaCache.Representations` |
| `Hale.PostgREST.PostgREST.SchemaCache` | `PostgREST.SchemaCache` |
| `Hale.PostgREST.PostgREST.ApiRequest.Types` | `PostgREST.ApiRequest.Types` |
| `Hale.PostgREST.PostgREST.ApiRequest.Preferences` | `PostgREST.ApiRequest.Preferences` |
| `Hale.PostgREST.PostgREST.RangeQuery` | `PostgREST.RangeQuery` |
| `Hale.PostgREST.PostgREST.Plan.Types` | `PostgREST.Plan.Types` |
| `Hale.PostgREST.PostgREST.Plan.ReadPlan` | `PostgREST.Plan` (read) |
| `Hale.PostgREST.PostgREST.Plan.MutatePlan` | `PostgREST.Plan` (mutate) |
| `Hale.PostgREST.PostgREST.Plan.CallPlan` | `PostgREST.Plan` (call) |
| `Hale.PostgREST.PostgREST.Query.SqlFragment` | `PostgREST.Query.SqlFragment` |
| `Hale.PostgREST.PostgREST.Config` | `PostgREST.Config` |
| `Hale.PostgREST.PostgREST.Config.PgVersion` | `PostgREST.Config.PgVersion` |
| `Hale.PostgREST.PostgREST.Config.JSPath` | `PostgREST.Config.JSPath` |
| `Hale.PostgREST.PostgREST.Config.Database` | `PostgREST.Config.Database` |
| `Hale.PostgREST.PostgREST.Config.Proxy` | `PostgREST.Config.Proxy` |
| `Hale.PostgREST.PostgREST.Auth.Types` | `PostgREST.Auth` (types) |
| `Hale.PostgREST.PostgREST.Auth` | `PostgREST.Auth` |
| `Hale.PostgREST.PostgREST.AppState` | `PostgREST.AppState` |
| `Hale.PostgREST.PostgREST.Cors` | `PostgREST.Cors` |
| `Hale.PostgREST.PostgREST.Logger` | `PostgREST.Logger` |
| `Hale.PostgREST.PostgREST.Observation` | `PostgREST.Observation` |
| `Hale.PostgREST.PostgREST.Network` | `PostgREST.Network` |
| `Hale.PostgREST.PostgREST.Metrics` | `PostgREST.Metrics` |
| `Hale.PostgREST.PostgREST.Debounce` | `PostgREST.Debounce` |
| `Hale.PostgREST.PostgREST.TimeIt` | `PostgREST.TimeIt` |
| `Hale.PostgREST.PostgREST.Unix` | `PostgREST.Unix` |
| `Hale.PostgREST.PostgREST.Cache.Sieve` | `PostgREST.Cache.Sieve` |
| `Hale.PostgREST.PostgREST.Listener` | `PostgREST.Listener` |
| `Hale.PostgREST.PostgREST.Response` | `PostgREST.Response` |
| `Hale.PostgREST.PostgREST.Response.GucHeader` | `PostgREST.Response.GucHeader` |
| `Hale.PostgREST.PostgREST.Response.Performance` | `PostgREST.Response.Performance` |
| `Hale.PostgREST.PostgREST.Response.OpenAPI` | `PostgREST.Response.OpenAPI` |
| `Hale.PostgREST.PostgREST.MainTx` | `PostgREST.MainTx` |
| `Hale.PostgREST.PostgREST.Admin` | `PostgREST.Admin` |
| `Hale.PostgREST.PostgREST.CLI` | `PostgREST.CLI` |
| `Hale.PostgREST.PostgREST.App` | `PostgREST.App` |
