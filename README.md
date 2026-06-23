# Neuraclinic

`git clone --recurse-submodules git@github.com:zchelalo/neuraclinic.git`

## Estructura

- `neuraclinic-auth`: microservicio de autenticacion en Go
- `neuraclinic-users`: microservicio de usuarios
- `neuraclinic-proto-contracts`: contratos `.proto` compartidos
- `neuraclinic-jenkins`: configuracion y soporte para CI/CD
- `.docker/compose.yml`: servicios compartidos de desarrollo local

## Submodulos

Si el repositorio se clona sin `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

## Servicios compartidos

Actualmente esta capa levanta servicios generales reutilizables por varios microservicios. Por ahora incluye:

- `RabbitMQ`

### Levantar RabbitMQ local

Desde esta carpeta:

```bash
make compose-detached
```

RabbitMQ quedara disponible en:

- AMQP: `localhost:5672`
- Management UI: `http://localhost:15672`

Credenciales por defecto:

- usuario: `guest`
- password: `guest`

Los microservicios que necesiten publicar o consumir eventos deben conectarse a la red Docker `neuraclinic-network`.
El hostname compartido dentro de Docker es `neuraclinic-rabbitmq`.

## Notas

- Cada microservicio conserva su propio `docker compose`, `Makefile` y flujo de desarrollo.
- Esta raiz solo centraliza submodulos y servicios transversales del ecosistema.
- Todavia no se incluye `infra` en esta capa.
