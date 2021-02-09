# gRPC tutorial with Docker

This tutorial is an implementation with docker of the [Python quickstart tutorial][tutorial]
on the [gRPC website][gRPC].

## Cloning the repo

```bash
git clone https://github.com/CristianCantoro/grpc-tutorial
cd grpc-tutorial
```

## Usage

```bash
$ make
help                           Print this help and exits.
build                          Build the containers for the tutorial.
clean                          Remove stopped containers and images.
proto                          Regenerate Python gPRC files.
run-server                     Run gRPC server.
run-client                     Run gRPC client.
```

## Building

```bash
$ make build
[building docker images]
```

## Running the tutorial

On one terminal run

```bash
$ make run-server
--- Starting gRPC server
```

```bash
$ make run-client
--- Starting gRPC client
-> Send message: name=World
<- Greeter client received: Hello, World!
--- Exiting gRPC client
```

or

```bash
$ make run-client NAME='test'
--- Starting gRPC client
-> Send message: name=test
<- Greeter client received: Hello, test!
--- Exiting gRPC client
```

When a request is made, the server will receive it:

```bash
--- Starting gRPC server
<- Request(name=test)
-> Helloreply('Hello, test!')
```

## Cleaning up

```bash
make clean
[cleaning up docker containers, images, and networks]
```

[tutorial]: https://grpc.io/docs/languages/python/quickstart/
[gRPC]: https://grpc.io/
