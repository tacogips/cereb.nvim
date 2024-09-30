init-submodule:
	git submodule update --init --recursive

build-cereb:
	cd submodule/cereb && bun install
	bun build submodule/cereb/src/main.ts --outfile=./cereb-bin/cereb.js
