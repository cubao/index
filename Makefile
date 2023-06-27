PROJECT_SOURCE_DIR ?= $(abspath ./)
PROJECT_NAME ?= $(shell basename $(PROJECT_SOURCE_DIR))
all:
	@echo nothing special

clean:
	rm -rf build dist site
force_clean:
	docker run --rm -v `pwd`:`pwd` -w `pwd` -it alpine/make make clean
.PHONY: clean force_clean

lint:
	pre-commit run -a
lint_install:
	pre-commit install
.PHONY: lint lint_install

install:
	python3 -m pip install -r requirements.txt
.PHONY: install

docs_build:
	JUPYTER_PLATFORM_DIRS=1 mkdocs build
docs_serve:
	mkdocs serve -a 0.0.0.0:8088
.PHONY: docs_build docs_serve

jupyterlab:
	jupyter lab --ip=0.0.0.0 --port 8899 --LabApp.token='' --no-browser \
		--ServerApp.iopub_msg_rate_limit 10000000 --allow-root
.PHONY: jupyterlab

DOCKER_TAG_WINDOWS ?= ghcr.io/cubao/build-env-windows-x64:v0.0.1
DOCKER_TAG_LINUX ?= ghcr.io/cubao/build-env-manylinux2014-x64:v0.0.3
DOCKER_TAG_MACOS ?= ghcr.io/cubao/build-env-macos-arm64:v0.0.1
DOCKER_TAG_JUPYTERLAB ?= ghcr.io/cubao/build-env-jupyterlab:v0.0.1

docker_build:
	docker build -t $(DOCKER_TAG_JUPYTERLAB) -f Dockerfile .
.PHONY: docker_build

test_in_jupyterlab:
	docker run --rm -w `pwd` -v `pwd`:`pwd` -it $(DOCKER_TAG_JUPYTERLAB) bash
test_in_win:
	docker run --rm -w `pwd` -v `pwd`:`pwd` -v `pwd`/build/win:`pwd`/build -it $(DOCKER_TAG_WINDOWS) bash
test_in_mac:
	docker run --rm -w `pwd` -v `pwd`:`pwd` -v `pwd`/build/mac:`pwd`/build -it $(DOCKER_TAG_MACOS) bash
test_in_linux:
	docker run --rm -w `pwd` -v `pwd`:`pwd` -v `pwd`/build/linux:`pwd`/build -it $(DOCKER_TAG_LINUX) bash
.PHONY: test_in_jupyterlab test_in_win test_in_mac test_in_linux

DEV_CONTAINER_NAME ?= $(USER)_$(subst /,_,$(PROJECT_NAME)____$(PROJECT_SOURCE_DIR))
DEV_CONTAINER_IMAG ?= $(DOCKER_TAG_JUPYTERLAB)
test_in_dev_container:
	docker ps | grep $(DEV_CONTAINER_NAME) \
		&& docker exec --network host -it $(DEV_CONTAINER_NAME) bash \
		|| docker run --rm --name $(DEV_CONTAINER_NAME) \
			--network host --security-opt seccomp=unconfined \
			-v `pwd`:`pwd` -w `pwd` -it $(DEV_CONTAINER_IMAG) bash
.PHONY: test_in_dev_container
