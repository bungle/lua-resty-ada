---
-- Ada URL
--
-- See: <https://url.spec.whatwg.org/#url-representation>
--
-- @classmod url


local lib = require("resty.ada.lib")
local utils = require("resty.ada.utils")
local search = require("resty.ada.search")


local ada_string_to_lua = utils.ada_string_to_lua
local ada_owned_string_to_lua = utils.ada_owned_string_to_lua



local ffi = require("ffi")
local ffi_gc = ffi.gc


local fmt = string.format
local type = type
local assert = assert
local tonumber = tonumber
local setmetatable = setmetatable


local _OMITTED = 0xffffffff


local _VERSION = "1.0.0"


local function parse_component(c, raw)
  if c == _OMITTED then
    return
  end
  return raw and c or c + 1
end


local mt = {
  _VERSION = _VERSION,
}


mt.__index = mt


---
-- Validate Methods
-- @section validate-methods


---
-- Checks whether the URL is valid.
--
-- @function is_valid
-- @treturn boolean `true` if URL is valid, otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:is_valid()
function mt:is_valid()
  local r = lib.ada_is_valid(self[1])
  return r
end


---
-- Has Methods
-- @section has-methods


---
-- Checks whether the URL has credentials.
--
-- A URL includes credentials if its username or password is not the empty string.
--
-- @function has_credentials
-- @treturn boolean `true` if URL has credentials, otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:has_credentials()
function mt:has_credentials()
  local r = lib.ada_has_credentials(self[1])
  return r
end


---
-- Checks whether the URL has a non-empty username.
--
-- @function has_non_empty_username
-- @treturn boolean `true` if URL has a non-empty username, otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:has_non_empty_username()
function mt:has_non_empty_username()
  local r = lib.ada_has_non_empty_username(self[1])
  return r
end


---
-- Checks whether the URL has a password.
--
-- @function has_password
-- @treturn boolean `true` if URL has a password, otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:has_password()
function mt:has_password()
  local r = lib.ada_has_password(self[1])
  return r
end


---
-- Checks whether the URL has a non-empty password.
--
-- @function has_non_empty_password
-- @treturn boolean `true` if URL has a non-empty password, otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:has_non_empty_password()
function mt:has_non_empty_password()
  local r = lib.ada_has_non_empty_password(self[1])
  return r
end


---
-- Checks whether the URL has a hostname (included an empty host).
--
-- @function has_hostname
-- @treturn boolean `true` if URL has a hostname (included an empty host), otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:has_hostname()
function mt:has_hostname()
  local r = lib.ada_has_hostname(self[1])
  return r
end


---
-- Checks whether the URL has an host but it is the empty string.
--
-- @function has_empty_hostname
-- @treturn boolean `true` if URL has an empty hostname, otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:has_empty_hostname()
function mt:has_empty_hostname()
  local r = lib.ada_has_empty_hostname(self[1])
  return r
end


---
-- Checks whether the URL has a (non default) port.
--
-- @function has_port
-- @treturn boolean `true` if URL has a (non default) port, otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:has_port()
function mt:has_port()
  local r = lib.ada_has_port(self[1])
  return r
end


---
-- Checks whether the URL has a search component.
--
-- @function has_search
-- @treturn boolean `true` if URL has a search, otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:has_search()
function mt:has_search()
  local r = lib.ada_has_search(self[1])
  return r
end


---
-- Checks whether the URL has a hash component.
--
-- @function has_hash
-- @treturn boolean `true` if URL has a hash, otherwise `false`
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:has_hash()
function mt:has_hash()
  local r = lib.ada_has_hash(self[1])
  return r
end


---
-- Get Methods
-- @section get-methods


---
-- Get URL component positions in a string (Lua 1-based indexing).
--
--    https://user:pass@example.com:1234/foo/bar?baz#quux
--          |     |    |          | ^^^^|       |   |
--          |     |    |          | |   |       |   ------ hash_start
--          |     |    |          | |   |       ---------- search_start
--          |     |    |          | |   ------------------ pathname_start
--          |     |    |          | ---------------------- port
--          |     |    |          ------------------------ host_end
--          |     |    ----------------------------------- host_start
--          |     ---------------------------------------- username_end
--          ---------------------------------------------- protocol_end
--
-- Given a following URL:
--    https://user:pass@example.com:1234/foo/bar?baz#quux
--
-- This function will return following table:
--
--    {
--      protocol_end = 7,
--      username_end = 13,
--      host_start = 18,
--      host_end = 29,
--      port = 1234,
--      pathname_start = 35,
--      search_start = 43,
--      hash_start = 47,
--    }
--
-- @function get_components
-- @treturn table table of URL components (or their positions)
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_components()
function mt:get_components()
  local c = lib.ada_get_components(self[1])
  return {
    protocol_end   = parse_component(c.protocol_end),
    username_end   = parse_component(c.username_end),
    host_start     = parse_component(c.host_start),
    host_end       = parse_component(c.host_end, true),
    port           = parse_component(c.port, true),
    pathname_start = parse_component(c.pathname_start),
    search_start   = parse_component(c.search_start),
    hash_start     = parse_component(c.hash_start),
  }
end


---
-- Get URL in a normalized form.
--
-- See: <https://url.spec.whatwg.org/#dom-url-href>
-- See: <https://url.spec.whatwg.org/#concept-url-serializer>
--
-- @function get_href
-- @treturn string URL in a normalized form
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_href()
function mt:get_href()
  local r = ada_string_to_lua(lib.ada_get_href(self[1]))
  return r
end


---
-- Get protocol from the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-protocol>
--
-- @function get_protocol
-- @treturn string protocol part of the URL
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_protocol()
function mt:get_protocol()
  local r = ada_string_to_lua(lib.ada_get_protocol(self[1]))
  return r
end


---
-- Get scheme type from the URL.
--
-- See: <https://url.spec.whatwg.org/#url-miscellaneous>
--
-- Scheme type definitions:
--
--    0 = HTTP
--    1 = NOT_SPECIAL
--    2 = HTTPS
--    3 = WS
--    4 = FTP
--    5 = WSS
--    6 = FILE
--
-- @function get_scheme_type
-- @treturn number scheme type of the URL
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_scheme_type()
function mt:get_scheme_type()
  local r = lib.ada_get_scheme_type(self[1])
  return r
end


---
-- Get origin of the URL.
--
-- See: <https://url.spec.whatwg.org/#concept-url-origin>
--
-- @function get_origin
-- @treturn string origin of the URL
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_origin()
function mt:get_origin()
  local r = ada_owned_string_to_lua(lib.ada_get_origin(self[1]))
  return r
end


---
-- Get URL's username.
--
-- See: <https://url.spec.whatwg.org/#dom-url-username>
--
-- @function get_username
-- @treturn string URL's username
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_username()
function mt:get_username()
  local r = ada_string_to_lua(lib.ada_get_username(self[1]))
  return r
end


---
-- Get URL's password.
--
-- See: <https://url.spec.whatwg.org/#dom-url-password>
--
-- @function get_password
-- @treturn string URL's password
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_password()
function mt:get_password()
  local r = ada_string_to_lua(lib.ada_get_password(self[1]))
  return r
end


---
-- Get URL's host, serialized, followed by U+003A (:) and url's port,
-- serialized.
--
-- See: <https://url.spec.whatwg.org/#dom-url-host>
--
-- @function get_host
-- @treturn string URL's host
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_host()
function mt:get_host()
  local r = ada_string_to_lua(lib.ada_get_host(self[1]))
  return r
end


---
-- Get  URL's host (name only), serialized.
--
-- When there is no host, this function returns the empty string.
--
-- See: <https://url.spec.whatwg.org/#dom-url-hostname>
--
-- @function get_hostname
-- @treturn string URL's host (name only)
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_hostname()
function mt:get_hostname()
  local r = ada_string_to_lua(lib.ada_get_hostname(self[1]))
  return r
end


---
-- Get host type from the URL.
--
-- Host type definitions:
--
--    0 = DEFAULT: e.g. "https://www.google.com"
--    1 = IPV4:    e.g. "http://127.0.0.1"
--    2 = IPV6:    e.g. "http://[2001:db8:3333:4444:5555:6666:7777:8888]"
--
-- @function get_host_type
-- @treturn number scheme type of the URL
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_host_type()
function mt:get_host_type()
  local r = lib.ada_get_host_type(self[1])
  return r
end


---
-- Get URL's port.
--
-- See: <https://url.spec.whatwg.org/#dom-url-port>
--
-- @function get_port
-- @treturn number|string URL's port
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_port()
function mt:get_port()
  local r = ada_string_to_lua(lib.ada_get_port(self[1]))
  r = tonumber(r, 10) or r
  return r
end


---
-- Get URL's path.
--
-- See: <https://url.spec.whatwg.org/#dom-url-pathname>
--
-- @function get_pathname
-- @treturn string URL's path
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_pathname()
function mt:get_pathname()
  local r = ada_string_to_lua(lib.ada_get_pathname(self[1]))
  return r
end


---
-- Get URL's search (query).
--
-- Return U+003F (?), followed by URL's query.
--
-- See: <https://url.spec.whatwg.org/#dom-url-search>
--
-- @function get_search
-- @treturn string URL's query
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_search()
function mt:get_search()
  local r = ada_string_to_lua(lib.ada_get_search(self[1]))
  return r
end


---
-- Get URL's hash (fragment).
--
-- Return U+0023 (#), followed by URL's fragment.
--
-- See: <https://url.spec.whatwg.org/#dom-url-hash>
--
-- @function get_hash
-- @treturn string URL's fragment (except on errors `nil`)
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:get_hash()
function mt:get_hash()
  local r = ada_string_to_lua(lib.ada_get_hash(self[1]))
  return r
end


---
-- Set Methods
-- @section set-methods


---
-- Sets HREF (aka url) to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-href>
--
-- @function set_href
-- @tparam string href the HREF to set to the URL
-- @treturn url|nil self (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when href is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:set_protocol("wss"):get_href()
function mt:set_href(href)
  assert(type(href) == "string", "invalid href")
  if not lib.ada_set_href(self[1], href, #href) then
    return nil, "unable to set href"
  end
  return self
end


---
-- Sets protocol to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-protocol>
--
-- @function set_protocol
-- @tparam string protocol the protocol to set to the URL
-- @treturn url|nil self (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when protocol is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:set_protocol("wss"):get_href()
function mt:set_protocol(protocol)
  assert(type(protocol) == "string", "invalid protocol")
  if not lib.ada_set_protocol(self[1], protocol, #protocol) then
    return nil, "unable to set protocol"
  end
  return self
end


---
-- Sets username to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-username>
--
-- @function set_username
-- @tparam string username the username to set to the URL
-- @treturn url|nil self (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when username is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:set_username("guest"):get_href()
function mt:set_username(username)
  assert(type(username) == "string", "invalid username")
  if not lib.ada_set_username(self[1], username, #username) then
    return nil, "unable to set username"
  end
  return self
end


---
-- Sets password to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-password>
--
-- @function set_password
-- @tparam string password the password to set to the URL
-- @treturn url|nil self (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when password is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:ada_set_password("secret"):get_href()
function mt:set_password(password)
  assert(type(password) == "string", "invalid password")
  if not lib.ada_set_password(self[1], password, #password) then
    return nil, "unable to set password"
  end
  return self
end


---
-- Sets host to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-host>
--
-- @function set_host
-- @tparam string host the host to set to the URL
-- @treturn url|nil self (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when host is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:set_host("test:4321"):get_href()
function mt:set_host(host)
  assert(type(host) == "string", "invalid host")
  if not lib.ada_set_host(self[1], host, #host) then
    return nil, "unable to set host"
  end
  return self
end


---
-- Sets host (name only) to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-hostname>
--
-- @function set_hostname
-- @tparam string hostname the host (name only) to set to the URL
-- @treturn url|nil self (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when hostname is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:set_hostname("test"):get_href()
function mt:set_hostname(hostname)
  assert(type(hostname) == "string", "invalid hostname")
  if not lib.ada_set_hostname(self[1], hostname, #hostname) then
    return nil, "unable to set hostname"
  end
  return self
end


---
-- Sets port to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-port>
--
-- @function set_port
-- @tparam number|string port the port to set to the URL
-- @treturn url|nil self (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when port is not a number or a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:set_port(4321):get_href()
function mt:set_port(port)
  local t = type(port)
  if t == "number" then
    port = fmt("%d", port)
  else
    assert(t == "string", "invalid port")
  end
  if not lib.ada_set_port(self[1], port, #port) then
    return nil, "unable to set port"
  end
  return self
end


---
-- Sets path to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-pathname>
--
-- @function set_pathname
-- @tparam string path the path to set to the URL
-- @treturn url|nil self (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when pathname is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:set_pathname("foo"):get_href()
function mt:set_pathname(pathname)
  assert(type(pathname) == "string", "invalid pathname")
  if not lib.ada_set_pathname(self[1], pathname, #pathname) then
    return nil, "unable to set pathname"
  end
  return self
end


---
-- Sets search (query) to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-search>
--
-- @function set_search
-- @tparam string query the query string to set to the URL
-- @treturn url self
-- @raise error when query is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:set_search("q=1&done"):get_href()
function mt:set_search(query)
  assert(type(query) == "string", "invalid query")
  lib.ada_set_search(self[1], query, #query)
  return self
end


---
-- Sets hash (fragment) to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-hash>
--
-- @function set_hash
-- @tparam string hash the fragment to set to the URL
-- @treturn url self
-- @raise error when hash is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:set_hash("home"):get_href()
function mt:set_hash(hash)
  assert(type(hash) == "string", "invalid hash")
  lib.ada_set_hash(self[1], hash, #hash)
  return self
end


---
-- Clear Methods
-- @section clear-methods


---
-- Clear URL's port.
--
-- See: <https://url.spec.whatwg.org/#dom-url-port>
--
-- @function clear_port
-- @treturn url self
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:clear_port():get_href()
function mt:clear_port()
  lib.ada_clear_port(self[1])
  return self
end


---
-- Clear URL's search (query string).
--
-- See: <https://url.spec.whatwg.org/#dom-url-search>
--
-- @function clear_search
-- @treturn url self
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:clear_search():get_href()
function mt:clear_search()
  lib.ada_clear_search(self[1])
  return self
end


---
-- Clear URL's hash (fragment).
--
-- See: <https://url.spec.whatwg.org/#dom-url-hash>
--
-- @function clear_hash
-- @treturn url self
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:clear_hash():get_href()
function mt:clear_hash()
  lib.ada_clear_hash(self[1])
  return self
end


---
-- Search Methods
-- @section search-methods


---
-- Parses search from URL and returns an instance of Ada URL Search.
--
-- @function search_parse
-- @treturn search Ada URL Search instance
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local search = url:search_parse()
function mt:search_parse()
  local s = search.parse(self:get_search() or "")
  return s
end


---
-- Checks whether the url has a search with a key.
--
-- @function search_has
-- @tparam string key search parameter name to check
-- @treturn boolean `true` if search has the key, otherwise `false`
-- @raise error when key is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local res = url:search_has("a")
function mt:search_has(key)
  assert(type(key) == "string", "invalid key")
  local r = search.has(self:get_search() or "", key)
  return r
end


---
-- Checks whether the url has a search with a key with a specific value.
--
-- @function search_has_value
-- @tparam string key search parameter name to check
-- @tparam string value search parameter value to check
-- @treturn boolean `true` if search has the key with the value, otherwise `false`
-- @raise error when key or value is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local res = url:search_has_value("a", "b")
function mt:search_has_value(key, value)
  assert(type(key) == "string", "invalid key")
  assert(type(value) == "string", "invalid value")
  local r = search.has_value(self:get_search() or "", key, value)
  return r
end


---
-- Get URL's search parameter's value.
--
-- @function search_get
-- @tparam string key search parameter name
-- @treturn string|nil parameter value or `nil`
-- @raise error when key is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local res = url:search_get("a")
function mt:search_get(key)
  assert(type(key) == "string", "invalid key")
  local r = search.get(self:get_search() or "", key)
  return r
end


---
-- Get all the URL's search parameter's values.
--
-- @function search_get_all
-- @tparam string key search parameter name
-- @treturn table array of all the values (or an empty array)
-- @raise error when key is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local res = url:search_get_all("a")
function mt:search_get_all(key)
  assert(type(key) == "string", "invalid key")
  local r = search.get_all(self:get_search() or "", key)
  return r
end

---
-- Set the URL's search parameter's value.
--
-- @function search_set
-- @tparam string key search parameter name
-- @tparam string value search parameter value
-- @treturn url self
-- @raise error when key or value is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local res = url:search_set("a", "g"):get_href()
function mt:search_set(key, value)
  assert(type(key) == "string", "invalid key")
  assert(type(value) == "string", "invalid value")
  self:set_search(search.set(self:get_search() or "", key, value))
  return self
end


---
-- Append value to the the URL's search parameter.
--
-- @function search_append
-- @tparam string key search parameter name
-- @tparam string value search parameter value
-- @treturn url self
-- @raise error when key or value is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local res = url:search_append("a", "g"):get_href()
function mt:search_append(key, value)
  assert(type(key) == "string", "invalid key")
  assert(type(value) == "string", "invalid value")
  self:set_search(search.append(self:get_search() or "", key, value))
  return self
end


---
-- Remove search parameter from URL.
--
-- @function search_remove
-- @tparam string key search parameter name
-- @treturn url self
-- @raise error when key is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local res = url:search_remove("a"):get_href()
function mt:search_remove(key)
  assert(type(key) == "string", "invalid key")
  self:set_search(search.remove(self:get_search() or "", key))
  return self
end


---
-- Remove search parameter's value from URL.
--
-- @function search_remove_value
-- @tparam string key search parameter name
-- @tparam string value search parameter's value
-- @treturn url self
-- @raise error when key or value is not a string
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local res = url:search_remove_value("a", "b"):get_href()
function mt:search_remove_value(key, value)
  assert(type(key) == "string", "invalid key")
  assert(type(value) == "string", "invalid value")
  self:set_search(search.remove_value(self:get_search() or "", key, value))
  return self
end


---
-- Sort the URL's search parameters.
--
-- @function search_sort
-- @treturn url self
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?e=f&c=d&a=b")
-- local res = url:search_sort():get_href()
function mt:search_sort()
  self:set_search(search.sort(self:get_search() or ""))
  return self
end


---
-- Count search parameters in URL.
--
-- @function search_size
-- @treturn number search parameters count
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- local res = url:search_size()
function mt:search_size()
  local r = search.size(self:get_search() or "")
  return r
end


---
-- Iterate over search parameters in URL.
--
-- @function search_each
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- for param in url:search_each() do
--   print(param.key, " = ", param.value)
-- end
function mt:search_each()
  local each_iter, entries_iter = search.each(self:get_search() or "")
  return each_iter, entries_iter
end


---
-- Iterate over each key in parameters in URL.
--
-- @function search_each_key
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- for key in url:search_each_key() do
--   print("key: ", key)
-- end
function mt:search_each_key()
  local each_key_iter, keys_iter = search.each_key(self:get_search() or "")
  return each_key_iter, keys_iter
end


---
-- Iterate over each value in search parameters in URL.
--
-- @function search_each_value
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- for value in url:search_each_value() do
--   print("value: ", value)
-- end
function mt:search_each_value()
  local each_value_iter, values_iter = search.each_value(self:get_search() or "")
  return each_value_iter, values_iter
end


---
-- Iterate over each key and value in search parameters in URL.
--
-- @function search_pairs
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- for key, value  in url:search_pairs() do
--   print(key, " = ", value)
-- end
function mt:search_pairs()
  local pairs_iter, entries_iter = search.pairs(self:get_search() or "")
  return pairs_iter, entries_iter
end



---
-- Iterate over each parameter in search parameters in URL.
--
-- @function search_pairs
-- @treturn function iterator function
-- @treturn cdata state
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/?a=b&c=d&e=f")
-- for i, param in url:search_ipairs() do
--   print(i, ". ", param.key, " = ", param.value)
-- end
function mt:search_ipairs()
  local ipairs_iter, entries_iter, invariant_state = search.ipairs(self:get_search() or "")
  return ipairs_iter, entries_iter, invariant_state
end


---
-- Other Methods
-- @section other-methods


---
-- Get URL in a normalized form.
--
-- @function tostring
-- @treturn string URL in a normalized form
--
-- @usage
-- local url = require("resty.ada").parse("https://user:pass@host:1234/path?search#hash")
-- local res = url:tostring()
mt.tostring = mt.get_href


---
-- Meta Methods
-- @section meta-methods


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
mt.__tostring = mt.get_href


---
-- Get length of the URL.
--
-- @function __len
-- @treturn number length of the URL
--
-- @usage
-- local ada = require("resty.ada")
-- local url = ada.parse("https://user:pass@host:1234/path?search#hash")
-- local len = #url
function mt:__len()
  local r = self:get_href()
  return #r
end


---
-- Destructor Method
-- @section destructor-method


---
-- Explicitly destroys the Ada URL instance and frees the memory.
--
-- After calling this function, further calls will result runtime error.
-- If this is not explicitly called, the memory is freed with garbage
-- collector.
--
-- @function free
--
-- @usage
-- local ada = require("resty.ada")
-- local url = ada.parse("https://user:pass@host:1234/path?search#hash")
-- url:free()
function mt:free()
  ffi_gc(self[1], nil)
  lib.ada_free(self[1])
  self[1] = nil
  setmetatable(self, nil)
end


---
-- Properties
-- @section properties


---
-- @field _VERSION resty.ada version


---
-- Provides URL parsing and manipulation functionality.
--
-- See: <https://url.spec.whatwg.org/#url-representation>
--
-- @module resty.ada


---
-- Constructors
-- @section constructor-functions


---
-- Parses URL and returns an instance of Ada URL.
--
-- @function parse
-- @tparam string url url to parse
-- @treturn url|nil Ada URL instance
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see parse_with_base
--
-- @usage
-- local ada = require("resty.ada")
-- local url, err = ada.parse("https://user:pass@host:1234/path?search#hash")
local function parse(url)
  assert(type(url) == "string", "invalid url")
  local u = ffi_gc(lib.ada_parse(url, #url), lib.ada_free)
  if not lib.ada_is_valid(u) then
    return nil, "invalid url"
  end
  local self = setmetatable({ u }, mt)
  return self
end


---
-- Parses URL with base URL and returns an instance of Ada URL.
--
-- @function parse_with_base
-- @tparam string url URL (or part of it) to parse
-- @tparam string base base url to parse
-- @treturn url|nil Ada URL instance
-- @treturn nil|string error message
-- @raise error when url or base is not a string
-- @see parse
--
-- @usage
-- local ada = require("resty.ada")
-- local url, err = ada.parse_with_base("/path?search#hash",
--                                      "https://user:pass@host:1234")
local function parse_with_base(url, base)
  assert(type(url) == "string", "invalid url")
  assert(type(base) == "string", "invalid base")
  local u = ffi_gc(lib.ada_parse_with_base(url, #url, base, #base), lib.ada_free)
  if not lib.ada_is_valid(u) then
    return nil, "invalid url or base"
  end
  local self = setmetatable({ u }, mt)
  return self
end


---
-- Convert Functions
-- @section convert-functions


---
-- Converts a domain (e.g., www.google.com) possibly containing international
-- characters to an ascii domain (with punycode).
--
-- See: <https://url.spec.whatwg.org/#concept-domain-to-ascii>
--
-- It will not do percent decoding: percent decoding should be done prior to
-- calling this function. We do not remove tabs and spaces, they should have
-- been removed prior to calling this function. We also do not trim control
-- characters. We also assume that the input is not empty. We return "" on error.
--
-- This function may accept or even produce invalid domains.
--
-- We receive a UTF-8 string representing a domain name.
-- If the string is percent encoded, we apply percent decoding.
--
-- Given a domain, we need to identify its labels.
--
-- They are separated by label-separators:
--
--    U+002E (.) FULL STOP
--    U+FF0E FULLWIDTH FULL STOP
--    U+3002 IDEOGRAPHIC FULL STOP
--    U+FF61 HALFWIDTH IDEOGRAPHIC FULL STOP
--
-- They are all mapped to U+002E.
--
-- We process each label into a string that should not exceed 63 octets.
-- If the string is already punycode (starts with "xn--"), then we must
-- scan it to look for unallowed code points.
--
-- Otherwise, if the string is not pure ASCII, we need to transcode it
-- to punycode by following RFC 3454 which requires us to:
--
-- - Map characters  (see section 3),
-- - Normalize (see section 4),
-- - Reject forbidden characters,
-- - Check for right-to-left characters and if so, check all requirements (see section 6),
-- - Optionally reject based on unassigned code points (section 7).
--
-- The Unicode standard provides a table of code points with a mapping, a list
-- of forbidden code points and so forth. This table is subject to change and
-- will vary based on the implementation. For Unicode 15, the table is at
-- <https://www.unicode.org/Public/idna/15.0.0/IdnaMappingTable.txt>
--
-- The resulting strings should not exceed 255 octets according to RFC 1035
-- section 2.3.4. ICU checks for label size and domain size, but these errors
-- are ignored.
--
-- @function idna_to_ascii
-- @tparam string domain URL (or part of it) to parse
-- @treturn string|nil ascii domain
-- @raise error when domain not a string
-- @see idna_to_unicode
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.idna_to_ascii("www.7‑Eleven.com") -- www.xn--7eleven-506c.com
local function idna_to_ascii(domain)
  assert(type(domain) == "string", "invalid domain")
  local r = ada_owned_string_to_lua(lib.ada_idna_to_ascii(domain, #domain))
  return r
end


---
-- Converts possibly international ascii domain to unicode.
--
-- See: <https://www.unicode.org/reports/tr46/#ToUnicode>
--
-- @function idna_to_unicode
-- @tparam string domain URL (or part of it) to parse
-- @treturn string|nil (unicode) domain
-- @raise error when domain not a string
-- @see idna_to_ascii
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.idna_to_unicode("www.xn--7eleven-506c.com") -- www.7‑Eleven.com
local function idna_to_unicode(domain)
  assert(type(domain) == "string", "invalid domain")
  local r = ada_owned_string_to_lua(lib.ada_idna_to_unicode(domain, #domain))
  return r
end


---
-- Validate Functions
-- @section validate-functions


---
-- Checks whether the URL can be parsed.
--
-- See: <https://url.spec.whatwg.org/#dom-url-canparse>
--
-- @function can_parse
-- @tparam string url URL (or part of it) to check
-- @treturn boolean `true` if URL can be parsed, otherwise `false`
-- @see can_parse_with_base
--
-- @usage
-- local ada = require("resty.ada")
-- local ok = ada.can_parse("https://user:pass@host:1234/path?search#hash")
local function can_parse(url)
  return type(url) == "string" and lib.ada_can_parse(url, #url)
end


---
-- Checks whether the URL can be parsed with a base URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-canparse>
--
-- @function can_parse_with_base
-- @tparam string url URL (or part of it) to check
-- @tparam string base base url to check
-- @treturn boolean `true` if URL can be parsed, otherwise `false`
-- @see can_parse
--
-- @usage
-- local ada = require("resty.ada")
-- local ok = ada.can_parse_with_base("/path?search#hash",
--                                    "https://user:pass@host:1234")
local function can_parse_with_base(url, base)
  return type(url)  == "string"
     and type(base) == "string"
     and lib.ada_can_parse_with_base(url, #url, base, #base)
end


local U = parse("https://localhost") -- just a dummy init value for this singleton


local function set_url(url)
  assert(type(url) == "string", "invalid url")
  local ok = lib.ada_set_href(U[1], url, #url)
  return ok
end


---
-- Has Functions
-- @section has-functions


---
-- Checks whether the URL has credentials.
--
-- A URL includes credentials if its username or password is not the empty string.
--
-- @function has_credentials
-- @tparam string url URL (or part of it) to check
-- @treturn boolean|nil `true` if URL has credentials, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_non_empty_username
-- @see get_username
-- @see set_username
-- @see has_credentials
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.has_credentials("https://user:pass@host:1234/path?search#hash")
local function has_credentials(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:has_credentials()
  return r
end


---
-- Checks whether the URL has a non-empty username.
--
-- @function has_non_empty_username
-- @tparam string url URL (or part of it) to check
-- @treturn boolean|nil `true` if URL has a non-empty username, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see get_username
-- @see set_username
-- @see has_credentials
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.has_non_empty_username("https://user:pass@host:1234/path?search#hash")
local function has_non_empty_username(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:has_non_empty_username()
  return r
end


---
-- Checks whether the URL has a password.
--
-- @function has_password
-- @tparam string url URL (or part of it) to check
-- @treturn boolean|nil `true` if URL has a password, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_non_empty_password
-- @see get_password
-- @see set_password
-- @see has_credentials
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.has_password("https://user:pass@host:1234/path?search#hash")
local function has_password(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:has_password()
  return r
end


---
-- Checks whether the URL has a non-empty password.
--
-- @function has_non_empty_password
-- @tparam string url URL (or part of it) to check
-- @treturn boolean|nil `true` if URL has a non-empty password, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_password
-- @see get_password
-- @see set_password
-- @see has_credentials
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.has_non_empty_password("https://user:pass@host:1234/path?search#hash")
local function has_non_empty_password(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:has_non_empty_password()
  return r
end


---
-- Checks whether the URL has a hostname (included an empty host).
--
-- @function has_hostname
-- @tparam string url URL (or part of it) to check
-- @treturn boolean|nil `true` if URL has a hostname (included an empty host), otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_empty_hostname
-- @see get_hostname
-- @see set_hostname
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.has_hostname("https://user:pass@host:1234/path?search#hash")
local function has_hostname(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:has_hostname()
  return r
end


---
-- Checks whether the URL has an host but it is the empty string.
--
-- @function has_empty_hostname
-- @tparam string url URL (or part of it) to check
-- @treturn boolean|nil `true` if URL has an empty hostname, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_hostname
-- @see get_hostname
-- @see set_hostname
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.has_empty_hostname("https://user:pass@host:1234/path?search#hash")
local function has_empty_hostname(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:has_empty_hostname()
  return r
end


---
-- Checks whether the URL has a (non default) port.
--
-- @function has_port
-- @tparam string url URL (or part of it) to check
-- @treturn boolean|nil `true` if URL has a (non default) port, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see get_port
-- @see set_port
-- @see clear_port
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.has_port("https://user:pass@host:1234/path?search#hash")
local function has_port(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:has_port()
  return r
end


---
-- Checks whether the URL has a search component.
--
-- @function has_search
-- @tparam string url URL (or part of it) to check
-- @treturn boolean|nil `true` if URL has a search, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see get_search
-- @see set_search
-- @see clear_search
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.has_search("https://user:pass@host:1234/path?search#hash")
local function has_search(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:has_search()
  return r
end


---
-- Checks whether the URL has a hash component.
--
-- @function has_hash
-- @tparam string url URL (or part of it) to check
-- @treturn boolean|nil `true` if URL has a hash, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see get_hash
-- @see set_hash
-- @see clear_hash
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.has_hash("https://user:pass@host:1234/path?search#hash")
local function has_hash(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:has_hash()
  return r
end


---
-- Get Functions
-- @section get-functions


---
-- Parses URL and returns a table with URL component positions in a string (Lua 1-based indexing).
--
-- Please be careful with the output of this function as it normalizes the input string.
--
--    https://user:pass@example.com:1234/foo/bar?baz#quux
--          |     |    |          | ^^^^|       |   |
--          |     |    |          | |   |       |   ------ hash_start
--          |     |    |          | |   |       ---------- search_start
--          |     |    |          | |   ------------------ pathname_start
--          |     |    |          | ---------------------- port
--          |     |    |          ------------------------ host_end
--          |     |    ----------------------------------- host_start
--          |     ---------------------------------------- username_end
--          ---------------------------------------------- protocol_end
--
-- Given a following URL:
--    https://user:pass@example.com:1234/foo/bar?baz#quux
--
-- This function will return following table:
--
--    {
--      protocol_end = 7,
--      username_end = 13,
--      host_start = 18,
--      host_end = 29,
--      port = 1234,
--      pathname_start = 35,
--      search_start = 43,
--      hash_start = 47,
--    }
--
-- @function get_components
-- @tparam string url URL (or part of it) to from which the URL component positions are extracted
-- @treturn table|nil table of URL components (or their positions) (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_components("https://user:pass@host:1234/path?search#hash")
local function get_components(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_components()
  return r
end


---
-- Get URL in a normalized form.
--
-- See: <https://url.spec.whatwg.org/#dom-url-href>
-- See: <https://url.spec.whatwg.org/#concept-url-serializer>
--
-- @function get_href
-- @tparam string url URL (or part of it) from which to get href
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_href("https://user:pass@host:1234/path?search#hash")
local function get_href(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_href()
  return r
end


---
-- Get protocol from the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-protocol>
--
-- @function get_protocol
-- @tparam string url URL (or part of it) from which to extract the protocol
-- @treturn string|nil protocol part of the URL (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see set_protocol
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_protocol("https://user:pass@host:1234/path?search#hash")
local function get_protocol(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_protocol()
  return r
end


---
-- Get scheme type from the URL.
--
-- See: <https://url.spec.whatwg.org/#url-miscellaneous>
--
-- Scheme type definitions:
--
--    0 = HTTP
--    1 = NOT_SPECIAL
--    2 = HTTPS
--    3 = WS
--    4 = FTP
--    5 = WSS
--    6 = FILE
--
-- @function get_scheme_type
-- @tparam string url URL (or part of it) from which to get scheme type
-- @treturn number|nil scheme type of the URL (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_scheme_type("https://user:pass@host:1234/path?search#hash")
local function get_scheme_type(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_scheme_type()
  return r
end


---
-- Get origin of the URL.
--
-- See: <https://url.spec.whatwg.org/#concept-url-origin>
--
-- @function get_origin
-- @tparam string url URL (or part of it) from which to get origin
-- @treturn string|nil origin of the URL (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_origin("https://user:pass@host:1234/path?search#hash")
local function get_origin(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_origin()
  return r
end


---
-- Get URL's username.
--
-- See: <https://url.spec.whatwg.org/#dom-url-username>
--
-- @function get_username
-- @tparam string url URL (or part of it) from which to get username
-- @treturn string|nil URL's username (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_non_empty_username
-- @see set_username
-- @see has_credentials
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_username("https://user:pass@host:1234/path?search#hash")
local function get_username(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_username()
  return r
end


---
-- Get URL's password.
--
-- See: <https://url.spec.whatwg.org/#dom-url-password>
--
-- @function get_password
-- @tparam string url URL (or part of it) from which to get password
-- @treturn string|nil URL's password (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_password
-- @see has_non_empty_password
-- @see set_password
-- @see has_credentials
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_password("https://user:pass@host:1234/path?search#hash")
local function get_password(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_password()
  return r
end


---
-- Get URL's host, serialized, followed by U+003A (:) and url's port,
-- serialized.
--
-- See: <https://url.spec.whatwg.org/#dom-url-host>
--
-- @function get_host
-- @tparam string url URL (or part of it) from which to get host
-- @treturn string|nil URL's host (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see set_host
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_host("https://user:pass@host:1234/path?search#hash")
local function get_host(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_host()
  return r
end


---
-- Get  URL's host (name only), serialized.
--
-- When there is no host, this function returns the empty string.
--
-- See: <https://url.spec.whatwg.org/#dom-url-hostname>
--
-- @function get_hostname
-- @tparam string url URL (or part of it) from which to get host (name only)
-- @treturn string|nil URL's host (name only) (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_hostname
-- @see has_empty_hostname
-- @see set_hostname
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_hostname("https://user:pass@host:1234/path?search#hash")
local function get_hostname(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_hostname()
  return r
end


---
-- Get host type from the URL.
--
-- Host type definitions:
--
--    0 = DEFAULT: e.g. "https://www.google.com"
--    1 = IPV4:    e.g. "http://127.0.0.1"
--    2 = IPV6:    e.g. "http://[2001:db8:3333:4444:5555:6666:7777:8888]"
--
-- @function get_host_type
-- @tparam string url URL (or part of it) from which to get scheme type
-- @treturn number|nil scheme type of the URL (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_host_type("https://user:pass@host:1234/path?search#hash")
local function get_host_type(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_host_type()
  return r
end


---
-- Get URL's port.
--
-- See: <https://url.spec.whatwg.org/#dom-url-port>
--
-- @function get_port
-- @tparam string url URL (or part of it) from which to get port
-- @treturn number|string|nil URL's port (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_port
-- @see set_port
-- @see clear_port
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_port("https://user:pass@host:1234/path?search#hash")
local function get_port(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_port()
  return r
end


---
-- Get URL's path.
--
-- See: <https://url.spec.whatwg.org/#dom-url-pathname>
--
-- @function get_pathname
-- @tparam string url URL (or part of it) from which to get path
-- @treturn string|nil URL's path (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see set_pathname
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_pathname("https://user:pass@host:1234/path?search#hash")
local function get_pathname(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_pathname()
  return r
end


---
-- Get URL's search (query).
--
-- Return U+003F (?), followed by URL's query.
--
-- See: <https://url.spec.whatwg.org/#dom-url-search>
--
-- @function get_search
-- @tparam string url URL (or part of it) from which to get query
-- @treturn string|nil URL's query (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_search
-- @see set_search
-- @see clear_search
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_search("https://user:pass@host:1234/path?search#hash")
local function get_search(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_search()
  return r
end


---
-- Get URL's hash (fragment).
--
-- Return U+0023 (#), followed by URL's fragment.
--
-- See: <https://url.spec.whatwg.org/#dom-url-hash>
--
-- @function get_hash
-- @tparam string url URL (or part of it) from which to get fragment
-- @treturn string|nil URL's fragment (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_hash
-- @see set_hash
-- @see clear_hash
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.get_hash("https://user:pass@host:1234/path?search#hash")
local function get_hash(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:get_hash()
  return r
end


---
-- Set Functions
-- @section set-functions


---
-- Sets protocol to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-protocol>
--
-- @function set_protocol
-- @tparam string url URL (or part of it) for which to set the protocol
-- @tparam string protocol the protocol to set to the URL
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or protocol is not a string
-- @see get_protocol
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.set_protocol("https://user:pass@host:1234/path?search#hash", "wss")
local function set_protocol(url, protocol)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local u, err = U:set_protocol(protocol)
  if err then
    return nil, err
  end
  local r = u:get_href()
  return r
end


---
-- Sets username to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-username>
--
-- @function set_username
-- @tparam string url URL (or part of it) for which to set the username
-- @tparam string username the username to set to the URL
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or username is not a string
-- @see has_non_empty_username
-- @see get_username
-- @see has_credentials
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.set_username("https://user:pass@host:1234/path?search#hash", "guest")
local function set_username(url, username)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local u, err = U:set_username(username)
  if err then
    return nil, err
  end
  local r = u:get_href()
  return r
end


---
-- Sets password to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-password>
--
-- @function set_password
-- @tparam string url URL (or part of it) for which to set the password
-- @tparam string password the password to set to the URL
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or password is not a string
-- @see has_password
-- @see has_non_empty_password
-- @see get_password
-- @see has_credentials
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.set_password("https://user:pass@host:1234/path?search#hash", "secret")
local function set_password(url, password)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local u, err = U:set_password(password)
  if err then
    return nil, err
  end
  local r = u:get_href()
  return r
end


---
-- Sets host to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-host>
--
-- @function set_host
-- @tparam string url URL (or part of it) for which to set the host
-- @tparam string host the host to set to the URL
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or host is not a string
-- @see get_host
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.set_host("https://user:pass@host:1234/path?search#hash", "test:4321")
local function set_host(url, host)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local u, err = U:set_host(host)
  if err then
    return nil, err
  end
  local r = u:get_href()
  return r
end


---
-- Sets host (name only) to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-hostname>
--
-- @function set_hostname
-- @tparam string url URL (or part of it) for which to set the host (name only)
-- @tparam string hostname the host (name only) to set to the URL
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or hostname is not a string
-- @see has_hostname
-- @see has_empty_hostname
-- @see get_hostname
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.set_hostname("https://user:pass@host:1234/path?search#hash", "test")
local function set_hostname(url, hostname)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local u, err = U:set_hostname(hostname)
  if err then
    return nil, err
  end
  local r = u:get_href()
  return r
end


---
-- Sets port to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-port>
--
-- @function set_port
-- @tparam string url URL (or part of it) for which to set the port
-- @tparam number|string port the port to set to the URL
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string or port is not a number or a string
-- @see has_port
-- @see get_port
-- @see clear_port
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.set_port("https://user:pass@host:1234/path?search#hash", 4321)
local function set_port(url, port)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local u, err = U:set_port(port)
  if err then
    return nil, err
  end
  local r = u:get_href()
  return r
end


---
-- Sets path to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-pathname>
--
-- @function set_pathname
-- @tparam string url URL (or part of it) for which to set the path
-- @tparam string pathname the path to set to the URL
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or pathname is not a string
-- @see get_pathname
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.set_pathname("https://user:pass@host:1234/path?search#hash", "foo")
local function set_pathname(url, pathname)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local u, err = U:set_pathname(pathname)
  if err then
    return nil, err
  end
  local r = u:get_href()
  return r
end


---
-- Sets search (query) to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-search>
--
-- @function set_search
-- @tparam string url URL (or part of it) for which to set the query string
-- @tparam string query the query string to set to the URL
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or search is not a string
-- @see has_search
-- @see get_search
-- @see clear_search
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.set_search("https://user:pass@host:1234/path?search#hash", "q=1&done")
local function set_search(url, query)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local u, err = U:set_search(query)
  if err then
    return nil, err
  end
  local r = u:get_href()
  return r
end


---
-- Sets hash (fragment) to the URL.
--
-- See: <https://url.spec.whatwg.org/#dom-url-hash>
--
-- @function set_hash
-- @tparam string url URL (or part of it) for which to set the fragment string
-- @tparam string hash the fragment to set to the URL
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or hash is not a string
-- @see has_hash
-- @see get_hash
-- @see clear_hash
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.set_hash("https://user:pass@host:1234/path?search#hash", "home")
local function set_hash(url, hash)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local u, err = U:set_hash(hash)
  if err then
    return nil, err
  end
  local r = u:get_href()
  return r
end


---
-- Clear Functions
-- @section clear-functions


---
-- Clear URL's port.
--
-- See: <https://url.spec.whatwg.org/#dom-url-port>
--
-- @function clear_port
-- @tparam string url URL (or part of it) from which to clear the port
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_port
-- @see get_port
-- @see set_port
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.clear_port("https://user:pass@host:1234/path?search#hash")
local function clear_port(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:clear_port():get_href()
  return r
end


---
-- Clear URL's search (query string).
--
-- See: <https://url.spec.whatwg.org/#dom-url-port>
--
-- @function clear_search
-- @tparam string url URL (or part of it) from which to clear the query string
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_search
-- @see get_search
-- @see set_search
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.clear_search("https://user:pass@host:1234/path?search#hash")
local function clear_search(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:clear_search():get_href()
  return r
end


---
-- Clear URL's hash (fragment).
--
-- See: <https://url.spec.whatwg.org/#dom-url-port>
--
-- @function clear_hash
-- @tparam string url URL (or part of it) from which to clear the fragment
-- @treturn string|nil URL in a normalized form (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
-- @see has_hash
-- @see get_hash
-- @see set_hash
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.clear_hash("https://user:pass@host:1234/path?search#hash")
local function clear_hash(url)
  if not set_url(url) then
    return nil, "invalid url"
  end
  local r = U:clear_hash():get_href()
  return r
end


---
-- Search Functions
-- @section search-functions


---
-- Parses search from URL and returns an instance of Ada URL Search.
--
-- @function search_parse
-- @tparam string url url (with search) to parse
-- @treturn search|nil Ada URL Search instance (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
--
-- @usage
-- local search = require("resty.ada.search").parse("a=b&c=d&e=f")
local function search_parse(url)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = search.parse(s or "")
  return r
end


---
-- Checks whether the url has a search with a key.
--
-- @function search_has
-- @tparam string url url (with search) to parse
-- @tparam string key search parameter name to check
-- @treturn boolean `true` if search has the key, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or key is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_has("https://user:pass@host:1234/?a=b&c=d&e=f", "a")
local function search_has(url, key)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = search.has(s or "", key)
  return r
end


---
-- Checks whether the url has a search with a key with a specific value.
--
-- @function search_has_value
-- @tparam string url url (with search) to parse
-- @tparam string key search parameter name to check
-- @tparam string value search parameter value to check
-- @treturn boolean `true` if search has the key with the value, otherwise `false` (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url, key or value is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_has_value("https://user:pass@host:1234/?a=b&c=d&e=f", "a", "b")
local function search_has_value(url, key, value)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = search.has_value(s or "", key, value)
  return r
end


---
-- Get URL's search parameter's value.
--
-- @function search_get
-- @tparam string url url (with search) to parse
-- @tparam string key search parameter name
-- @treturn string|nil parameter value or `nil` (and on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or key is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_get("https://user:pass@host:1234/?a=b&c=d&e=f", "a")
local function search_get(url, key)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = search.get(s or "", key)
  return r
end


---
-- Get all the URL's search parameter's values.
--
-- @function search_get_all
-- @tparam string url url (with search) to parse
-- @tparam string key search parameter name
-- @treturn table|nil array of all the values (or an empty array) (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or key is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_get_all("https://user:pass@host:1234/?a=b&c=d&e=f", "a")
local function search_get_all(url, key)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = search.get_all(s or "", key)
  return r
end


---
-- Set the URL's search parameter's value.
--
-- @function search_set
-- @tparam string url url (with search) to parse
-- @tparam string key search parameter name
-- @tparam string value search parameter value
-- @treturn string|nil string presentation of the URL (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url, key or value is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_set("https://user:pass@host:1234/?a=b&c=d&e=f", "a", "g")
local function search_set(url, key, value)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = U:set_search(search.set(s, key, value)):get_href()
  return r
end


---
-- Append value to the the URL's search parameter.
--
-- @function search_append
-- @tparam string url url (with search) to parse
-- @tparam string key search parameter name
-- @tparam string value search parameter value
-- @treturn string|nil string presentation of the URL (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url, key or value is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_append("https://user:pass@host:1234/?a=b&c=d&e=f", "a", "g")
local function search_append(url, key, value)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = U:set_search(search.append(s, key, value)):get_href()
  return r
end


---
-- Remove search parameter from URL.
--
-- @function search_remove
-- @tparam string url url (with search) to parse
-- @tparam string key search parameter name
-- @treturn string|nil string presentation of the URL (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url or key is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_remove("https://user:pass@host:1234/?a=b&c=d&e=f", "a")
local function search_remove(url, key)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = U:set_search(search.remove(s, key)):get_href()
  return r
end


---
-- Remove search parameter's value from URL.
--
-- @function search_remove_value
-- @tparam string url url (with search) to parse
-- @tparam string key search parameter name
-- @tparam string value search parameter's value
-- @treturn string|nil string presentation of the URL (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url, key or value is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_remove_value("https://user:pass@host:1234/?a=b&c=d&e=f", "a", "b")
local function search_remove_value(url, key, value)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = U:set_search(search.remove_value(s, key, value)):get_href()
  return r
end


---
-- Sort the URL's search parameters.
--
-- @function search_sort
-- @tparam string url url (with search) to parse
-- @treturn string|nil string presentation of the URL (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_sort("https://user:pass@host:1234/?e=f&c=d&a=b")
local function search_sort(url)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = U:set_search(search.sort(s)):get_href()
  return r
end


---
-- Count search parameters in URL.
--
-- @function search_size
-- @tparam string url url (with search) to parse
-- @treturn number|nil search parameters count (except on errors `nil`)
-- @treturn nil|string error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- local res = ada.search_size("https://user:pass@host:1234/?a=b&c=d&e=f")
local function search_size(url)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local r = search.size(s or "")
  return r
end


---
-- Iterate over search parameters in URL.
--
-- @function search_each
-- @tparam string url url (with search) to parse
-- @treturn function iterator function (except on errors `nil`)
-- @treturn cdata|string state or error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- for param in ada.search_each("https://user:pass@host:1234/?a=b&c=d&e=f") do
--   print(param.key, " = ", param.value)
-- end
local function search_each(url)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local iterator, invariant_state = search.each(s or "")
  return iterator, invariant_state
end


---
-- Iterate over each key in parameters in URL.
--
-- @function search_each_key
-- @tparam string url url (with search) to parse
-- @treturn function iterator function (except on errors `nil`)
-- @treturn cdata|string state or error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- for key in ada.search_each_key("https://user:pass@host:1234/?a=b&c=d&e=f") do
--   print("key: ", key)
-- end
local function search_each_key(url)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local iterator, invariant_state = search.each_key(s or "")
  return iterator, invariant_state
end


---
-- Iterate over each value in search parameters in URL.
--
-- @function search_each_value
-- @tparam string url url (with search) to parse
-- @treturn function iterator function (except on errors `nil`)
-- @treturn cdata|string state or error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- for value in ada.search_each_value("https://user:pass@host:1234/?a=b&c=d&e=f") do
--   print("value: ", value)
-- end
local function search_each_value(url)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local iterator, invariant_state = search.each_value(s or "")
  return iterator, invariant_state
end


---
-- Iterate over each key and value in search parameters in URL.
--
-- @function search_pairs
-- @tparam string url url (with search) to parse
-- @treturn function iterator function (except on errors `nil`)
-- @treturn cdata|string state or error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- for key, value in ada.search_pairs("https://user:pass@host:1234/?a=b&c=d&e=f") do
--   print(key, " = ", value)
-- end
local function search_pairs(url)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local iterator, invariant_state = search.pairs(s or "")
  return iterator, invariant_state
end


---
-- Iterate over each parameter in search parameters in URL.
--
-- @function search_ipairs
-- @tparam string url url (with search) to parse
-- @treturn function iterator function (except on errors `nil`)
-- @treturn cdata|string state or error message
-- @raise error when url is not a string
--
-- @usage
-- local ada = require("resty.ada")
-- for i, param in ada.search_ipairs("https://user:pass@host:1234/?a=b&c=d&e=f") do
--   print(i, ". ", param.key, " = ", param.value)
-- end
local function search_ipairs(url)
  local s, err = get_search(url)
  if err then
    return nil, err
  end
  local iterator, invariant_state, initial_value = search.ipairs(s or "")
  return iterator, invariant_state, initial_value
end


---
-- Fields
-- @section fields


return {
  ---
  -- resty.ada version
  -- @usage
  -- local ada = require("resty.ada")
  -- local ver = ada._VERSION
  _VERSION = _VERSION,
  ---
  -- resty.ada.search
  -- @see resty.ada.search
  -- @usage
  -- local ada = require("resty.ada")
  -- local res = ada.search.has("a=b&c=d&e=f", "a")
  search = search,
  parse = parse,
  parse_with_base = parse_with_base,
  idna_to_ascii = idna_to_ascii,
  idna_to_unicode = idna_to_unicode,
  can_parse = can_parse,
  can_parse_with_base = can_parse_with_base,
  has_credentials = has_credentials,
  has_non_empty_username = has_non_empty_username,
  has_password = has_password,
  has_non_empty_password = has_non_empty_password,
  has_hostname = has_hostname,
  has_empty_hostname = has_empty_hostname,
  has_port = has_port,
  has_search = has_search,
  has_hash = has_hash,
  get_components = get_components,
  get_href = get_href,
  get_protocol = get_protocol,
  get_scheme_type = get_scheme_type,
  get_origin = get_origin,
  get_username = get_username,
  get_password = get_password,
  get_host = get_host,
  get_hostname = get_hostname,
  get_host_type = get_host_type,
  get_port = get_port,
  get_pathname = get_pathname,
  get_search = get_search,
  get_hash = get_hash,
  set_protocol = set_protocol,
  set_username = set_username,
  set_password = set_password,
  set_host = set_host,
  set_hostname = set_hostname,
  set_port = set_port,
  set_pathname = set_pathname,
  set_search = set_search,
  set_hash = set_hash,
  clear_port = clear_port,
  clear_search = clear_search,
  clear_hash = clear_hash,
  search_parse = search_parse,
  search_has = search_has,
  search_has_value = search_has_value,
  search_get = search_get,
  search_get_all = search_get_all,
  search_set = search_set,
  search_append = search_append,
  search_remove = search_remove,
  search_remove_value = search_remove_value,
  search_each = search_each,
  search_each_key = search_each_key,
  search_each_value = search_each_value,
  search_pairs = search_pairs,
  search_ipairs = search_ipairs,
  search_sort = search_sort,
  search_size = search_size,
}
