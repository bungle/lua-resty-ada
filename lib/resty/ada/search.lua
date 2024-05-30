local lib = require("resty.ada.lib")
local utils = require("resty.ada.utils")


local ada_string_to_lua = utils.ada_string_to_lua
local ada_strings_to_lua = utils.ada_strings_to_lua
local ada_owned_string_to_lua = utils.ada_owned_string_to_lua


local ffi_gc = require("ffi").gc


local type = type
local assert = assert
local tonumber = tonumber
local setmetatable = setmetatable


local mt = {}


mt.__index = mt


local function new(search)
  assert(type(search) == "string", "invalid search")
  local s = ffi_gc(lib.ada_parse_search_params(search, #search), lib.ada_free_search_params)
  return s
end


local function parse(search)
  local s = new(search)
  local self = setmetatable({ s }, mt)
  return self
end


local function sort(search)
  local s = new(search)
  lib.ada_search_params_sort(s)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end
function mt:sort()
  lib.ada_search_params_sort(self[1])
  return self
end


local function append(search, key, value)
  local s = new(search)
  lib.ada_search_params_append(s, key, #key, value, #value)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end
function mt:append(key, value)
  lib.ada_search_params_append(self[1], key, #key, value, #value)
  return self
end


local function set(search, key, value)
  local s = new(search)
  lib.ada_search_params_set(s, key, #key, value, #value)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end
function mt:set(key, value)
  lib.ada_search_params_set(self[1], key, #key, value, #value)
  return self
end


local function remove(search, key)
  local s = new(search)
  lib.ada_search_params_remove(s, key, #key)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end
function mt:remove(key)
  lib.ada_search_params_remove(self[1], key, #key)
  return self
end


local function remove_value(search, key, value)
  local s = new(search)
  lib.ada_search_params_remove_value(s, key, #key, value, #value)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end
function mt:remove_value(key, value)
  lib.ada_search_params_remove_value(self[1], key, #key, value, #value)
  return self
end


local function has(search, key)
  local s = new(search)
  local r = lib.ada_search_params_has(s, key, #key)
  return r
end
function mt:has(key)
  local r = lib.ada_search_params_has(self[1], key, #key)
  return r
end


local function has_value(search, key, value)
  local s = new(search)
  local r =  lib.ada_search_params_has_value(s, key, #key, value, #value)
  return r
end
function mt:has_value(key, value)
  local r = lib.ada_search_params_has_value(self[1], key, #key, value, #value)
  return r
end


local function real_get(s, key)
  local r = ada_string_to_lua(lib.ada_search_params_get(s, key, #key))
  return r
end
local function get(search, key)
  local s = new(search)
  local r = real_get(s, key)
  return r
end
function mt:get(key)
  local r = real_get(self[1], key)
  return r
end


local function real_get_all(s, key)
  local r = ada_strings_to_lua(lib.ada_search_params_get_all(s, key, #key))
  return r
end
local function get_all(search, key)
  local s = new(search)
  local r = real_get_all(s, key)
  return r
end
function mt:get_all(key)
  local r = real_get_all(self[1], key)
  return r
end


local function real_size(s)
  local r = tonumber(lib.ada_search_params_size(s), 10)
  return r
end
local function size(search, key)
  local s = new(search)
  local r = real_size(s, key)
  return r
end
function mt:size(key)
  local r = real_size(self[1], key)
  return r
end


local function pairs_iter(entries_iterator)
  if lib.ada_search_params_entries_iter_has_next(entries_iterator) then
    local pair = lib.ada_search_params_entries_iter_next(entries_iterator)
    local key = pair.key
    local value = pair.value
    key = ada_string_to_lua(key)
    value = ada_string_to_lua(value)
    return key, value
  end
end
local function static_pairs(search)
  local s = new(search)
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(s), lib.ada_free_search_params_entries_iter)
  return pairs_iter, entries_iter
end
function mt:__pairs()
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(self[1]), lib.ada_free_search_params_entries_iter)
  return pairs_iter, entries_iter
end


local function ipairs_iter(entries_iterator, invariant_state)
  if lib.ada_search_params_entries_iter_has_next(entries_iterator) then
    local pair = lib.ada_search_params_entries_iter_next(entries_iterator)
    local key = pair.key
    local value = pair.value
    local entry = {
      key = ada_string_to_lua(key),
      value = ada_string_to_lua(value),
    }
    return invariant_state + 1, entry
  end
end
local function static_ipairs(search)
  local s = new(search)
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(s), lib.ada_free_search_params_entries_iter)
  return ipairs_iter, entries_iter, 0
end
function mt:__ipairs()
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(self[1]), lib.ada_free_search_params_entries_iter)
  return ipairs_iter, entries_iter, 0
end


local function each_iter(entries_iterator)
  if lib.ada_search_params_entries_iter_has_next(entries_iterator) then
    local pair = lib.ada_search_params_entries_iter_next(entries_iterator)
    local key = pair.key
    local value = pair.value
    return {
      key = ada_string_to_lua(key),
      value = ada_string_to_lua(value),
    }
  end
end
local function static_each(search)
  local s = new(search)
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(s), lib.ada_free_search_params_entries_iter)
  return each_iter, entries_iter
end
function mt:each()
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(self[1]), lib.ada_free_search_params_entries_iter)
  return each_iter, entries_iter
end


local function each_key_iter(keys_iterator)
  if lib.ada_search_params_keys_iter_has_next(keys_iterator) then
    local key = ada_string_to_lua(lib.ada_search_params_keys_iter_next(keys_iterator))
    return key
  end
end
local function static_each_key(search)
  local s = new(search)
  local keys_iter = ffi_gc(lib.ada_search_params_get_keys(s), lib.ada_free_search_params_keys_iter)
  return each_key_iter, keys_iter
end
function mt:each_key()
  local keys_iter = ffi_gc(lib.ada_search_params_get_keys(self[1]), lib.ada_free_search_params_keys_iter)
  return each_key_iter, keys_iter
end


local function each_value_iter(values_iterator)
  if lib.ada_search_params_values_iter_has_next(values_iterator) then
    local value = ada_string_to_lua(lib.ada_search_params_values_iter_next(values_iterator))
    return value
  end
end
local function static_each_value(search)
  local s = new(search)
  local values_iter = ffi_gc(lib.ada_search_params_get_values(s), lib.ada_free_search_params_values_iter)
  return each_value_iter, values_iter
end
function mt:each_value()
  local values_iter = ffi_gc(lib.ada_search_params_get_values(self[1]), lib.ada_free_search_params_values_iter)
  return each_value_iter, values_iter
end


function mt:tostring()
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(self[1]))
  return r
end
function mt:__tostring()
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(self[1]))
  return r
end


function mt:__len()
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(self[1]))
  return #r
end


return {
  parse = parse,
  sort = sort,
  append = append,
  set = set,
  remove = remove,
  remove_value = remove_value,
  has = has,
  has_value = has_value,
  get = get,
  get_all = get_all,
  size = size,
  pairs = static_pairs,
  ipairs = static_ipairs,
  each = static_each,
  each_key = static_each_key,
  each_value = static_each_value,
}
