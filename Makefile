#!make

# source variable from env file
include env
export $(shell sed 's/=.*//' env)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help build proto clean


.SILENT: build run-server run-client


help: ## Print this help and exits.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


.DEFAULT_GOAL := help

# globals
FORCE ?= false

# DOCKER TASKS
build: docker/Dockerfile.proto ## Build the containers for the tutorial.

	if $(FORCE) || ! docker images grpc-tutorial-proto:latest | \
			grep grpc-tutorial >/dev/null; then \
		docker build -t grpc-tutorial-proto:${VERSION} \
					 -t grpc-tutorial-proto:latest \
					 -f docker/Dockerfile.proto \
					 .; \
	fi

	if $(FORCE) || ! docker images grpc-tutorial:latest | grep grpc-tutorial \
			>/dev/null; then \
		docker build -t grpc-tutorial:${VERSION} \
					 -t grpc-tutorial:latest \
					 -f docker/Dockerfile.tutorial \
					 .; \
	fi

	if ! docker network ls -f "name=grpc-tutorial-network" | \
			grep grpc-tutorial >/dev/null; then \
		docker network create grpc-tutorial-network; \
	fi


clean: ## Remove stopped containers and images.
	# Remove stopped containers
	docker container ls -f "status=exited" | \
		grep grpc-tutorial-proto | \
		awk '{print $$1}' | \
		xargs -L1 --no-run-if-empty docker rm
	docker container ls -f "status=exited" | \
		grep grpc-tutorial | \
		awk '{print $$1}' | \
		xargs -L1 --no-run-if-empty docker rm

	# Remove network
	docker network ls -f "name=grpc-tutorial-network" | \
		grep grpc-tutorial-network | \
		awk '{print $$1}' | \
		xargs -L1 --no-run-if-empty docker network rm

	# Remove images
	docker images grpc-tutorial:$(VERSION) -q | \
		xargs -L1 --no-run-if-empty docker rmi -f
	docker images grpc-tutorial-proto:$(VERSION) -q | \
		xargs -L1 --no-run-if-empty docker rmi -f
	docker images grpc-tutorial:latest -q | \
		xargs -L1 --no-run-if-empty docker rmi -f
	docker images grpc-tutorial-proto:latest -q | \
		xargs -L1 --no-run-if-empty docker rmi -f


proto: ## Regenerate Python gPRC files.
	docker build -t grpc-tutorial-proto:latest \
				 -f ./docker/Dockerfile.proto \
				 .
	docker run \
		-it \
		--rm \
		--mount type=bind,\
source="$(PWD)"/proto,\
target=/home/tutorial/proto,\
readonly \
		--mount type=volume,\
dst=/home/tutorial/app,\
volume-driver=local,\
volume-opt=type=none,\
volume-opt=o=bind,volume-opt=device="$(PWD)"/app/ \
		grpc-tutorial-proto:latest \
			-m grpc_tools.protoc \
			-Iproto \
			--python_out=app \
			--grpc_python_out=app \
			proto/helloworld.proto


run-server: build ## Run gRPC server.
	docker run \
		--rm \
		--network grpc-tutorial-network \
		--network-alias server \
		grpc-tutorial:latest \
			app/greeter_server.py 

run-client: build ## Run gRPC client.
	docker run \
		--rm \
		--network grpc-tutorial-network \
		grpc-tutorial:latest \
			app/greeter_client.py $(if $(NAME),--name $(NAME),)
