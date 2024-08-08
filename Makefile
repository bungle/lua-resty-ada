.PHONY: build copy-library luarocks-install lint unit coverage test docs clean install

LIBRARY := libada.so
ifeq ($(shell uname), Darwin)
  LIBRARY := libada.dylib
endif

build:
	@cmake -B build
	@cmake --build build

copy-library: build
	@cp $ build/$(LIBRARY) .

luarocks-install:
	@luarocks make

lint:
	@luacheck ./lib

unit:
	@busted

coverage: unit
	@luacov
	@echo
	@awk '/File/,0' luacov.report.out
	@echo

test: copy-library luarocks-install coverage lint

docs:
	@ldoc .

clean:
	@rm -Rf build luacov.stats.out luacov.report.out $(LIBRARY)

install: deps
	@luarocks make
	@cmake --install build
