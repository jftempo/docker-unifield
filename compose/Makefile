VER=3.0rc2

# The base image does not include any Unifield code
# so we put a simpler base version on it.
BASEVER=1

help:
	@echo "targets:"
	@echo "  checkout: fetch the code into directory unifield"
	@echo "  build: build the Docker images, store them locally"
	@echo "  push: push the Docker images to Docker Hub"
	@echo
	@echo "Add the VER=xxx to the end to checkout tag xxx"
	@echo "from Bazaar, i.e. make build VER=2.1-3"

checkout:
	mkdir -p unifield
	bzr checkout --lightweight -r uf$(VER) $(HOME)/unifield/server/branches/trunk unifield/server
	bzr checkout --lightweight -r uf$(VER) $(HOME)/unifield/web/branches/trunk unifield/web

build:
	docker build -f Dockerfile-base -t unifield/base:$(BASEVER) .
	docker build -f Dockerfile-web -t unifield/web:$(VER) .
	docker build -f Dockerfile-server -t unifield/server:$(VER) .

push:
	docker push unifield/base:$(BASEVER)
	docker push unifield/web:$(VER)
	docker push unifield/server:$(VER)
