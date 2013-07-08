.PHONY: build clean

all: build

build: deps
	rebar compile

clean:
	rm -rf apps/*/ebin deps

deps:
	rebar get-deps

shell: all
	erl -pa apps/*/ebin -s flake -config demo.config

qc: all
	erl -pa apps/*/ebin -s flake -config demo.config -eval "prop_flake:exitcode(prop_flake:qc())"
