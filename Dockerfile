FROM bitwalker/alpine-elixir:1.9.0
RUN apk add make gcc libc-dev inotify-tools
WORKDIR /app

ENV MIX_ENV dev

COPY mix.* ./
COPY .formatter.exs /app/
RUN mix do deps.get, deps.compile

COPY lib /app/lib
COPY test /app/test
COPY config /app/config

RUN mix compile

ENTRYPOINT mix test.watch --stale
