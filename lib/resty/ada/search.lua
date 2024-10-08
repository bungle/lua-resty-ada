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
local number_to_string = utils.number_to_string


local ffi_gc = require("ffi").gc


local type = type
local next = next
local pairs = pairs
local assert = assert
local tonumber = tonumber
local setmetatable = setmetatable


local function each_iter(entries_iterator)
  if lib.ada_search_params_entries_iter_has_next(entries_iterator) then
    local pair = lib.ada_search_params_entries_iter_next(entries_iterator)
    return {
      key = ada_string_to_lua(pair.key),
      value = ada_string_to_lua(pair.value),
    }
  end

  ffi_gc(entries_iterator, nil)
  lib.ada_free_search_params_entries_iter(entries_iterator)
end


local function each_key_iter(keys_iterator)
  if lib.ada_search_params_keys_iter_has_next(keys_iterator) then
    local key = ada_string_to_lua(lib.ada_search_params_keys_iter_next(keys_iterator))
    return key
  end

  ffi_gc(keys_iterator, nil)
  lib.ada_free_search_params_keys_iter(keys_iterator)
end


local function each_value_iter(values_iterator)
  if lib.ada_search_params_values_iter_has_next(values_iterator) then
    local value = ada_string_to_lua(lib.ada_search_params_values_iter_next(values_iterator))
    return value
  end

  ffi_gc(values_iterator, nil)
  lib.ada_free_search_params_values_iter(values_iterator)
end


local function pairs_iter(entries_iterator)
  if lib.ada_search_params_entries_iter_has_next(entries_iterator) then
    local pair = lib.ada_search_params_entries_iter_next(entries_iterator)
    local key = ada_string_to_lua(pair.key)
    local value = ada_string_to_lua(pair.value)
    return key, value
  end

  ffi_gc(entries_iterator, nil)
  lib.ada_free_search_params_entries_iter(entries_iterator)
end


local function ipairs_iter(entries_iterator, invariant_state)
  if lib.ada_search_params_entries_iter_has_next(entries_iterator) then
    local pair = lib.ada_search_params_entries_iter_next(entries_iterator)
    local entry = {
      key = ada_string_to_lua(pair.key),
      value = ada_string_to_lua(pair.value),
    }
    return invariant_state + 1, entry
  end

  ffi_gc(entries_iterator, nil)
  lib.ada_free_search_params_entries_iter(entries_iterator)
end


local mt = {}


mt.__index = mt


---
-- Decode Methods
-- @section decode-methods


---
-- Decodes search parameters and returns a Lua table of them.
--
-- If same parameter appears multiple times, only the value of the
-- first is returned.
--
-- An example return value:
--    {
--      key1 = "value",
--      key2 = "value2",
--    }
--
-- @function decode
-- @treturn table a table of all search parameters (a string:string map).
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f&a=g")
-- local result = search:decode()
function mt:decode()
  if self:size() == 0 then
    return {}
  end
  local r = {}
  for k in self:each_key() do
    if not r[k] then
      r[k] = self:get(k)
    end
  end
  return r
end


---
-- Decodes all search parameters and returns a Lua table of them.
--
-- An example return value:
--    {
--      key1 = { "first", "second", },
--      key2 = { "value" },
--    }
--
-- @function decode
-- @treturn table a table of all search parameters (a string:table [array] map).
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&a=c&d=e")
-- local result = search:decode_all()
function mt:decode_all()
  if self:size() == 0 then
    return {}
  end
  local r = {}
  for k in self:each_key() do
    if not r[k] then
      r[k] = self:get_all(k)
    end
  end
  return r
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
-- @raise error when key is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:has("a")
function mt:has(key)
  assert(type(key) == "string", "invalid key")
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
-- @raise error when key or value is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:has_value("a", "b")
function mt:has_value(key, value)
  assert(type(key) == "string", "invalid key")
  assert(type(value) == "string", "invalid value")
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
-- @raise error when key is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:get("a")
function mt:get(key)
  assert(type(key) == "string", "invalid key")
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
-- @raise error when key is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:get_all("a")
function mt:get_all(key)
  assert(type(key) == "string", "invalid key")
  local r = ada_strings_to_lua(lib.ada_search_params_get_all(self[1], key, #key))
  return r
end


---
-- Set Methods
-- @section set-methods


---
-- Sets (or resets) the search parameters.
--
-- @function reset
-- @tparam string search search to parse
-- @treturn search self
-- @raise error when search is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- print(search:reset("g=h"):tostring())
function mt:reset(search)
  assert(type(search) == "string", "invalid search")
  lib.ada_search_params_reset(self[1], search, #search)
  return self
end


---
-- Set the search parameter's value.
--
-- See: <https://url.spec.whatwg.org/#dom-urlsearchparams-set>
--
-- @function set
-- @tparam string key search parameter name
-- @tparam string value search parameter value
-- @treturn search self
-- @raise error when key or value is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:set("a", "g"):tostring()
function mt:set(key, value)
  assert(type(key) == "string", "invalid key")
  assert(type(value) == "string", "invalid value")
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
-- @raise error when key or value is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:append("a", "g"):tostring()
function mt:append(key, value)
  assert(type(key) == "string", "invalid key")
  assert(type(value) == "string", "invalid value")
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
-- @raise error when key is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:remove("a"):tostring()
function mt:remove(key)
  assert(type(key) == "string", "invalid key")
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
-- @raise error when key or value is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- local result = search:remove_value("a", "b"):tostring()
function mt:remove_value(key, value)
  assert(type(key) == "string", "invalid key")
  assert(type(value) == "string", "invalid value")
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
-- Destructor Method
-- @section destructor-method


---
-- Explicitly destroys the Ada URL Search instance and frees the memory.
--
-- After calling this function, further calls will result runtime error.
-- If this is not explicitly called, the memory is freed with garbage
-- collector.
--
-- @function free
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
-- search:free()
function mt:free()
  ffi_gc(self[1], nil)
  lib.ada_free_search_params(self[1])
  self[1] = nil
  setmetatable(self, nil)
end


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
local function parse(search)
  assert(type(search) == "string", "invalid search")
  return setmetatable({
    ffi_gc(lib.ada_parse_search_params(search, #search), lib.ada_free_search_params)
  }, mt)
end


local S = parse("") -- just a dummy init value for this singleton


---
-- Encode and Decode Functions
-- @section encode-and-decode-function


local function encode_value(v)
  if v == true or v == "" then
    return ""
  end

  if type(v) == "number" then
    v = number_to_string(v)
  end

  return v
end


---
-- Encodes search parameters and returns an query string.
--
-- * only `string` keys are allowed.
-- * only `string`, `boolean` and `number` values are allowed or an array of them
-- * `false` value is treated as missing (same as `nil`)
-- * `true` returns `""` (empty string)
-- * negative and positive `inf` and `NaN` are not allowed as numbers in values
--
-- When passing a table the keys will be sorted and with string the given order
-- is preserved.
--
-- @function encode
-- @tparam table|string params search parameters to encode (either a `table` or `string`)
-- @treturn string encoded query string
-- @raise error when search or key is not a table or string, or when the rules above are not followed
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.encode({
--   g = "h",
--   a = { "f", "b", },
--   c = "d",
-- })
local function encode(params)
  if type(params) == "table" then
    if not next(params) then
      return ""
    end

    S:reset("")

    for k, v in pairs(params) do
      if v ~= false then
        if type(v) == "table" then
          for i = 1, #v do
            if v[i] then
              S:append(k, encode_value(v[i]))
            end
          end

        else
          S:append(k, encode_value(v))
        end
      end
    end

    S:sort()

  else
    if params == "" or params == "?" then
      return ""
    end

    S:reset(params)
  end

  local r = S:tostring()
  return r
end


---
-- Decodes search parameters and returns a Lua table of them.
--
-- If same parameter appears multiple times, only the value of the
-- first is returned.
--
-- Given the following query string:
--    "a=b&c=d&e=f&a=g"
--
-- The following table is returned:
--    {
--      a = "b",
--      c = "d",
--      e = "f",
--    }
--
-- @function decode
-- @tparam string search search to parse
-- @treturn table a table of all search parameters (a string:string map).
-- @raise error when search or key is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.decode("a=b&c=d&e=f&a=g")
local function decode(search)
  local r = S:reset(search):decode()
  return r
end


---
-- Decodes all search parameters and returns a Lua table of them.
--
-- Given the following query string:
--    "a=b&a=c&d=e""
--
-- The following table is returned:
--    {
--      a = { "b", "c" },
--      d = { "e" },
--    }
--
-- @function decode_all
-- @tparam string search search to parse
-- @treturn table a table of all search parameters (a string:table [array] map).
-- @raise error when search or key is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.decode_all("a=b&a=c&d=e")
local function decode_all(search)
  local r = S:reset(search):decode_all()
  return r
end


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
-- @raise error when search or key is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.has("a=b&c=d&e=f", "a")
local function has(search, key)
  local r = S:reset(search):has(key)
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
-- @raise error when search, key or value is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.has_value("a=b&c=d&e=f", "a", "b")
local function has_value(search, key, value)
  local r = S:reset(search):has_value(key, value)
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
-- @raise error when search or key is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.get("a=b&c=d&e=f", "a")
local function get(search, key)
  local r = S:reset(search):get(key)
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
-- @raise error when search or key is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.get_all("a=b&c=d&e=f", "a")
local function get_all(search, key)
  local r = S:reset(search):get_all(key)
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
-- @raise error when search, key or value is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.set("a=b&c=d&e=f", "a", "g")
local function set(search, key, value)
  local r = S:reset(search):set(key, value):tostring()
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
-- @raise error when search, key or value is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.append("a=b&c=d&e=f", "a", "g")
local function append(search, key, value)
  local r = S:reset(search):append(key, value):tostring()
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
-- @raise error when search or key is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.remove("a=b&c=d&e=f", "a")
local function remove(search, key)
  local r = S:reset(search):remove(key):tostring()
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
-- @raise error when search, key or value is not a string
--
-- @usage
-- local search = require("resty.ada.search")
-- local result = search.remove_value("a=b&c=d&e=f", "a", "b")
local function remove_value(search, key, value)
  local r = S:reset(search):remove_value(key, value):tostring()
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
  local iterator, invariant_state = S:reset(search):each()
  return iterator, invariant_state
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
  local iterator, invariant_state = S:reset(search):each_key()
  return iterator, invariant_state
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
  local iterator, invariant_state = S:reset(search):each_value()
  return iterator, invariant_state
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
  local iterator, invariant_state = S:reset(search):pairs()
  return iterator, invariant_state
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
  local iterator, invariant_state, initial_value = S:reset(search):ipairs()
  return iterator, invariant_state, initial_value
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
  local r = S:reset(search):sort():tostring()
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
  local r = S:reset(search):size()
  return r
end


return {
  parse = parse,
  encode = encode,
  decode = decode,
  decode_all = decode_all,
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
