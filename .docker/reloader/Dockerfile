FROM alpine:3.18.3
RUN apk add --no-cache --upgrade bash curl jq
COPY reloader/reload.sh reload.sh
CMD ["sh","reload.sh"]
