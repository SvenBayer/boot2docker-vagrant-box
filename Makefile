BOOT2DOCKER_VERSION := 1.8.2

B2D_ISO_FILE := boot2docker.iso
B2D_ISO_URL := https://github.com/boot2docker/boot2docker/releases/download/v$(BOOT2DOCKER_VERSION)/boot2docker.iso
B2D_ISO_CHECKSUM := 29839aeef97758e142eae4c2fd10890b

all: virtualbox

virtualbox:	clean-virtualbox build-virtualbox test-virtualbox

$(B2D_ISO_FILE):
	curl -L -o ${B2D_ISO_FILE} ${B2D_ISO_URL}

$(PRL_B2D_ISO_FILE):
	curl -L -o ${PRL_B2D_ISO_FILE} ${PRL_B2D_ISO_URL}

build-virtualbox: $(B2D_ISO_FILE)
	packer build -only=virtualbox-iso \
		-var 'B2D_ISO_FILE=${B2D_ISO_FILE}' \
		-var 'B2D_ISO_CHECKSUM=${B2D_ISO_CHECKSUM}' \
		template.json

clean-virtualbox:
	rm -f *_virtualbox.box $(B2D_ISO_FILE)

test-virtualbox:
	@cd tests/virtualbox; bats --tap *.bats

.PHONY: all virtualbox \
	clean-virtualbox build-virtualbox test-virtualbox \
