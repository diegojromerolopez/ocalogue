.PHONY: all build test clean run lint format

all: build

build:
	dune build

test:
	dune runtest

clean:
	dune clean

run:
	dune exec ocalogue -- --help

lint:
	dune build @check 2>/dev/null || dune build

format:
	dune fmt 2>/dev/null || true
