# lua-resty-ada

**lua-resty-ada** implements a LuaJIT FFI bindings to
[Ada — WHATWG-compliant and fast URL parser](https://github.com/ada-url/ada/).

## Status

This library is considered production ready.


## Synopsis

```lua
local ada = require("resty.ada")

local url = assert(ada.parse("https://www.7‑Eleven.com:1234/Home/../Privacy/Montréal"))

print(tostring(url))
-- prints: https://www.xn--7eleven-506c.com:1234/Privacy/Montr%C3%A9al

print(tostring(url:clear_port())) -- there are many more methods
-- prints: https://www.xn--7eleven-506c.com/Privacy/Montr%C3%A9al

url:free()
-- explicitly frees the memory without waiting for the garbage collector

-- There is also a static API

print(ada.get_href("https://www.7‑Eleven.com:1234/Home/../Privacy/Montréal"))
-- prints: https://www.xn--7eleven-506c.com:1234/Privacy/Montr%C3%A9al

print(ada.clear_port("https://www.7‑Eleven.com:1234/Home/../Privacy/Montréal"))
-- prints: https://www.xn--7eleven-506c.com/Privacy/Montr%C3%A9al
```


## API

LDoc generated API docs can be viewed at [bungle.github.io/lua-resty-ada](https://bungle.github.io/lua-resty-ada/).


## Installation

### Using OpenResty Package Manager

```bash
❯ opm get bungle/lua-resty-ada
```

OPM repository for `lua-resty-ada` is located at
[opm.openresty.org/package/bungle/lua-resty-ada](https://opm.openresty.org/package/bungle/lua-resty-ada/).

### Using LuaRocks

```bash
❯ luarocks install lua-resty-ada
```

LuaRocks repository for `lua-resty-ada` is located at
[luarocks.org/modules/bungle/lua-resty-ada](https://luarocks.org/modules/bungle/lua-resty-session).

### Building Ada

Please consult [Ada](https://github.com/ada-url/ada/) on how to build or install
the ada library. The Ada library needs to installed in in the system library path or
one of the paths in Lua's `package.cpath`.

This project can also build it by executing (requires [cmake](https://cmake.org/)):

```bash
❯ make build
```

Or run the test suite with [act](https://github.com/nektos/act):

```bash
❯ act
```


# License

`lua-resty-ada` uses two clause BSD license.

```
Copyright (c) 2024–2025 Aapo Talvensaari, 2024 Guilherme Salazar
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
```
