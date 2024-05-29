# lua-resty-ada

**lua-resty-ada** implements a LuaJIT FFI bindings to Ada — WHATWG-compliant and fast URL parser.


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

-- There is also a static API

print(ada.get_href("https://www.7‑Eleven.com:1234/Home/../Privacy/Montréal"))
-- prints: https://www.xn--7eleven-506c.com:1234/Privacy/Montr%C3%A9al

print(ada.clear_port("https://www.7‑Eleven.com:1234/Home/../Privacy/Montréal"))
-- prints: https://www.xn--7eleven-506c.com/Privacy/Montr%C3%A9al
```


# License

`lua-resty-ada` uses two clause BSD license.

```
Copyright (c) 2024 Aapo Talvensaari
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
