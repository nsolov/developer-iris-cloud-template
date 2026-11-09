# Minimal InterSystems IRIS Developer Cloud template

This repository is a deliberately small IRIS REST application that can be used
as a starting point for a deployment on
[Developer Cloud](https://cloud.sandbox.developer.intersystems.com/).

It demonstrates the platform-specific pieces that an application normally
needs:

- a persistent application database at `/data`;
- reading a variable configured in the Developer Cloud UI;
- one public REST endpoint;
- an IRIS init method that records every successful start.

## Deploy to Developer Cloud

Create a deployment from this Git repository and use these settings:

| Setting | Value |
| --- | --- |
| IRIS init method | `APP:##class(App.Init).run()` |
| Variable name | `APP_MESSAGE` |
| Variable value | Any non-empty value |

After the deployment starts, open:

```text
https://<deployment>.sandbox.developer.intersystems.com/api/status
```

Example response:

```json
{
  "variable": {
    "name": "APP_MESSAGE",
    "isSet": true,
    "value": "Hello from Developer Cloud"
  },
  "irisInit": {
    "runCount": 1,
    "lastRunAt": "2026-11-09 09:00:00"
  }
}
```

For demonstration purposes, the endpoint returns the value of `APP_MESSAGE`.
Do not use this pattern for passwords, tokens, or other secret variables in a
real application.

The demo also gives public read/write permission to `%DB_APP` so that both the
unauthenticated endpoint and the platform init session stay minimal. A real
application should replace this with dedicated IRIS users, roles, and resource
permissions.

## How persistence works

[`iris.cpf`](iris.cpf) creates two databases:

- `APP-CODE` contains compiled classes and is part of the Docker image;
- `APP-DATA` contains globals and persistent objects and has
  `Directory=/data`.

Developer Cloud recognizes `/data` as persistent storage. Rebuilding or
redeploying the image replaces `APP-CODE`, but retains `APP-DATA`. Therefore the
`runCount` returned by the REST endpoint continues increasing across deploys.

The init method saves a row in `App.Data.StartupEvent` after every successful
IRIS start. The configured variable is read in ObjectScript with:

```objectscript
set value = $system.Util.GetEnviron("APP_MESSAGE")
```

## Run locally

Start the application:

```shell
docker compose up --build -d
curl http://localhost:52773/api/status
```

Developer Cloud invokes the init method itself. For the same demonstration
locally, invoke it once after IRIS starts:

```shell
docker compose exec -T iris iris session IRIS -U APP <<'EOF'
set sc = ##class(App.Init).run()
do:$system.Status.IsError(sc) $system.OBJ.DisplayError(sc)
halt
EOF
curl http://localhost:52773/api/status
```

Stop the local container:

```shell
docker compose down
```

The Compose setup is intentionally ephemeral. Developer Cloud provides the
persistent volume for `/data`; the local Compose file focuses only on quick
functional testing of the image.

## Project layout

```text
Dockerfile                       Builds a self-contained IRIS image
iris.cpf                         Database, namespace, and web app configuration
iris.script                      Imports and compiles ObjectScript classes
src/App/Init.cls                 Developer Cloud post-start method
src/App/REST.cls                 GET /api/status
src/App/Data/StartupEvent.cls    Persistent startup records
docker-compose.yml               Optional local development environment
```
