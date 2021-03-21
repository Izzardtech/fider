# Build Step
FROM getfider/githubci:0.0.5 AS builder

RUN mkdir /app
WORKDIR /app

COPY . .
RUN npm ci
RUN GOOS=linux GOARCH=amd64 mage build

# Runtime Step
FROM debian:buster-slim

RUN apt-get update
RUN apt-get install -y ca-certificates

RUN mkdir /app
WORKDIR /app

COPY --from=builder /app/favicon.png /app
COPY --from=builder /app/migrations /app/migrations
COPY --from=builder /app/views /app/views
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/LICENSE /app
COPY --from=builder /app/robots.txt /app
COPY --from=builder /app/ssr.js /app
COPY --from=builder /app/fider /app

EXPOSE 3000

HEALTHCHECK --timeout=5s CMD ./fider ping

CMD ./fider migrate && ./fider