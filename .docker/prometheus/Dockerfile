FROM alpine AS builder
RUN apk add gettext # envsubst is part of gettext

# RUN ldd /usr/bin/envsubst

FROM prom/prometheus

COPY --from=builder /lib/ld-musl-x86_64.so.1 /lib/ld-musl-x86_64.so.1
COPY --from=builder /usr/lib/libintl.so.8 /usr/lib/libintl.so.8
COPY --from=builder /usr/bin/envsubst /bin/envsubst


COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
