B2D_ISO_VERSION := 1.9.1
B2D_ISO_FILE := boot2docker.iso
B2D_ISO_URL := https://github.com/boot2docker/boot2docker/releases/download/v$(B2D_ISO_VERSION)/boot2docker.iso
B2D_ISO_CHECKSUM := 669e0c5f2698188f0d48a2ed2a3e5218

all: virtualbox

virtualbox:	clean-virtualbox build-virtualbox test-virtualbox

$(B2D_ISO_FILE):
	curl -L -o ${B2D_ISO_FILE} ${B2D_ISO_URL}

$(PRL_B2D_ISO_FILE):
	curl -L -o ${PRL_B2D_ISO_FILE} ${PRL_B2D_ISO_URL}

build-virtualbox: $(B2D_ISO_FILE)
	packer build -only=virtualbox-iso \
		-var 'B2D_ISO_VERSION=${B2D_ISO_VERSION}' \
		-var 'B2D_ISO_URL=${B2D_ISO_URL}' \
		-var 'B2D_ISO_CHECKSUM=${B2D_ISO_CHECKSUM}' \
		template.json

clean-virtualbox:
	rm -f *_virtualbox.box $(B2D_ISO_FILE)

test-virtualbox:
	@cd tests/virtualbox; bats --tap *.bats

test-packer:
	packer validate template.json

push-virtualbox:
	packer push \
		-name $ALTAS_USERNAME/$ATLAS_NAME \
		-var 'B2D_ISO_VERSION=${B2D_ISO_VERSION}' \
		-var 'B2D_ISO_URL=${B2D_ISO_URL}' \
		-var 'B2D_ISO_CHECKSUM=${B2D_ISO_CHECKSUM}' \
		template.json

.PHONY: all virtualbox \
	clean-virtualbox build-virtualbox test-virtualbox
