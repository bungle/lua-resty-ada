---
-- Provides reusable utilities for `resty.ada`.
--
-- @local
-- @module resty.ada.utils


local lib = require("resty.ada.lib")
local new_tab = require("table.new")


local ffi_str = require("ffi").string


local tonumber = tonumber
local tostring = tostring


local POS_INF = 1/0
local NEG_INF = -1/0


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
  local size = tonumber(lib.ada_strings_size(result), 10)
  if size == 0 then
    lib.ada_free_strings(result)
    return {}
  end
  local r = new_tab(size, 0)
  for i = 1, size do
    r[i] = ada_string_to_lua(lib.ada_strings_get(result, i - 1))
  end
  lib.ada_free_strings(result)
  return r
end


local function ada_owned_string_to_lua(ada_owned_string)
  local r = ada_string_to_lua(ada_owned_string)
  lib.ada_free_owned_string(ada_owned_string)
  return r
end


local function number_to_string(v)
  if v == POS_INF or v == NEG_INF or v ~= v then
    return nil
  end
  local r = tostring(v)
  return r
end


return {
  ada_string_to_lua = ada_string_to_lua,
  ada_strings_to_lua = ada_strings_to_lua,
  ada_owned_string_to_lua = ada_owned_string_to_lua,
  number_to_string = number_to_string,
}
