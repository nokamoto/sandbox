EXAMPLE_IMAGE = ghcr.io/nokamoto/sandbox/example
GO_BUILDER = gcr.io/buildpacks/builder:v1
PROTO_FILES := $(shell find api -type f -name *.proto)
PROTO_GEN_DIR = internal/proto

.PHONY: go
go: go-fmt go-test
	go mod tidy

.PHONY: go-build-example
go-build-example:
	pack build --builder $(GO_BUILDER) $(EXAMPLE_IMAGE)

.PHONY: go-fmt
go-fmt:
	go fmt ./...

.PHONY: go-publish-example
go-publish-example:
ifndef TAG
	$(error TAG required)
endif
	pack build --builder $(GO_BUILDER) --publish $(EXAMPLE_IMAGE):$(TAG)

.PHONY: go-run-example
go-run-example:
	GRPC_PORT=9000 go run ./cmd/example

.PHONY: go-test
go-test:
	go test -v ./...

.PHONY: protoc
protoc:
	protoc \
		--go_out=$(PROTO_GEN_DIR) --go_opt=paths=source_relative \
    	--go-grpc_out=$(PROTO_GEN_DIR) --go-grpc_opt=paths=source_relative \
   		$(PROTO_FILES)

.PHONY: proto-fmt
proto-fmt:
	find . -type f -name *.proto | xargs clang-format -i

kind:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
	chmod +x ./kind
