---
-- Provides reusable utilities for `resty.ada`.
--
-- @local
-- @module resty.ada.utils


local lib = require("resty.ada.lib")
local new_tab = require("table.new")


local ffi = require("ffi")
local ffi_gc = ffi.gc
local ffi_str = ffi.string


local fmt = string.format
local type = type
local tostring = tostring
local tonumber = tonumber


local function ada_string_to_lua(result)
  if result.data == nil then -- nullptr equals to nil but is not falsy
    return nil
  end
  if result.length == 0 then
    return ""
  end
  local r = ffi_str(result.data, result.length)
  return r
end


local function ada_strings_to_lua(result)
  local size = tonumber(lib.ada_strings_size(ffi_gc(result, lib.ada_free_strings)), 10)
  if size == 0 then
    return {}
  end
  local r = new_tab(size, 0)
  for i = 1, size do
    r[i] = ada_string_to_lua(lib.ada_strings_get(result, i - 1))
  end
  return r
end


local function ada_owned_string_to_lua(ada_owned_string)
  local r = ada_string_to_lua(ffi_gc(ada_owned_string, lib.ada_free_owned_string))
  return r
end


local function port_to_string(port)
  local t = type(port)
  if t == "number" then
    port = fmt("%d", port)
  elseif t ~= "string" then
    port = tostring(port)
  end
  return port
end


return {
  ada_string_to_lua = ada_string_to_lua,
  ada_strings_to_lua = ada_strings_to_lua,
  ada_owned_string_to_lua = ada_owned_string_to_lua,
  port_to_string = port_to_string,
}
