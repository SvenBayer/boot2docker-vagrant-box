# Boot2docker configuration
B2D_ISO_VERSION := 1.9.1
B2D_ISO_FILE := boot2docker.iso
B2D_ISO_URL := https://github.com/boot2docker/boot2docker/releases/download/v$(B2D_ISO_VERSION)/boot2docker.iso
B2D_ISO_CHECKSUM := 669e0c5f2698188f0d48a2ed2a3e5218

# Packer configuration
PACKER_VARS := -var 'B2D_ISO_URL=${B2D_ISO_URL}' -var 'B2D_ISO_CHECKSUM=${B2D_ISO_CHECKSUM}'
PACKER_TEMPLATE := template.json

all: virtualbox

virtualbox:	clean-virtualbox build-virtualbox test-virtualbox

$(B2D_ISO_FILE):
	curl -L -o ${B2D_ISO_FILE} ${B2D_ISO_URL}

$(PRL_B2D_ISO_FILE):
	curl -L -o ${PRL_B2D_ISO_FILE} ${PRL_B2D_ISO_URL}

build-virtualbox: $(B2D_ISO_FILE)
	packer build -only=virtualbox-iso \
		${PACKER_VARS} \
		${PACKER_TEMPLATE}

clean-virtualbox:
	rm -f *_virtualbox.box $(B2D_ISO_FILE)

test-virtualbox:
	@cd tests/virtualbox; bats --tap *.bats

test-packer:
	packer validate \
		${PACKER_VARS} \
		${PACKER_TEMPLATE}

push-virtualbox:
	packer push \
		-name $ALTAS_USERNAME/$ATLAS_NAME \
		${PACKER_VARS} \
		${PACKER_TEMPLATE}

.PHONY: all virtualbox \
	clean-virtualbox build-virtualbox test-virtualbox
