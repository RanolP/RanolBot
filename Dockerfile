FROM rust:alpine AS chef

RUN rustup target add x86_64-unknown-linux-musl
RUN apk update
RUN apk add --no-cache openssl-dev musl-dev

WORKDIR /app
RUN cargo install cargo-chef

FROM chef AS planner

COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder

COPY --from=planner /app/recipe.json .
RUN cargo chef cook --release --recipe-path recipe.json

COPY . .
RUN cargo build --release

FROM alpine:latest

COPY --from=builder \
    /app/target/release/ranol-bot \
    /usr/bin/ranol-bot

ENTRYPOINT [ "/usr/bin/ranol-bot" ]