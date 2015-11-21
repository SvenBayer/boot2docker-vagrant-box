
# -----------------------------------------------------------------------------
# CONFIG
# -----------------------------------------------------------------------------

# Boot2docker configuration
B2D_ISO_VERSION := 1.9.1
B2D_ISO_FILE := boot2docker.iso
B2D_ISO_URL := https://github.com/boot2docker/boot2docker/releases/download/v$(B2D_ISO_VERSION)/boot2docker.iso
B2D_ISO_CHECKSUM := 669e0c5f2698188f0d48a2ed2a3e5218

# Packer configuration
PACKER_TEMPLATE := template.json

all: virtualbox

# -----------------------------------------------------------------------------
# PACKER
# -----------------------------------------------------------------------------

packer-file:
	m4 template.json.m4 > template.json

packer-validate:
	packer validate ${PACKER_TEMPLATE}

# -----------------------------------------------------------------------------
# VIRTUALBOX
# -----------------------------------------------------------------------------

virtualbox:	virtualbox-clean virtualbox-build virtualbox-test

$(B2D_ISO_FILE):
	curl -L -o ${B2D_ISO_FILE} ${B2D_ISO_URL}

$(PRL_B2D_ISO_FILE):
	curl -L -o ${PRL_B2D_ISO_FILE} ${PRL_B2D_ISO_URL}

virtualbox-clean:
	rm -f *_virtualbox.box $(B2D_ISO_FILE)

virtualbox-build: $(B2D_ISO_FILE)
	packer build -only=virtualbox-iso \
		${PACKER_TEMPLATE}

virtualbox-test:
	@cd tests/virtualbox; bats --tap *.bats

virtualbox-push:
	packer push \
		-name ${ALTAS_USERNAME}/${ATLAS_NAME} \
		${PACKER_TEMPLATE}

# -----------------------------------------------------------------------------
# PHONY
# -----------------------------------------------------------------------------

.PHONY: all virtualbox \
	packer-file packer-validate virtualbox-clean virtualbox-build virtualbox-test
