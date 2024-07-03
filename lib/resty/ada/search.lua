---
-- Ada URL search parameters
--
-- See: <https://url.spec.whatwg.org/#interface-urlsearchparams>
--
-- @classmod search


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


local function new(search)
  assert(type(search) == "string", "invalid search")
  local s = ffi_gc(lib.ada_parse_search_params(search, #search), lib.ada_free_search_params)
  return s
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


local function each_key_iter(keys_iterator)
  if lib.ada_search_params_keys_iter_has_next(keys_iterator) then
    local key = ada_string_to_lua(lib.ada_search_params_keys_iter_next(keys_iterator))
    return key
  end
end


local function each_value_iter(values_iterator)
  if lib.ada_search_params_values_iter_has_next(values_iterator) then
    local value = ada_string_to_lua(lib.ada_search_params_values_iter_next(values_iterator))
    return value
  end
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


local mt = {}


mt.__index = mt



local function parse(search)
  local s = new(search)
  local self = setmetatable({ s }, mt)
  return self
end


---
-- Has Methods
-- @section has-methods


---
-- Checks whether the search has a key.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-has>
--
-- @function has
-- @tparam string key search parameter name to check
-- @treturn boolean `true` if search has the key, otherwise `false`
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:has("a")
function mt:has(key)
  local r = lib.ada_search_params_has(self[1], key, #key)
  return r
end


---
-- Checks whether the search has a key with a specific value.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-has>
--
-- @function has_value
-- @tparam string key search parameter name to check
-- @tparam string value search parameter value to check
-- @treturn boolean `true` if search has the key with the value, otherwise `false`
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:has_value("a", "b")
function mt:has_value(key, value)
  local r = lib.ada_search_params_has_value(self[1], key, #key, value, #value)
  return r
end


---
-- Get Methods
-- @section get-methods


---
-- Get search parameter's value.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-get>
--
-- @function get
-- @tparam string key search parameter name
-- @treturn string|nil parameter value or `nil`
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:get("a")
function mt:get(key)
  local r = ada_string_to_lua(lib.ada_search_params_get(self[1], key, #key))
  return r
end


---
-- Get all the search parameter's values.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-getall>
--
-- @function get_all
-- @tparam string key search parameter name
-- @treturn table array of all the values (or an empty array)
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:get_all("a")
function mt:get_all(key)
  local r = ada_strings_to_lua(lib.ada_search_params_get_all(self[1], key, #key))
  return r
end


---
-- Set Methods
-- @section set-methods


---
-- Set the search parameter's value.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-set>
--
-- @function set
-- @tparam string key search parameter name
-- @tparam string value search parameter value
-- @treturn search self
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:set("a", "g"):tostring()
function mt:set(key, value)
  lib.ada_search_params_set(self[1], key, #key, value, #value)
  return self
end


---
-- Append value to the the search parameter.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-append>
--
-- @function append
-- @tparam string key search parameter name
-- @tparam string value search parameter value
-- @treturn search self
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:append("a", "g"):tostring()
function mt:append(key, value)
  lib.ada_search_params_append(self[1], key, #key, value, #value)
  return self
end


---
-- Remove Methods
-- @section remove-methods


---
-- Remove search parameter.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-delete>
--
-- @function remove
-- @tparam string key search parameter name
-- @treturn search self
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:remove("a"):tostring()
function mt:remove(key)
  lib.ada_search_params_remove(self[1], key, #key)
  return self
end


---
-- Remove search parameter's value.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-delete>
--
-- @function remove_value
-- @tparam string key search parameter name
-- @tparam string value search parameter's value
-- @treturn search self
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:remove_value("a", "b"):tostring()
function mt:remove_value(key, value)
  lib.ada_search_params_remove_value(self[1], key, #key, value, #value)
  return self
end


---
-- Iterate Methods
-- @section iterate-methods


---
-- Iterate over search parameters.
--
-- @function each
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- for param in search:each() do
--   print(param.key, " = ", param.value)
-- end
function mt:each()
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(self[1]), lib.ada_free_search_params_entries_iter)
  return each_iter, entries_iter
end


---
-- Iterate over each key in search parameters.
--
-- @function each_key
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- for key in search:each_key() do
--   print("key: ", key)
-- end
function mt:each_key()
  local keys_iter = ffi_gc(lib.ada_search_params_get_keys(self[1]), lib.ada_free_search_params_keys_iter)
  return each_key_iter, keys_iter
end


---
-- Iterate over each value in search parameters.
--
-- @function each_value
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- for value in search:each_value() do
--   print("value: ", value)
-- end
function mt:each_value()
  local values_iter = ffi_gc(lib.ada_search_params_get_values(self[1]), lib.ada_free_search_params_values_iter)
  return each_value_iter, values_iter
end


---
-- Iterate over each key and value in search parameters.
--
-- @function pairs
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- for key, value in search:pairs() do
--   print(key, " = ", value)
-- end
function mt:pairs()
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(self[1]), lib.ada_free_search_params_entries_iter)
  return pairs_iter, entries_iter
end


---
-- Iterate over each parameter in search parameters.
--
-- @function ipairs
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- for i, param in search:ipairs() do
--   print(param.key, " = ", param.value)
-- end
function mt:ipairs()
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(self[1]), lib.ada_free_search_params_entries_iter)
  return ipairs_iter, entries_iter, 0
end


---
-- Other Methods
-- @section other-methods


---
-- Return search parameters as a string.
--
-- See: <https://url.spec.whatwg.org/#urlsearchparams-stringification-behavior>
--
-- @function tostring
-- @treturn string string presentation of the search parameters
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:tostring()
function mt:tostring()
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(self[1]))
  return r
end


---
-- Sort search parameters.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-sort>
--
-- @function sort
-- @treturn search self
--
-- @usage
-- local search = require("resty.ada.search").parse("e=f&c=d&a=b")
-- local result = search:sort():tostring()
function mt:sort()
  lib.ada_search_params_sort(self[1])
  return self
end


---
-- Count search parameters.
--
-- @function size
-- @treturn number search parameters count
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:size()
function mt:size()
  local r = tonumber(lib.ada_search_params_size(self[1]), 10)
  return r
end


---
-- Meta Methods
-- @section meta-methods


---
-- Iterate over each key and value in search parameters.
--
-- @function __pairs
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- for key, value in pairs(search) do
--   print(key, " = ", value)
-- end
mt.__pairs = mt.pairs


---
-- Iterate over each parameter in search parameters.
--
-- @function __pairs
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- for i, param in ipairs(search) do
--   print(i, ". ", param.key, " = ", param.value)
-- end
mt.__ipairs = mt.ipairs


---
-- Return search parameters as a string.
--
-- See: <https://url.spec.whatwg.org/#urlsearchparams-stringification-behavior>
--
-- @function __tostring
-- @treturn string string presentation of the search parameters
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = tostring(search)
mt.__tostring = mt.tostring


---
-- Count search parameters.
--
-- @function __len
-- @treturn number search parameters count
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = #search
mt.__len = mt.size


---
-- Provides URL search parameter parsing and manipulation functionality.
--
-- See: <https://url.spec.whatwg.org/#interface-urlsearchparams>
--
-- @module resty.ada.search


---
-- Constructors
-- @section constructors


---
-- Parses search and returns an instance of Ada URL Search.
--
-- See: <https://url.spec.whatwg.org/#interface-urlsearchparams>
--
-- @function parse
-- @tparam string search search to parse
-- @treturn search Ada URL Search instance
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")


---
-- Has Functions
-- @section has-functions


---
-- Checks whether the search has a key.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-has>
--
-- @function has
-- @tparam string search search to parse
-- @tparam string key search parameter name to check
-- @treturn boolean `true` if search has the key, otherwise `false`
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.has("a=b&c=d&e=f", "a")
local function has(search, key)
  local s = new(search)
  local r = lib.ada_search_params_has(s, key, #key)
  return r
end


---
-- Checks whether the search has a key with a specific value.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-has>
--
-- @function has_value
-- @tparam string search search to parse
-- @tparam string key search parameter name to check
-- @tparam string value search parameter value to check
-- @treturn boolean `true` if search has the key with the value, otherwise `false`
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.has_value("a=b&c=d&e=f", "a", "b")
local function has_value(search, key, value)
  local s = new(search)
  local r =  lib.ada_search_params_has_value(s, key, #key, value, #value)
  return r
end


---
-- Get Functions
-- @section get-functions


---
-- Get search parameter's value.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-get>
--
-- @function get
-- @tparam string search search to parse
-- @tparam string key search parameter name
-- @treturn string|nil parameter value or `nil`
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.get("a=b&c=d&e=f", "a")
local function get(search, key)
  local r = ada_string_to_lua(lib.ada_search_params_get(new(search), key, #key))
  return r
end


---
-- Get all the search parameter's values.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-getall>
--
-- @function get_all
-- @tparam string search search to parse
-- @tparam string key search parameter name
-- @treturn table array of all the values (or an empty array)
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.get_all("a=b&c=d&e=f", "a")
local function get_all(search, key)
  local r = ada_strings_to_lua(lib.ada_search_params_get_all(new(search), key, #key))
  return r
end


---
-- Set Functions
-- @section set-functions


---
-- Set the search parameter's value.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-set>
--
-- @function set
-- @tparam string search search to parse
-- @tparam string key search parameter name
-- @tparam string value search parameter value
-- @treturn string string presentation of the search parameters
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.set("a=b&c=d&e=f", "a", "g")
local function set(search, key, value)
  local s = new(search)
  lib.ada_search_params_set(s, key, #key, value, #value)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end


---
-- Append value to the the search parameter.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-append>
--
-- @function append
-- @tparam string search search to parse
-- @tparam string key search parameter name
-- @tparam string value search parameter value
-- @treturn string string presentation of the search parameters
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.append("a=b&c=d&e=f", "a", "g")
local function append(search, key, value)
  local s = new(search)
  lib.ada_search_params_append(s, key, #key, value, #value)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end


---
-- Remove Functions
-- @section remove-functions


---
-- Remove search parameter.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-delete>
--
-- @function remove
-- @tparam string search search to parse
-- @tparam string key search parameter name
-- @treturn string string presentation of the search parameters
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.remove("a=b&c=d&e=f", "a")
local function remove(search, key)
  local s = new(search)
  lib.ada_search_params_remove(s, key, #key)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end


---
-- Remove search parameter's value.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-delete>
--
-- @function remove_value
-- @tparam string search search to parse
-- @tparam string key search parameter name
-- @tparam string value search parameter's value
-- @treturn string string presentation of the search parameters
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.remove_value("a=b&c=d&e=f", "a", "b")
local function remove_value(search, key, value)
  local s = new(search)
  lib.ada_search_params_remove_value(s, key, #key, value, #value)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end


---
-- Iterate Functions
-- @section iterate-functions


---
-- Iterate over search parameters.
--
-- @function each
-- @tparam string search search to parse
-- @treturn function iterator function
-- @treturn cdata state
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- for param in search.each("a=b&c=d&e=f") do
--   print(param.key, " = ", param.value)
-- end
local function each(search)
  local s = new(search)
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(s), lib.ada_free_search_params_entries_iter)
  return each_iter, entries_iter
end


---
-- Iterate over each key in search parameters.
--
-- @function each_key
-- @tparam string search search to parse
-- @treturn function iterator function
-- @treturn cdata state
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- for key in search.each_key("a=b&c=d&e=f") do
--   print("key: ", key)
-- end
local function each_key(search)
  local s = new(search)
  local keys_iter = ffi_gc(lib.ada_search_params_get_keys(s), lib.ada_free_search_params_keys_iter)
  return each_key_iter, keys_iter
end


---
-- Iterate over each value in search parameters.
--
-- @function each_value
-- @tparam string search search to parse
-- @treturn function iterator function
-- @treturn cdata state
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- for value in search.each_value("a=b&c=d&e=f") do
--   print("value: ", value)
-- end
local function each_value(search)
  local s = new(search)
  local values_iter = ffi_gc(lib.ada_search_params_get_values(s), lib.ada_free_search_params_values_iter)
  return each_value_iter, values_iter
end


---
-- Iterate over each key and value in search parameters.
--
-- @function pairs
-- @tparam string search search to parse
-- @treturn function iterator function
-- @treturn cdata state
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- for key, value in search.pairs("a=b&c=d&e=f") do
--   print(key, " = ", value)
-- end
local function search_pairs(search)
  local s = new(search)
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(s), lib.ada_free_search_params_entries_iter)
  return pairs_iter, entries_iter
end


---
-- Iterate over each parameter in search parameters.
--
-- @function ipairs
-- @tparam string search search to parse
-- @treturn function iterator function
-- @treturn cdata state
-- @raise error when search is not a string
--
-- @usage
-- for i, param in search.ipairs("a=b&c=d&e=f") do
--   print(i, ". ", param.key, " = ", param.value)
-- end
local function search_ipairs(search)
  local s = new(search)
  local entries_iter = ffi_gc(lib.ada_search_params_get_entries(s), lib.ada_free_search_params_entries_iter)
  return ipairs_iter, entries_iter, 0
end


---
-- Other Functions
-- @section other-functions


---
-- Sort search parameters.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-sort>
--
-- @function sort
-- @tparam string search search to parse
-- @treturn string string presentation of the search parameters
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.sort("e=f&c=d&a=b")
local function sort(search)
  local s = new(search)
  lib.ada_search_params_sort(s)
  local r = ada_owned_string_to_lua(lib.ada_search_params_to_string(s))
  return r
end


---
-- Count search parameters.
--
-- @function size
-- @tparam string search search to parse
-- @treturn number search parameters count
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.size("a=b&c=d&e=f")
local function size(search)
  local r = tonumber(lib.ada_search_params_size(new(search)), 10)
  return r
end


return {
  parse = parse,
  has = has,
  has_value = has_value,
  get = get,
  get_all = get_all,
  set = set,
  append = append,
  remove = remove,
  remove_value = remove_value,
  each = each,
  each_key = each_key,
  each_value = each_value,
  pairs = search_pairs,
  ipairs = search_ipairs,
  sort = sort,
  size = size,
}
