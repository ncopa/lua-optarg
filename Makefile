LUA = lua
LUACHECK = luacheck

.PHONY: test lint

all: lint test

test: optarg.lua test_optarg.lua
	$(LUA) test_optarg.lua -v

lint: optarg.lua test_optarg.lua
	$(LUACHECK) .

