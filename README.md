# Neuraclinic

`git clone --recurse-submodules git@github.com:zchelalo/neuraclinic.git`

## Structure

- `neuraclinic-auth`: Go authentication microservice
- `neuraclinic-notifications`: Go email notifications worker
- `neuraclinic-users`: users microservice
- `neuraclinic-proto-contracts`: shared `.proto` contracts
- `neuraclinic-jenkins`: CI/CD support and Jenkins configuration
- `.docker/compose.yml`: shared local development services

## Submodules

If the repository is cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

## Shared Services

This root layer provides shared services that can be reused by multiple microservices. At the moment it includes:

- `RabbitMQ`

### Start RabbitMQ Locally

From this directory:

```bash
make compose-detached
```

RabbitMQ will be available at:

- AMQP: `localhost:5672`
- Management UI: `http://localhost:15672`

Default credentials:

- username: `guest`
- password: `guest`

Microservices that need to publish or consume events should connect to the Docker network `neuraclinic-network`.
The shared Docker hostname is `neuraclinic-rabbitmq`.

## Notes

- Each microservice keeps its own `docker compose`, `Makefile`, and development workflow.
- This root repository only centralizes submodules and cross-cutting shared services.
- `neuraclinic-notifications` consumes RabbitMQ events and should be converted to a git submodule once its remote repository exists.
- `infra` is not included in this layer yet.
