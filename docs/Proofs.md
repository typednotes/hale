# Proven Properties Catalog

> All theorems link to their source modules in the [API Reference](../Hale.html).

**Total: 257 compile-time verified theorems across 52 files**

All theorems are checked by the Lean 4 kernel at compile time. No `sorry`
in production code (one `sorry` exists in `unsafeToPiece` for trusted-input
constructor, documented as TODO).

## Algebraic Laws

### Monoid/Semigroup Associativity (8, in `Base/Data/Newtype.lean`)
| Theorem | Module |
|---------|--------|
| `Dual.append_assoc` | Base/Data/Newtype |
| `Endo.append_assoc` | Base/Data/Newtype |
| `First.append_assoc` | Base/Data/Newtype |
| `Last.append_assoc` | Base/Data/Newtype |
| `Sum.append_assoc` | Base/Data/Newtype |
| `Product.append_assoc` | Base/Data/Newtype |
| `All.append_assoc` | Base/Data/Newtype |
| `Any.append_assoc` | Base/Data/Newtype |

### Functor Laws (14)
| Theorem | Module |
|---------|--------|
| `Identity.map_id` | Base/Data/Functor/Identity |
| `Identity.map_comp` | Base/Data/Functor/Identity |
| `Const.map_id` | Base/Data/Functor/Const |
| `Const.map_comp` | Base/Data/Functor/Const |
| `Const.map_val` | Base/Data/Functor/Const |
| `Proxy.map_id` | Base/Data/Proxy |
| `Proxy.map_comp` | Base/Data/Proxy |
| `Either.map_id` | Base/Data/Either |
| `Either.map_comp` | Base/Data/Either |
| `Compose.map_id` | Base/Data/Functor/Compose |
| `Compose.map_comp` | Base/Data/Functor/Compose |
| `Product.map_id` | Base/Data/Functor/Product |
| `Product.map_comp` | Base/Data/Functor/Product |
| `Sum.map_id` | Base/Data/Functor/Sum |
| `Sum.map_comp` | Base/Data/Functor/Sum |

### Monad Laws (9)
| Theorem | Module |
|---------|--------|
| `Identity.pure_bind` | Base/Data/Functor/Identity |
| `Identity.bind_pure` | Base/Data/Functor/Identity |
| `Identity.bind_assoc` | Base/Data/Functor/Identity |
| `Proxy.pure_bind` | Base/Data/Proxy |
| `Proxy.bind_pure` | Base/Data/Proxy |
| `Proxy.bind_assoc` | Base/Data/Proxy |
| `Either.pure_bind` | Base/Data/Either |
| `Either.bind_pure` | Base/Data/Either |
| `Either.bind_assoc` | Base/Data/Either |

### Monad Combinators (1)
| Theorem | Module |
|---------|--------|
| `join_pure` | Base/Control/Monad |

## Data Structure Properties

### Either (3)
| Theorem | Module |
|---------|--------|
| `swap_swap` | Base/Data/Either |
| `isLeft_not_isRight` | Base/Data/Either |
| `partitionEithers_length` | Base/Data/Either |

### Maybe/Option (8)
| Theorem | Module |
|---------|--------|
| `maybe_none` | Base/Data/Maybe |
| `maybe_some` | Base/Data/Maybe |
| `fromMaybe_none` | Base/Data/Maybe |
| `fromMaybe_some` | Base/Data/Maybe |
| `catMaybes_nil` | Base/Data/Maybe |
| `mapMaybe_nil` | Base/Data/Maybe |
| `maybeToList_listToMaybe` | Base/Data/Maybe |
| `catMaybes_eq_mapMaybe_id` | Base/Data/Maybe |

### Tuple (7)
| Theorem | Module |
|---------|--------|
| `swap_swap` | Base/Data/Tuple |
| `curry_uncurry` | Base/Data/Tuple |
| `uncurry_curry` | Base/Data/Tuple |
| `bimap_id` | Base/Data/Tuple |
| `bimap_comp` | Base/Data/Tuple |
| `mapFst_eq_bimap` | Base/Data/Tuple |
| `mapSnd_eq_bimap` | Base/Data/Tuple |

### List (4)
| Theorem | Module |
|---------|--------|
| `tails_length` | Base/Data/List |
| `inits_length` | Base/Data/List |
| `tails_nil` | Base/Data/List |
| `inits_nil` | Base/Data/List |

### NonEmpty (4)
| Theorem | Module |
|---------|--------|
| `toList_ne_nil` | Base/Data/List/NonEmpty |
| `reverse_length` | Base/Data/List/NonEmpty |
| `toList_length` | Base/Data/List/NonEmpty |
| `map_length` | Base/Data/List/NonEmpty |

### Ord/Down (2)
| Theorem | Module |
|---------|--------|
| `get_mk` | Base/Data/Ord |
| `compare_reverse` | Base/Data/Ord |

### Bool (5)
| Theorem | Module |
|---------|--------|
| `bool_false` | Base/Data/Bool |
| `bool_true` | Base/Data/Bool |
| `guard'_true` | Base/Data/Bool |
| `guard'_false` | Base/Data/Bool |
| `bool_ite` | Base/Data/Bool |

### Void (1)
| Theorem | Module |
|---------|--------|
| `eq_absurd` | Base/Data/Void |

### Function (5)
| Theorem | Module |
|---------|--------|
| `on_apply` | Base/Data/Function |
| `applyTo_apply` | Base/Data/Function |
| `const_apply` | Base/Data/Function |
| `flip_flip` | Base/Data/Function |
| `flip_apply` | Base/Data/Function |

### Foldable (2)
| Theorem | Module |
|---------|--------|
| `foldr_nil` | Base/Data/Foldable |
| `foldl_nil` | Base/Data/Foldable |

### String (1)
| Theorem | Module |
|---------|--------|
| `unwords_nil` | Base/Data/String |

### Char (3)
| Theorem | Module |
|---------|--------|
| `isAlphaNum_iff` | Base/Data/Char |
| `isSpace_eq_isWhitespace` | Base/Data/Char |
| `ord_eq_toNat` | Base/Data/Char |

### Ix (1)
| Theorem | Module |
|---------|--------|
| `Ix.inRange_iff_index_isSome_nat` | Base/Data/Ix |

### ExitCode (2)
| Theorem | Module |
|---------|--------|
| `success_toUInt32` | Base/System/Exit |
| `isSuccess_iff` | Base/System/Exit |

## Numeric Type Properties

### Complex (2)
| Theorem | Module |
|---------|--------|
| `conjugate_conjugate` | Base/Data/Complex |
| `add_comm'` | Base/Data/Complex |

### Fixed-Point (5)
| Theorem | Module |
|---------|--------|
| `scale_pos` | Base/Data/Fixed |
| `add_exact` | Base/Data/Fixed |
| `sub_exact` | Base/Data/Fixed |
| `neg_neg` | Base/Data/Fixed |
| `fromInt_zero` | Base/Data/Fixed |

### Time (2)
| Theorem | Module |
|---------|--------|
| `fromSeconds_toSeconds` | Time/Data/Time/Clock |
| `diffUTCTime_self` | Time/Data/Time/Clock |

## Protocol Correctness

### HTTP Method Properties (21, in `HttpTypes/Network/HTTP/Types/Method.lean`)
| Theorem | What it proves |
|---------|---------------|
| `parseMethod_GET` | Parsing "GET" yields `.standard .GET` |
| `parseMethod_POST` | Parsing "POST" yields `.standard .POST` |
| `parseMethod_HEAD` | Parsing "HEAD" yields `.standard .HEAD` |
| `parseMethod_PUT` | Parsing "PUT" yields `.standard .PUT` |
| `parseMethod_DELETE` | Parsing "DELETE" yields `.standard .DELETE` |
| `parseMethod_TRACE` | Parsing "TRACE" yields `.standard .TRACE` |
| `parseMethod_CONNECT` | Parsing "CONNECT" yields `.standard .CONNECT` |
| `parseMethod_OPTIONS` | Parsing "OPTIONS" yields `.standard .OPTIONS` |
| `parseMethod_PATCH` | Parsing "PATCH" yields `.standard .PATCH` |
| `parseMethod_custom` | Non-standard strings yield `.custom` |
| `Method.get_is_safe` | GET is a safe method |
| `Method.head_is_safe` | HEAD is a safe method |
| `Method.options_is_safe` | OPTIONS is a safe method |
| `Method.trace_is_safe` | TRACE is a safe method |
| `Method.post_not_safe` | POST is not safe |
| `Method.patch_not_safe` | PATCH is not safe |
| `Method.put_is_idempotent` | PUT is idempotent |
| `Method.delete_is_idempotent` | DELETE is idempotent |
| `Method.post_not_idempotent` | POST is not idempotent |
| `Method.patch_not_idempotent` | PATCH is not idempotent |
| `Method.safe_implies_idempotent` | All safe methods are idempotent |

### HTTP Status Properties (13, in `HttpTypes/Network/HTTP/Types/Status.lean`)
| Theorem | What it proves |
|---------|---------------|
| `status200_valid` | 200 is in valid range [100, 599] |
| `status404_valid` | 404 is in valid range |
| `status500_valid` | 500 is in valid range |
| `status100_valid` | 100 is in valid range |
| `status301_valid` | 301 is in valid range |
| `status100_no_body` | 100 must not have body |
| `status101_no_body` | 101 must not have body |
| `status204_no_body` | 204 must not have body |
| `status304_no_body` | 304 must not have body |
| `status200_may_have_body` | 200 may have body |
| `status201_may_have_body` | 201 may have body |
| `status404_may_have_body` | 404 may have body |
| `status500_may_have_body` | 500 may have body |

### HTTP Version Properties (4, in `HttpTypes/Network/HTTP/Types/Version.lean`)
| Theorem | What it proves |
|---------|---------------|
| `http09_valid` | HTTP/0.9 has major=0, minor=9 |
| `http10_valid` | HTTP/1.0 has major=1, minor=0 |
| `http11_valid` | HTTP/1.1 has major=1, minor=1 |
| `http20_valid` | HTTP/2.0 has major=2, minor=0 |

### Transport Security (3, in `Warp/Types.lean`)
| Theorem | What it proves |
|---------|---------------|
| `tcp_not_secure` | TCP is not encrypted |
| `tls_is_secure` | TLS is always encrypted |
| `quic_is_secure` | QUIC is always encrypted |

### Keep-Alive Semantics (2, in `Warp/Run.lean`)
| Theorem | What it proves |
|---------|---------------|
| `connAction_http10_default` | HTTP/1.0 defaults to close |
| `connAction_http11_default` | HTTP/1.1 defaults to keep-alive |

### HTTP Version Parsing (5, in `Warp/Request.lean`)
| Theorem | What it proves |
|---------|---------------|
| `parseHttpVersion_http11` | "HTTP/1.1" -> http11 |
| `parseHttpVersion_http10` | "HTTP/1.0" -> http10 |
| `parseHttpVersion_http09` | "HTTP/0.9" -> http09 |
| `parseHttpVersion_http20` | "HTTP/2.0" -> http20 |
| `parseRequestLine_empty` | "" -> none |

### Warp Settings (1, in `Warp/Settings.lean`)
| Theorem | What it proves |
|---------|---------------|
| `defaultSettings_valid` | Default timeout > 0 and backlog > 0 |

## Encoding/Decoding Roundtrips

### HTTP/2 Frame Types (10, in `Http2/Network/HTTP2/Frame/Types.lean`)
| Theorem | Frame Type |
|---------|-----------|
| `fromUInt8_toUInt8_data` | DATA |
| `fromUInt8_toUInt8_headers` | HEADERS |
| `fromUInt8_toUInt8_priority` | PRIORITY |
| `fromUInt8_toUInt8_rstStream` | RST_STREAM |
| `fromUInt8_toUInt8_settings` | SETTINGS |
| `fromUInt8_toUInt8_pushPromise` | PUSH_PROMISE |
| `fromUInt8_toUInt8_ping` | PING |
| `fromUInt8_toUInt8_goaway` | GOAWAY |
| `fromUInt8_toUInt8_windowUpdate` | WINDOW_UPDATE |
| `fromUInt8_toUInt8_continuation` | CONTINUATION |

### HTTP/3 Frame Types (7, in `Http3/Network/HTTP3/Frame.lean`)
| Theorem | Frame Type |
|---------|-----------|
| `FrameType.roundtrip_data` | DATA |
| `FrameType.roundtrip_headers` | HEADERS |
| `FrameType.roundtrip_cancelPush` | CANCEL_PUSH |
| `FrameType.roundtrip_settings` | SETTINGS |
| `FrameType.roundtrip_pushPromise` | PUSH_PROMISE |
| `FrameType.roundtrip_goaway` | GOAWAY |
| `FrameType.roundtrip_maxPushId` | MAX_PUSH_ID |

### HTTP/3 Error Codes (17, in `Http3/Network/HTTP3/Error.lean`)
| Theorem | Error Code |
|---------|-----------|
| `H3Error.roundtrip_noError` | H3_NO_ERROR |
| `H3Error.roundtrip_generalProtocolError` | H3_GENERAL_PROTOCOL_ERROR |
| `H3Error.roundtrip_internalError` | H3_INTERNAL_ERROR |
| `H3Error.roundtrip_streamCreationError` | H3_STREAM_CREATION_ERROR |
| `H3Error.roundtrip_closedCriticalStream` | H3_CLOSED_CRITICAL_STREAM |
| `H3Error.roundtrip_frameUnexpected` | H3_FRAME_UNEXPECTED |
| `H3Error.roundtrip_frameError` | H3_FRAME_ERROR |
| `H3Error.roundtrip_excessiveLoad` | H3_EXCESSIVE_LOAD |
| `H3Error.roundtrip_idError` | H3_ID_ERROR |
| `H3Error.roundtrip_settingsError` | H3_SETTINGS_ERROR |
| `H3Error.roundtrip_missingSettings` | H3_MISSING_SETTINGS |
| `H3Error.roundtrip_requestRejected` | H3_REQUEST_REJECTED |
| `H3Error.roundtrip_requestCancelled` | H3_REQUEST_CANCELLED |
| `H3Error.roundtrip_requestIncomplete` | H3_REQUEST_INCOMPLETE |
| `H3Error.roundtrip_messageError` | H3_MESSAGE_ERROR |
| `H3Error.roundtrip_connectError` | H3_CONNECT_ERROR |
| `H3Error.roundtrip_versionFallback` | H3_VERSION_FALLBACK |

### WebSocket Opcodes (6, in `WebSockets/Types.lean`)
| Theorem | Opcode |
|---------|--------|
| `opcode_roundtrip_text` | TEXT |
| `opcode_roundtrip_binary` | BINARY |
| `opcode_roundtrip_close` | CLOSE |
| `opcode_roundtrip_ping` | PING |
| `opcode_roundtrip_pong` | PONG |
| `opcode_roundtrip_continuation` | CONTINUATION |

## ByteString Properties

### ByteString Invariants (3, in `ByteString/Internal.lean`)
| Theorem | What it proves |
|---------|---------------|
| `take_valid` | `take` result has valid offset/length |
| `drop_valid` | `drop` result has valid offset/length |
| `null_iff_length_zero` | `null bs <-> length bs = 0` |

### Builder Monoid (3, in `ByteString/Builder.lean`)
| Theorem | What it proves |
|---------|---------------|
| `empty_append` | `empty ++ b = b` (left identity) |
| `append_empty` | `b ++ empty = b` (right identity) |
| `append_assoc` | `(a ++ b) ++ c = a ++ (b ++ c)` (associativity) |

### Short ByteString (1, in `ByteString/Short.lean`)
| Theorem | What it proves |
|---------|---------------|
| `length_toShort` | `toShort` preserves length |

## Word8 Properties (4, in `Word8/Data/Word8.lean`)
| Theorem | What it proves |
|---------|---------------|
| `toLower_idempotent` | `toLower . toLower = toLower` |
| `toUpper_idempotent` | `toUpper . toUpper = toUpper` |
| `isUpper_toLower` | Upper -> toLower -> isLower |
| `isLower_toUpper` | Lower -> toUpper -> isUpper |

## CaseInsensitive (1, in `CaseInsensitive/Data/CaseInsensitive.lean`)
| Theorem | What it proves |
|---------|---------------|
| `ci_eq_iff` | CI equality is by foldedCase |

## Socket State (11, in `Network/Socket/Types.lean`)
| Theorem | What it proves |
|---------|---------------|
| `SocketState.fresh_ne_bound` | fresh /= bound |
| `SocketState.fresh_ne_listening` | fresh /= listening |
| `SocketState.fresh_ne_connected` | fresh /= connected |
| `SocketState.fresh_ne_closed` | fresh /= closed |
| `SocketState.bound_ne_listening` | bound /= listening |
| `SocketState.bound_ne_connected` | bound /= connected |
| `SocketState.bound_ne_closed` | bound /= closed |
| `SocketState.listening_ne_connected` | listening /= connected |
| `SocketState.listening_ne_closed` | listening /= closed |
| `SocketState.connected_ne_closed` | connected /= closed |
| `SocketState.beq_refl` | s == s = true |

## Response Lifecycle (1, in `WAI/Network/Wai/Internal.lean`)
| Theorem | What it proves |
|---------|---------------|
| `ResponseState.pending_ne_sent` | pending /= sent |

## Path Safety (4, in `WaiAppStatic/Types.lean`)
| Theorem | What it proves |
|---------|---------------|
| `empty_piece_valid` | Empty string is a valid piece |
| `toPiece_rejects_dot` | Dotfiles rejected at construction |
| `toPiece_rejects_slash` | Path traversal rejected at construction |
| `toPiece_accepts_simple` | Normal filenames accepted |

## WAI Response Laws (11, in `WAI/Internal.lean`)
| Theorem | What it proves |
|---------|---------------|
| `status_responseBuilder` | Status accessor on builder |
| `status_responseFile` | Status accessor on file |
| `status_responseStream` | Status accessor on stream |
| `headers_responseBuilder` | Headers accessor on builder |
| `headers_responseFile` | Headers accessor on file |
| `mapResponseHeaders_id_responseBuilder` | `mapHeaders id` on builder = id |
| `mapResponseHeaders_id_responseFile` | `mapHeaders id` on file = id |
| `mapResponseHeaders_id_responseStream` | `mapHeaders id` on stream = id |
| `mapResponseStatus_id_responseBuilder` | `mapStatus id` on builder = id |
| `mapResponseStatus_id_responseFile` | `mapStatus id` on file = id |
| `mapResponseStatus_id_responseStream` | `mapStatus id` on stream = id |

## WAI Middleware Algebra (5, in `WAI/Wai.lean`)
| Theorem | What it proves |
|---------|---------------|
| `idMiddleware_comp_left` | `id . m = m` |
| `idMiddleware_comp_right` | `m . id = m` |
| `modifyRequest_id` | `modifyRequest id = id` |
| `modifyResponse_id` | `modifyResponse id = id` |
| `ifRequest_false` | `ifRequest (always false) m = id` |

## Middleware Properties (11)

### AddHeaders (3, in `WaiExtra/AddHeaders.lean`)
| Theorem | What it proves |
|---------|---------------|
| `addHeaders_nil_builder` | Empty headers on builder = identity |
| `addHeaders_nil_file` | Empty headers on file = identity |
| `addHeaders_nil_stream` | Empty headers on stream = identity |

### StripHeaders (3, in `WaiExtra/StripHeaders.lean`)
| Theorem | What it proves |
|---------|---------------|
| `stripHeaders_nil_builder` | Empty strip list on builder = identity |
| `stripHeaders_nil_file` | Empty strip list on file = identity |
| `stripHeaders_nil_stream` | Empty strip list on stream = identity |

### Select (1, in `WaiExtra/Select.lean`)
| Theorem | What it proves |
|---------|---------------|
| `select_none` | Always-none = identity |

### Routed (2, in `WaiExtra/Routed.lean`)
| Theorem | What it proves |
|---------|---------------|
| `routed_true` | Always-true = apply middleware |
| `routed_false` | Always-false = identity |

### ForceSSL (1, in `WaiExtra/ForceSSL.lean`)
| Theorem | What it proves |
|---------|---------------|
| `forceSSL_secure` | Secure requests pass through |

### HealthCheck (1, in `WaiExtra/HealthCheckEndpoint.lean`)
| Theorem | What it proves |
|---------|---------------|
| `healthCheck_passthrough` | Non-matching paths pass through |

## ResourceT (1, in `ResourceT/Resource.lean`)
| Theorem | What it proves |
|---------|---------------|
| `releaseKey_eq` | `a = b <-> a.id = b.id` |

## Involution/Self-Inverse Properties (Summary)
| Theorem | Module |
|---------|--------|
| `swap_swap` (Tuple) | Base/Data/Tuple |
| `swap_swap` (Either) | Base/Data/Either |
| `conjugate_conjugate` | Base/Data/Complex |
| `flip_flip` | Base/Data/Function |
| `curry_uncurry` | Base/Data/Tuple |
| `neg_neg` (Fixed) | Base/Data/Fixed |
| `toLower_idempotent` | Word8/Data/Word8 |
| `toUpper_idempotent` | Word8/Data/Word8 |

## Proof-Carrying Structures (Invariants by Construction)
These are not standalone theorems but proof fields embedded in structures,
enforced at construction time and erased at runtime:

| Structure | Proof Field | Invariant |
|-----------|-------------|-----------|
| `Ratio` | `den_pos` | Denominator > 0 |
| `Ratio` | `coprime` | Num and den are coprime |
| `Piece` | `no_dot` | No leading dot |
| `Piece` | `no_slash` | No embedded slash |
| `Settings` | `settingsTimeoutPos` | Timeout > 0 |
| `Settings` | `settingsBacklogPos` | Backlog > 0 |
| `Socket` | `state` (phantom) | Socket state machine |
