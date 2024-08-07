.PHONY: deps lint test unit docs

BUILD_DIR := $(shell mktemp -d)

deps:
	@cmake -S deps/ada -B $(BUILD_DIR)
	@cmake --build $(BUILD_DIR)
	@cp $(BUILD_DIR)/libada.* .
	@rm -Rf $(BUILD_DIR)

lint:
	@luacheck -q ./lib

test: deps
	@luarocks make
	@busted --coverage
	@echo
	@awk '/File/,0' luacov.report.out
	@echo
	@echo Lint
	@echo -----------------------------------------------------------------------------------
	@luacheck -q ./lib
	@echo

unit:
	@luarocks make
	@busted --coverage
	@echo
	@awk '/File/,0' luacov.report.out
	@echo
	@echo Lint
	@echo -----------------------------------------------------------------------------------
	@luacheck -q ./lib
	@echo

docs:
	@ldoc .
