# Developer Sandbox Example TODO

This repository is a small, ready-to-use TODO application that can be used as a
starting point for a deployment on
[Developer Cloud](https://cloud.sandbox.developer.intersystems.com/).

Open the deployment and you immediately get an English-language web UI where
tasks can be listed, added, and deleted. The application demonstrates:

- persistent application data stored in IRIS at `/data`;
- a static browser UI served by the bundled web server;
- a JSON REST API with list, create, and delete operations;
- reading a variable configured in the Developer Cloud UI;
- an IRIS init method that records every successful start.

## Deploy to Developer Cloud

Create a deployment from this Git repository and use these settings:

| Setting | Value |
| --- | --- |
| IRIS init method | `APP:##class(App.Init).run()` |
| Variable name | `APP_MESSAGE` |
| Variable value | Any non-empty value |

After the deployment starts, open its root URL:

```text
https://<deployment>.sandbox.developer.intersystems.com/
```

The init method creates three sample tasks the first time a new persistent
database starts. They can be deleted and will not be recreated on later starts.

Runtime details, including `APP_MESSAGE`, are available from `/api/status`:

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

For demonstration purposes, the status endpoint shows the value of
`APP_MESSAGE`.
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

TODO items are instances of the persistent `App.Data.Todo` class. The init
method also saves a row in `App.Data.StartupEvent` after every successful IRIS
start. The configured variable is read in ObjectScript with:

```objectscript
set value = $system.Util.GetEnviron("APP_MESSAGE")
```

## Run locally

Start the application:

```shell
docker compose up --build -d
```

Open [http://localhost:52773/](http://localhost:52773/) in a browser.

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

The TODO API can also be used directly:

```shell
curl http://localhost:52773/api/todos
curl -X POST http://localhost:52773/api/todos \
  -H 'Content-Type: application/json' \
  --data '{"text":"Try the Developer Sandbox example"}'
curl -X DELETE http://localhost:52773/api/todos/1
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
src/App/REST.cls                 Status and TODO REST endpoints
src/App/Data/StartupEvent.cls    Persistent startup records
src/App/Data/Todo.cls            Persistent TODO items
web/index.html                   Static TODO page
web/app.css                      Shared frontend styles
web/app.js                       TODO frontend behavior
httpd-local.conf                 Root URL mapping to the static entry point
docker-compose.yml               Optional local development environment
```
