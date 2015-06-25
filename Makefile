
all: clean build test

build:
	packer build -parallel=false -only=virtualbox-iso template.json

test:
	@cd tests/virtualbox; bats --tap *.bats

clean:
	rm -rf *.iso *.box

.PHONY: clean build test all
