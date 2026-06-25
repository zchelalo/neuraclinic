# Neuraclinic

`git clone --recurse-submodules git@github.com:zchelalo/neuraclinic.git`

## Structure

- `neuraclinic-auth`: Go authentication microservice
- `neuraclinic-records`: Go clinical records microservice
- `neuraclinic-file-management`: Go file metadata and pre-signed URL microservice
- `neuraclinic-location`: Go location catalog and address suggestion microservice
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
- `neuraclinic-records` implements patients, appointments, notes, familiograms, and attachment metadata. Attachment uploads depend on an external `FileManagementService`.
- `neuraclinic-file-management` stores file metadata in PostgreSQL, signs S3-compatible upload/download URLs, uses MinIO locally, and includes Terraform for the AWS S3 bucket.
- `neuraclinic-location` serves offline location catalogs for address suggestions. Its migrations only create schema; catalogs must be imported explicitly from `neuraclinic-location` with `make import-location-data` or with the source-specific targets.
- `neuraclinic-notifications` consumes RabbitMQ events and should be converted to a git submodule once its remote repository exists.
- `infra` is not included in this layer yet.

## Location Catalogs

`neuraclinic-location` does not call public geocoding APIs at runtime and does not auto-download data on startup. To load Mexico postal-code, settlement, state, and municipality catalogs locally:

```bash
cd neuraclinic-location
make download-location-data
make import-location-data SOURCE_VERSION=2026-06-22 INEGI_SOURCE_VERSION=2026-06-12
```

`download-location-data` downloads the SEPOMEX national postal-code snapshot and INEGI AGEEML catalog zips into `neuraclinic-location/data/sources`, which is ignored by git. `import-location-data` starts the location stack, runs migrations through the service entrypoint, imports SEPOMEX postal codes/settlements, and imports INEGI AGEEML states/municipalities into PostgreSQL. Re-running the target is safe for the same snapshots because the importers use stable IDs and update existing rows.

Source-specific targets are also available: `make import-sepomex` and `make import-inegi-ageeml`. The larger INEGI locality file (`may_acento.zip`) is downloaded now for the next locality-level importer, but it is not loaded by the current target.

For API consumers, administrative-area filters use the `AdminAreaType` proto enum (`STATE`, `MUNICIPALITY`). Settlement types remain text because they are imported source values from SEPOMEX rather than a closed Neuraclinic taxonomy.
