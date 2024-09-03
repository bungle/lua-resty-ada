package = "lua-resty-ada"
version = "1.1.0-1"
source = {
  url = "git+https://github.com/bungle/lua-resty-ada.git",
  tag = "v1.1.0",
}
description = {
  summary = "LuaJIT FFI bindings to Ada — WHATWG-compliant and fast URL parser",
  detailed = "lua-resty-ada implements a LuaJIT FFI bindings to Ada — WHATWG-compliant and fast URL parser.",
  homepage = "https://github.com/bungle/lua-resty-ada",
  maintainer = "Aapo Talvensaari <aapo.talvensaari@gmail.com>",
  license = "BSD",
}
dependencies = {
  "lua >= 5.1",
}
build = {
  type = "builtin",
  modules = {
    ["resty.ada"] = "lib/resty/ada.lua",
    ["resty.ada.lib"] = "lib/resty/ada/lib.lua",
    ["resty.ada.search"] = "lib/resty/ada/search.lua",
    ["resty.ada.utils"] = "lib/resty/ada/utils.lua",
  },
}
