# syntax=docker/dockerfile:1

FROM golang:1.22-alpine AS build
WORKDIR /src

# (facultatif si ton binaire fait du TLS, utile pour ca-certs)
RUN apk add --no-cache ca-certificates

# Cache efficace des deps
# Si tu n'as pas de go.sum, copie juste go.mod
COPY go.mod ./
# COPY go.sum ./   # décommente si tu as un go.sum
RUN --mount=type=cache,target=/go/pkg/mod go mod download

# Copie du code
COPY . .

# Build par plateforme (buildx fournit $TARGETOS/$TARGETARCH)
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w" -o /out/app .

# Image finale ultra-minimale
FROM scratch
# (facultatif, seulement si TLS)
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /out/app /app
ENTRYPOINT ["/app"]
