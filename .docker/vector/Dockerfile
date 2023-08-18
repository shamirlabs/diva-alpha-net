FROM --platform=linux/amd64 timberio/vector:latest-alpine
COPY ./config/vector/vector.toml /local/vector/vector.toml
CMD ["--config=/local/vector/vector.toml"]
