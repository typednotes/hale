/*
 * ffi/tls.c — OpenSSL/LibreSSL TLS FFI for Lean 4
 *
 * Wraps OpenSSL's SSL_CTX, SSL objects for TLS server support.
 * Follows the same lean_alloc_external pattern as ffi/network.c.
 *
 * Features:
 * - TLS 1.2 / 1.3 support
 * - ALPN negotiation (for HTTP/2)
 * - Client certificate retrieval
 * - Proper resource cleanup via GC finalizer
 *
 * Platform: macOS and Linux. Requires OpenSSL or LibreSSL.
 */

#include <lean/lean.h>
#include <openssl/ssl.h>
#include <openssl/err.h>
#include <openssl/x509.h>
#include <string.h>
#include <stdlib.h>

/* ────────────────────────────────────────────────────────────
 * External classes for SSL_CTX and SSL
 * ──────────────────────────────────────────────────────────── */

static lean_external_class *g_hale_ssl_ctx_class = NULL;
static lean_external_class *g_hale_ssl_class = NULL;

typedef struct {
    SSL_CTX *ctx;
} hale_ssl_ctx_t;

typedef struct {
    SSL *ssl;
    int fd;  /* borrowed — not owned, closed by socket layer */
} hale_ssl_t;

static void hale_ssl_ctx_finalizer(void *ptr) {
    hale_ssl_ctx_t *c = (hale_ssl_ctx_t *)ptr;
    if (c) {
        if (c->ctx) SSL_CTX_free(c->ctx);
        free(c);
    }
}

static void hale_ssl_finalizer(void *ptr) {
    hale_ssl_t *s = (hale_ssl_t *)ptr;
    if (s) {
        if (s->ssl) {
            SSL_shutdown(s->ssl);
            SSL_free(s->ssl);
        }
        free(s);
    }
}

static void hale_noop_foreach_tls(void *mod, b_lean_obj_arg fn) {
    /* no sub-objects to traverse */
}

static void ensure_classes(void) {
    if (!g_hale_ssl_ctx_class) {
        g_hale_ssl_ctx_class = lean_register_external_class(
            hale_ssl_ctx_finalizer, hale_noop_foreach_tls);
    }
    if (!g_hale_ssl_class) {
        g_hale_ssl_class = lean_register_external_class(
            hale_ssl_finalizer, hale_noop_foreach_tls);
    }
}

static lean_obj_res mk_io_error(const char *msg) {
    unsigned long err = ERR_get_error();
    char buf[256];
    if (err) {
        ERR_error_string_n(err, buf, sizeof(buf));
    } else {
        strncpy(buf, msg, sizeof(buf) - 1);
        buf[sizeof(buf) - 1] = '\0';
    }
    return lean_mk_io_user_error(lean_mk_string(buf));
}

/* ────────────────────────────────────────────────────────────
 * SSL_CTX creation and configuration
 * ──────────────────────────────────────────────────────────── */

/*
 * @[extern "hale_tls_ctx_create"]
 * opaque tlsCtxCreateImpl : @& String → @& String → IO TLSContextHandle.type
 *
 * Creates an SSL_CTX configured for TLS server mode with the given
 * certificate and key files.
 */
LEAN_EXPORT lean_obj_res hale_tls_ctx_create(
    b_lean_obj_arg cert_path_obj,
    b_lean_obj_arg key_path_obj,
    lean_obj_arg world
) {
    ensure_classes();

    const char *cert_path = lean_string_cstr(cert_path_obj);
    const char *key_path = lean_string_cstr(key_path_obj);

    SSL_CTX *ctx = SSL_CTX_new(TLS_server_method());
    if (!ctx) {
        return lean_io_result_mk_error(mk_io_error("SSL_CTX_new failed"));
    }

    /* Set minimum TLS version to 1.2 */
    SSL_CTX_set_min_proto_version(ctx, TLS1_2_VERSION);

    /* Load certificate and private key */
    if (SSL_CTX_use_certificate_chain_file(ctx, cert_path) != 1) {
        SSL_CTX_free(ctx);
        return lean_io_result_mk_error(mk_io_error("Failed to load certificate"));
    }

    if (SSL_CTX_use_PrivateKey_file(ctx, key_path, SSL_FILETYPE_PEM) != 1) {
        SSL_CTX_free(ctx);
        return lean_io_result_mk_error(mk_io_error("Failed to load private key"));
    }

    if (SSL_CTX_check_private_key(ctx) != 1) {
        SSL_CTX_free(ctx);
        return lean_io_result_mk_error(mk_io_error("Private key does not match certificate"));
    }

    hale_ssl_ctx_t *wrapper = malloc(sizeof(hale_ssl_ctx_t));
    if (!wrapper) {
        SSL_CTX_free(ctx);
        return lean_io_result_mk_error(mk_io_error("malloc failed"));
    }
    wrapper->ctx = ctx;

    lean_obj_res obj = lean_alloc_external(g_hale_ssl_ctx_class, wrapper);
    return lean_io_result_mk_ok(obj);
}

/* ────────────────────────────────────────────────────────────
 * ALPN configuration (for HTTP/2 negotiation)
 * ──────────────────────────────────────────────────────────── */

static int alpn_select_cb(SSL *ssl, const unsigned char **out, unsigned char *outlen,
                          const unsigned char *in, unsigned int inlen, void *arg) {
    /* Prefer h2, fall back to http/1.1 */
    static const unsigned char h2[] = "\x02h2";
    static const unsigned char http11[] = "\x08http/1.1";

    if (SSL_select_next_proto((unsigned char **)out, outlen,
                              h2, sizeof(h2) - 1, in, inlen) == OPENSSL_NPN_NEGOTIATED) {
        return SSL_TLSEXT_ERR_OK;
    }
    if (SSL_select_next_proto((unsigned char **)out, outlen,
                              http11, sizeof(http11) - 1, in, inlen) == OPENSSL_NPN_NEGOTIATED) {
        return SSL_TLSEXT_ERR_OK;
    }
    return SSL_TLSEXT_ERR_NOACK;
}

/*
 * @[extern "hale_tls_ctx_set_alpn"]
 * opaque tlsCtxSetAlpnImpl : @& TLSContextHandle.type → IO Unit
 */
LEAN_EXPORT lean_obj_res hale_tls_ctx_set_alpn(
    b_lean_obj_arg ctx_obj,
    lean_obj_arg world
) {
    hale_ssl_ctx_t *wrapper = lean_get_external_data(ctx_obj);
    SSL_CTX_set_alpn_select_cb(wrapper->ctx, alpn_select_cb, NULL);
    return lean_io_result_mk_ok(lean_box(0));
}

/* ────────────────────────────────────────────────────────────
 * TLS handshake (accept)
 * ──────────────────────────────────────────────────────────── */

/*
 * @[extern "hale_tls_accept_socket"]
 * opaque tlsAcceptSocket : @& TLSContextHandle.type → @& RawSocket → IO TLSSessionHandle.type
 *
 * Performs a TLS server-side handshake on a Lean Socket external object.
 * Extracts the file descriptor from the external object (stored as (intptr_t)fd).
 */
LEAN_EXPORT lean_obj_res hale_tls_accept_socket(
    b_lean_obj_arg ctx_obj,
    b_lean_obj_arg sock_obj,
    lean_obj_arg world
) {
    /* Extract fd from the Socket external object (same encoding as network.c) */
    int fd = (int)(intptr_t)lean_get_external_data(sock_obj);
    ensure_classes();

    hale_ssl_ctx_t *ctx_wrapper = lean_get_external_data(ctx_obj);
    SSL *ssl = SSL_new(ctx_wrapper->ctx);
    if (!ssl) {
        return lean_io_result_mk_error(mk_io_error("SSL_new failed"));
    }

    SSL_set_fd(ssl, (int)fd);

    int ret = SSL_accept(ssl);
    if (ret != 1) {
        int err = SSL_get_error(ssl, ret);
        SSL_free(ssl);
        char msg[128];
        snprintf(msg, sizeof(msg), "SSL_accept failed (error %d)", err);
        return lean_io_result_mk_error(mk_io_error(msg));
    }

    hale_ssl_t *wrapper = malloc(sizeof(hale_ssl_t));
    if (!wrapper) {
        SSL_free(ssl);
        return lean_io_result_mk_error(mk_io_error("malloc failed"));
    }
    wrapper->ssl = ssl;
    wrapper->fd = (int)fd;

    lean_obj_res obj = lean_alloc_external(g_hale_ssl_class, wrapper);
    return lean_io_result_mk_ok(obj);
}

/* ────────────────────────────────────────────────────────────
 * TLS read / write / close
 * ──────────────────────────────────────────────────────────── */

/*
 * @[extern "hale_tls_read"]
 * opaque tlsReadImpl : @& TLSSessionHandle.type → USize → IO ByteArray
 */
LEAN_EXPORT lean_obj_res hale_tls_read(
    b_lean_obj_arg ssl_obj,
    size_t maxlen,
    lean_obj_arg world
) {
    hale_ssl_t *wrapper = lean_get_external_data(ssl_obj);
    if (!wrapper->ssl) {
        /* Return empty on closed session */
        lean_obj_res arr = lean_mk_empty_byte_array(lean_box(0));
        return lean_io_result_mk_ok(arr);
    }

    lean_obj_res arr = lean_mk_empty_byte_array(lean_box(maxlen));
    uint8_t *buf = lean_sarray_cptr(arr);

    int n = SSL_read(wrapper->ssl, buf, (int)maxlen);
    if (n <= 0) {
        /* EOF or error — return empty array */
        return lean_io_result_mk_ok(lean_mk_empty_byte_array(lean_box(0)));
    }

    lean_sarray_set_size(arr, n);
    return lean_io_result_mk_ok(arr);
}

/*
 * @[extern "hale_tls_write"]
 * opaque tlsWriteImpl : @& TLSSessionHandle.type → @& ByteArray → IO Unit
 */
LEAN_EXPORT lean_obj_res hale_tls_write(
    b_lean_obj_arg ssl_obj,
    b_lean_obj_arg data_obj,
    lean_obj_arg world
) {
    hale_ssl_t *wrapper = lean_get_external_data(ssl_obj);
    if (!wrapper->ssl) {
        return lean_io_result_mk_error(lean_mk_io_user_error(
            lean_mk_string("TLS write on closed session")));
    }

    size_t len = lean_sarray_size(data_obj);
    const uint8_t *buf = lean_sarray_cptr(data_obj);
    size_t written = 0;

    while (written < len) {
        int n = SSL_write(wrapper->ssl, buf + written, (int)(len - written));
        if (n <= 0) {
            return lean_io_result_mk_error(mk_io_error("SSL_write failed"));
        }
        written += n;
    }

    return lean_io_result_mk_ok(lean_box(0));
}

/*
 * @[extern "hale_tls_close"]
 * opaque tlsCloseImpl : @& TLSSessionHandle.type → IO Unit
 */
LEAN_EXPORT lean_obj_res hale_tls_close(
    b_lean_obj_arg ssl_obj,
    lean_obj_arg world
) {
    hale_ssl_t *wrapper = lean_get_external_data(ssl_obj);
    if (wrapper->ssl) {
        SSL_shutdown(wrapper->ssl);
        SSL_free(wrapper->ssl);
        wrapper->ssl = NULL;
    }
    return lean_io_result_mk_ok(lean_box(0));
}

/* ────────────────────────────────────────────────────────────
 * TLS introspection
 * ──────────────────────────────────────────────────────────── */

/*
 * @[extern "hale_tls_get_version"]
 * opaque tlsGetVersionImpl : @& TLSSessionHandle.type → IO String
 */
LEAN_EXPORT lean_obj_res hale_tls_get_version(
    b_lean_obj_arg ssl_obj,
    lean_obj_arg world
) {
    hale_ssl_t *wrapper = lean_get_external_data(ssl_obj);
    const char *ver = wrapper->ssl ? SSL_get_version(wrapper->ssl) : "unknown";
    return lean_io_result_mk_ok(lean_mk_string(ver));
}

/*
 * @[extern "hale_tls_get_alpn"]
 * opaque tlsGetAlpnImpl : @& TLSSessionHandle.type → IO (Option String)
 */
LEAN_EXPORT lean_obj_res hale_tls_get_alpn(
    b_lean_obj_arg ssl_obj,
    lean_obj_arg world
) {
    hale_ssl_t *wrapper = lean_get_external_data(ssl_obj);
    if (!wrapper->ssl) {
        return lean_io_result_mk_ok(lean_box(0));
    }

    const unsigned char *alpn = NULL;
    unsigned int alpn_len = 0;
    SSL_get0_alpn_selected(wrapper->ssl, &alpn, &alpn_len);

    if (alpn && alpn_len > 0) {
        lean_obj_res s = lean_mk_string_from_bytes((const char *)alpn, alpn_len);
        return lean_io_result_mk_ok(({lean_obj_res opt = lean_alloc_ctor(1, 1, 0); lean_ctor_set(opt, 0, s); opt;}));
    }
    return lean_io_result_mk_ok(lean_box(0));
}
