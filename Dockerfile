# multi-arch, tiny static binary
FROM golang:1.22-alpine AS build
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/app-amd64 . \
&& CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o /out/app-arm64 .


FROM scratch AS amd64
COPY --from=build /out/app-amd64 /app
ENTRYPOINT ["/app"]


FROM scratch AS arm64
COPY --from=build /out/app-arm64 /app
ENTRYPOINT ["/app"]