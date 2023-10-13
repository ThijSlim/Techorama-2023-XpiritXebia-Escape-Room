# Techorama-Escape-Room

## Run app build

1. Change version in pubspec.yaml

2. Create a Github Release

```sh
git tag v<Version in pubspec>
git push --tags
```

## Run back-end

```sh
cd ./Xpirit.EscapeRoom
docker compose up --build
```

## Reverse Proxy to localhost API

Authenticate with ngrok

```sh
ngrok authtoken <Token>
```

Create reverse proxy to localhost

```sh
ngrok http 5120 --domain xpiritescaperoom.ngrok.dev
```

## Build IOS App

```sh
flutter build ipa
```