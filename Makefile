LUACHECK = luacheck
BUSTED = busted


.PHONY: test lint

all: lint test

test: optarg.lua spec/optarg_spec.lua
	$(BUSTED) --verbose spec/

lint: optarg.lua spec/optarg_spec.lua
	$(LUACHECK) .

