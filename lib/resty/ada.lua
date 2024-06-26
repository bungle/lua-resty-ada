local lib = require("resty.ada.lib")
local utils = require("resty.ada.utils")
local search = require("resty.ada.search")


local ada_string_to_lua = utils.ada_string_to_lua
local ada_owned_string_to_lua = utils.ada_owned_string_to_lua
local port_to_string = utils.port_to_string


local ffi = require("ffi")
local ffi_gc = ffi.gc


local type = type
local assert = assert
local tonumber = tonumber
local setmetatable = setmetatable


local _OMITTED = 0xffffffff
local _VERSION = "1.0.0"


local mt = {
  _VERSION = _VERSION,
}


mt.__index = mt


local function new(url)
  assert(type(url) == "string", "invalid url")
  local u = ffi_gc(lib.ada_parse(url, #url), lib.ada_free)
  return u
end


local function new_with_base(url, base)
  assert(type(url) == "string", "invalid url")
  assert(type(base) == "string", "invalid base")
  local u = ffi_gc(lib.ada_parse_with_base(url, #url, base, #base), lib.ada_free)
  return u
end


local function parse(url)
  local u = new(url)
  if not lib.ada_is_valid(u) then
    return nil, "invalid url"
  end
  local self = setmetatable({ u }, mt)
  return self
end


local function parse_with_base(url, base)
  local u = new_with_base(url, base)
  if not lib.ada_is_valid(u) then
    return nil, "invalid url"
  end
  local self = setmetatable({ u }, mt)
  return self
end


local function is_valid(url)
  local u = new(url)
  local r = lib.ada_is_valid(u)
  return r
end
function mt:is_valid()
  local r = lib.ada_is_valid(self[1])
  return r
end


local function can_parse(url)
  return type(url) == "string"
     and lib.ada_can_parse(url, #url)
end


local function can_parse_with_base(url, base)
  return type(url)  == "string"
     and type(base) == "string"
     and lib.ada_parse_with_base(url, #url, base, #base)
end

local function parse_component(c)
  if c == _OMITTED then
    return
  end
  return c + 1
end
local function real_get_components(u)
  local c = lib.ada_get_components(u)
  return {
    protocol_end   = parse_component(c.protocol_end),
    username_end   = parse_component(c.username_end),
    host_start     = parse_component(c.host_start),
    host_end       = parse_component(c.host_end),
    port           = parse_component(c.port),
    pathname_start = parse_component(c.pathname_start),
    search_start   = parse_component(c.search_start),
    hash_start     = parse_component(c.hash_start),
  }
end
local function get_components_with_base(url, base)
  local u = new_with_base(url, base)
  local r = real_get_components(u)
  return r
end
local function get_components(url)
  local u = new(url)
  local r = real_get_components(u)
  return r
end
function mt:get_components()
  local r = real_get_components(self[1])
  return r
end


local function has_credentials_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_has_credentials(u)
  return r
end
local function has_credentials(url)
  local u = new(url)
  local r = lib.ada_has_credentials(u)
  return r
end
function mt:has_credentials()
  local r = lib.ada_has_credentials(self[1])
  return r
end


local function has_empty_hostname_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_has_empty_hostname(u)
  return r
end
local function has_empty_hostname(url)
  local u = new(url)
  local r = lib.ada_has_empty_hostname(u)
  return r
end
function mt:has_empty_hostname()
  local r = lib.ada_has_empty_hostname(self[1])
  return r
end


local function has_hostname_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_has_hostname(u)
  return r
end
local function has_hostname(url)
  local u = new(url)
  local r = lib.ada_has_hostname(u)
  return r
end
function mt:has_hostname()
  local r = lib.ada_has_hostname(self[1])
  return r
end


local function has_non_empty_username_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_has_non_empty_username(u)
  return r
end
local function has_non_empty_username(url)
  local u = new(url)
  local r = lib.ada_has_non_empty_username(u)
  return r
end
function mt:has_non_empty_username()
  local r = lib.ada_has_non_empty_username(self[1])
  return r
end


local function has_non_empty_password_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_has_non_empty_password(u)
  return r
end
local function has_non_empty_password(url)
  local u = new(url)
  local r = lib.ada_has_non_empty_password(u)
  return r
end
function mt:has_non_empty_password()
  local r = lib.ada_has_non_empty_password(self[1])
  return r
end


local function has_port_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_has_port(u)
  return r
end
local function has_port(url)
  local u = new(url)
  local r = lib.ada_has_port(u)
  return r
end
function mt:has_port()
  local r = lib.has_port(self[1])
  return r
end


local function has_password_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_has_password(u)
  return r
end
local function has_password(url)
  local u = new(url)
  local r = lib.ada_has_password(u)
  return r
end
function mt:has_password()
  local r = lib.ada_has_password(self[1])
  return r
end


local function has_hash_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_has_hash(u)
  return r
end
local function has_hash(url)
  local u = new(url)
  local r = lib.ada_has_hash(u)
  return r
end
function mt:has_hash()
  local r = lib.ada_has_hash(self[1])
  return r
end


local function has_search_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_has_hash(u)
  return r
end
local function has_search(url)
  local u = new(url)
  local r = lib.ada_has_hash(u)
  return r
end
function mt:has_search()
  local r = lib.ada_has_search(self[1])
  return r
end


local function get_origin_with_base(url, base)
  local u = new_with_base(url, base)
  local o = lib.ada_get_origin(u)
  local r = ada_owned_string_to_lua(o)
  return r
end
local function get_origin(url)
  local u = new(url)
  local o = lib.ada_get_origin(u)
  local r = ada_owned_string_to_lua(o)
  return r
end
function mt:get_origin()
  local o = lib.ada_get_origin(self[1])
  local r = ada_owned_string_to_lua(o)
  return r
end


local function real_get_href(u)
  local h = lib.ada_get_href(u)
  local r = ada_string_to_lua(h)
  return r
end
local function get_href_with_base(url, base)
  local u = new_with_base(url, base)
  local r = real_get_href(u)
  return r
end
local function get_href(url)
  local u = new(url)
  local r = real_get_href(u)
  return r
end
function mt:get_href()
  local r = real_get_href(self[1])
  return r
end


local function get_username_with_base(url, base)
  local u = new_with_base(url, base)
  local n = lib.ada_get_username(u)
  local r = ada_string_to_lua(n)
  return r
end
local function get_username(url)
  local u = new(url)
  local n = lib.ada_get_username(u)
  local r = ada_string_to_lua(n)
  return r
end
function mt:get_username()
  local n = lib.ada_get_username(self[1])
  local r = ada_string_to_lua(n)
  return r
end


local function get_password_with_base(url, base)
  local u = new_with_base(url, base)
  local p = lib.ada_get_password(u)
  local r = ada_string_to_lua(p)
  return r
end
local function get_password(url)
  local u = new(url)
  local p = lib.ada_get_password(u)
  local r = ada_string_to_lua(p)
  return r
end
function mt:get_password()
  local p = lib.ada_get_password(self[1])
  local r = ada_string_to_lua(p)
  return r
end


local function real_get_port(u)
  local p = lib.ada_get_port(u)
  local r = ada_string_to_lua(p)
  r = tonumber(r, 10) or r
  return r
end
local function get_port_with_base(url, base)
  local u = new_with_base(url, base)
  local r = real_get_port(u)
  return r
end
local function get_port(url)
  local u = new(url)
  local r = real_get_port(u)
  return r
end
function mt:get_port()
  local r = real_get_port(self[1])
  return r
end


local function get_hash_with_base(url, base)
  local u = new_with_base(url, base)
  local h = lib.ada_get_hash(u)
  local r = ada_string_to_lua(h)
  return r
end
local function get_hash(url)
  local u = new(url)
  local h = lib.ada_get_hash(u)
  local r = ada_string_to_lua(h)
  return r
end
function mt:get_hash()
  local h = lib.ada_get_hash(self[1])
  local r = ada_string_to_lua(h)
  return r
end


local function get_host_with_base(url, base)
  local u = new_with_base(url, base)
  local h = lib.ada_get_host(u)
  local r = ada_string_to_lua(h)
  return r
end
local function get_host(url)
  local u = new(url)
  local h = lib.ada_get_host(u)
  local r = ada_string_to_lua(h)
  return r
end
function mt:get_host()
  local h = lib.ada_get_host(self[1])
  local r = ada_string_to_lua(h)
  return r
end


local function get_hostname_with_base(url, base)
  local u = new_with_base(url, base)
  local h = lib.ada_get_hostname(u)
  local r = ada_string_to_lua(h)
  return r
end
local function get_hostname(url)
  local u = new(url)
  local h = lib.ada_get_hostname(u)
  local r = ada_string_to_lua(h)
  return r
end
function mt:get_hostname()
  local h = lib.ada_get_hostname(self[1])
  local r = ada_string_to_lua(h)
  return r
end


local function get_pathname_with_base(url, base)
  local u = new_with_base(url, base)
  local p = lib.ada_get_pathname(u)
  local r = ada_string_to_lua(p)
  return r
end
local function get_pathname(url)
  local u = new(url)
  local p = lib.ada_get_pathname(u)
  local r = ada_string_to_lua(p)
  return r
end
function mt:get_pathname()
  local p = lib.ada_get_pathname(self[1])
  local r = ada_string_to_lua(p)
  return r
end


local function get_search_with_base(url, base)
  local u = new_with_base(url, base)
  local s = lib.ada_get_search(u)
  local r = ada_string_to_lua(s)
  return r
end
local function get_search(url)
  local u = new(url)
  local s = lib.ada_get_search(u)
  local r = ada_string_to_lua(s)
  return r
end
function mt:get_search()
  local s = lib.ada_get_search(self[1])
  local r = ada_string_to_lua(s)
  return r
end


local function get_protocol_with_base(url, base)
  local u = new_with_base(url, base)
  local p = lib.ada_get_protocol(u)
  local r = ada_string_to_lua(p)
  return r
end
local function get_protocol(url)
  local u = new(url)
  local p = lib.ada_get_protocol(u)
  local r = ada_string_to_lua(p)
  return r
end
function mt:get_protocol()
  local p = lib.ada_get_protocol(self[1])
  local r = ada_string_to_lua(p)
  return r
end


local function get_host_type_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_get_host_type(u)
  return r
end
local function get_host_type(url)
  local u = new(url)
  local r = lib.ada_get_host_type(u)
  return r
end
function mt:get_host_type()
  local r = lib.ada_get_host_type(self[1])
  return r
end


local function get_scheme_type_with_base(url, base)
  local u = new_with_base(url, base)
  local r = lib.ada_get_scheme_type(u)
  return r
end
local function get_scheme_type(url)
  local u = new(url)
  local r = lib.ada_get_scheme_type(u)
  return r
end
function mt:get_scheme_type()
  local r = lib.ada_get_scheme_type(self[1])
  return r
end


local function set_href_with_base(url, base, href)
  local u = new_with_base(url, base)
  local ok = lib.ada_set_href(u, href, #href)
  if not ok then
    return nil, "unable to set href"
  end
  local r = real_get_href(u)
  return r
end
local function set_href(url, href)
  local u = new(url)
  local ok = lib.ada_set_href(u, href, #href)
  if not ok then
    return nil, "unable to set href"
  end
  local r = real_get_href(u)
  return r
end
function mt:set_href(href)
  local ok = lib.ada_set_href(self[1], href, #href)
  if not ok then
    return nil, "unable to set href"
  end
  return self
end


local function set_host_with_base(url, base, host)
  local u = new_with_base(url, base)
  local ok = lib.ada_set_host(u, host, #host)
  if not ok then
    return nil, "unable to set host"
  end
  local r = real_get_href(u)
  return r
end
local function set_host(url, host)
  local u = new(url)
  local ok = lib.ada_set_host(u, host, #host)
  if not ok then
    return nil, "unable to set host"
  end
  local r = real_get_href(u)
  return r
end
function mt:set_host(host)
  local ok = lib.ada_set_host(self[1], host, #host)
  if not ok then
    return nil, "unable to set host"
  end
  return self
end


local function set_hostname_with_base(url, base, hostname)
  local u = new_with_base(url, base)
  local ok = lib.ada_set_hostname(u, hostname, #hostname)
  if not ok then
    return nil, "unable to set hostname"
  end
  local r = real_get_href(u)
  return r
end
local function set_hostname(url, hostname)
  local u = new(url)
  local ok = lib.ada_set_hostname(u, hostname, #hostname)
  if not ok then
    return nil, "unable to set hostname"
  end
  local r = real_get_href(u)
  return r
end
function mt:set_hostname(hostname)
  local ok = lib.ada_set_hostname(self[1], hostname, #hostname)
  if not ok then
    return nil, "unable to set hostname"
  end
  return self
end


local function set_protocol_with_base(url, base, protocol)
  local u = new_with_base(url, base)
  local ok = lib.ada_set_protocol(u, protocol, #protocol)
  if not ok then
    return nil, "unable to set protocol"
  end
  local r = real_get_href(u)
  return r
end
local function set_protocol(url, protocol)
  local u = new(url)
  local ok = lib.ada_set_protocol(u, protocol, #protocol)
  if not ok then
    return nil, "unable to set protocol"
  end
  local r = real_get_href(u)
  return r
end
function mt:set_protocol(protocol)
  local ok = lib.ada_set_protocol(self[1], protocol, #protocol)
  if not ok then
    return nil, "unable to set protocol"
  end
  return self
end


local function set_username_with_base(url, base, username)
  local u = new_with_base(url, base)
  local ok = lib.ada_set_username(u, username, #username)
  if not ok then
    return nil, "unable to set username"
  end
  local r = real_get_href(u)
  return r
end
local function set_username(url, username)
  local u = new(url)
  local ok = lib.ada_set_username(u, username, #username)
  if not ok then
    return nil, "unable to set username"
  end
  local r = real_get_href(u)
  return r
end
function mt:set_username(username)
  local ok = lib.ada_set_username(self[1], username, #username)
  if not ok then
    return nil, "unable to set username"
  end
  return self
end


local function set_password_with_base(url, base, password)
  local u = new_with_base(url, base)
  local ok = lib.ada_set_password(u, password, #password)
  if not ok then
    return nil, "unable to set password"
  end
  local r = real_get_href(u)
  return r
end
local function set_password(url, password)
  local u = new(url)
  local ok = lib.ada_set_password(u, password, #password)
  if not ok then
    return nil, "unable to set password"
  end
  local r = real_get_href(u)
  return r
end
function mt:set_password(password)
  local ok = lib.ada_set_password(self[1], password, #password)
  if not ok then
    return nil, "unable to set password"
  end
  return self
end


local function set_port_with_base(url, port)
  local u = new(url)
  port = port_to_string(port)
  local ok = lib.ada_set_port(u, port, #port)
  if not ok then
    return nil, "unable to set port"
  end
  local r = real_get_href(u)
  return r
end
local function set_port(url, port)
  local u = new(url)
  port = port_to_string(port)
  local ok = lib.ada_set_port(u, port, #port)
  if not ok then
    return nil, "unable to set port"
  end
  local r = real_get_href(u)
  return r
end
function mt:set_port(port)
  port = port_to_string(port)
  local ok = lib.ada_set_port(self[1], port, #port)
  if not ok then
    return nil, "unable to set port"
  end
  return self
end


local function set_pathname_with_base(url, base, pathname)
  local u = new_with_base(url, base)
  local ok = lib.ada_set_pathname(u, pathname, #pathname)
  if not ok then
    return nil, "unable to set pathname"
  end
  local r = real_get_href(u)
  return r
end
local function set_pathname(url, pathname)
  local u = new(url)
  local ok = lib.ada_set_pathname(u, pathname, #pathname)
  if not ok then
    return nil, "unable to set pathname"
  end
  local r = real_get_href(u)
  return r
end
function mt:set_pathname(pathname)
  local ok = lib.ada_set_pathname(self[1], pathname, #pathname)
  if not ok then
    return nil, "unable to set pathname"
  end
  return self
end


local function set_search_with_base(url, base, query)
  local u = new_with_base(url, base)
  lib.ada_set_search(u, query, #query)
  local r = real_get_href(u)
  return r
end
local function set_search(url, query)
  local u = new(url)
  lib.ada_set_search(u, query, #query)
  local r = real_get_href(u)
  return r
end
function mt:set_search(query)
  lib.ada_set_search(self[1], query, #query)
  return self
end


local function set_hash_with_base(url, base, hash)
  local u = new_with_base(url, base)
  lib.ada_set_hash(u, hash, #hash)
  local r = real_get_href(u)
  return r
end
local function set_hash(url, hash)
  local u = new(url)
  lib.ada_set_hash(u, hash, #hash)
  local r = real_get_href(u)
  return r
end
function mt:set_hash(hash)
  lib.ada_set_hash(self[1], hash, #hash)
  return self
end


local function clear_port_with_base(url, base)
  local u = new_with_base(url, base)
  lib.ada_clear_port(u)
  local r = real_get_href(u)
  return r
end
local function clear_port(url)
  local u = new(url)
  lib.ada_clear_port(u)
  local r = real_get_href(u)
  return r
end
function mt:clear_port()
  lib.ada_clear_port(self[1])
  return self
end


local function clear_search_with_base(url, base)
  local u = new_with_base(url, base)
  lib.ada_clear_search(u)
  local r = real_get_href(u)
  return r
end
local function clear_search(url)
  local u = new(url)
  lib.ada_clear_search(u)
  local r = real_get_href(u)
  return r
end
function mt:clear_search()
  lib.ada_clear_search(self[1])
  return self
end


local function clear_hash_with_base(url, base)
  local u = new_with_base(url, base)
  lib.ada_clear_hash(u)
  local r = real_get_href(u)
  return r
end
local function clear_hash(url)
  local u = new(url)
  lib.ada_clear_hash(u)
  local r = real_get_href(u)
  return r
end
function mt:clear_hash()
  lib.ada_clear_hash(self[1])
  return self
end


local function idna_to_unicode(url)
  local r = ada_owned_string_to_lua(lib.ada_idna_to_unicode(url, #url))
  return r
end
function mt:to_unicode()
  local r = idna_to_unicode(self:get_href())
  return r
end


local function idna_to_ascii(url)
  local r = ada_owned_string_to_lua(lib.ada_idna_to_ascii(url, #url))
  return r
end
function mt:to_ascii()
  local r = idna_to_ascii(self:get_href())
  return r
end


function mt:tostring()
  local r = self:get_href()
  return r
end
function mt:__tostring()
  local r = self:get_href()
  return r
end


function mt:__len()
  local r = self:get_href()
  return #r
end


local function search_sort_with_base(url, base)
  local u, err = parse_with_base(url, base)
  if err then
    return nil, err
  end
  u:set_search(search.sort(u:get_search()))
  local r = u:get_href()
  return r
end
local function search_sort(url)
  local u, err = parse(url)
  if err then
    return nil, err
  end
  u:set_search(search.sort(u:get_search()))
  local r = u:get_href()
  return r
end
function mt:search_sort()
  self:set_search(search.sort(self:get_search()))
  return self
end


local function search_append_with_base(url, base, key, value)
  local u, err = parse_with_base(url, base)
  if err then
    return nil, err
  end
  u:set_search(search.append(u:get_search(), key, value))
  local r = u:get_href()
  return r
end
local function search_append(url, key, value)
  local u, err = parse(url)
  if err then
    return nil, err
  end
  u:set_search(search.append(u:get_search(), key, value))
  local r = u:get_href()
  return r
end
function mt:search_append(key, value)
  self:set_search(search.append(self:get_search(), key, value))
  return self
end


local function search_set_with_base(url, base, key, value)
  local u, err = parse_with_base(url, base)
  if err then
    return nil, err
  end
  u:set_search(search.set(u:get_search(), key, value))
  local r = u:get_href()
  return r
end
local function search_set(url, key, value)
  local u, err = parse(url)
  if err then
    return nil, err
  end
  u:set_search(search.set(u:get_search(), key, value))
  local r = u:get_href()
  return r
end
function mt:search_set(key, value)
  self:set_search(search.set(self:get_search(), key, value))
  return self
end


local function search_remove_with_base(url, base, key)
  local u, err = parse_with_base(url, base)
  if err then
    return nil, err
  end
  u:set_search(search.remove(u:get_search(), key))
  local r = u:get_href()
  return r
end
local function search_remove(url, key)
  local u, err = parse(url)
  if err then
    return nil, err
  end
  u:set_search(search.remove(u:get_search(), key))
  local r = u:get_href()
  return r
end
function mt:search_remove(key)
  self:set_search(search.remove(self:get_search(), key))
  return self
end


local function search_remove_value_with_base(url, base, key, value)
  local u, err = parse_with_base(url, base)
  if err then
    return nil, err
  end
  u:set_search(search.remove(u:get_search(), key, value))
  local r = u:get_href()
  return r
end
local function search_remove_value(url, key, value)
  local u, err = parse(url)
  if err then
    return nil, err
  end
  u:set_search(search.remove_value(u:get_search(), key, value))
  local r = u:get_href()
  return r
end
function mt:search_remove_value(key, value)
  self:set_search(search.remove_value(self:get_search(), key, value))
  return self
end


local function search_has_with_base(url, base, key)
  local r = search.has(get_search_with_base(url, base), key)
  return r
end
local function search_has(url, key)
  local r = search.has(get_search(url), key)
  return r
end
function mt:search_has(key)
  local r = search.has(self:get_search(), key)
  return r
end


local function search_has_value_with_base(url, base, key, value)
  local r = search.has_value(get_search_with_base(url, base), key, value)
  return r
end
local function search_has_value(url, key, value)
  local r = search.has_value(get_search(url), key, value)
  return r
end
function mt:search_has_value(key, value)
  local r = search.has_value(self:get_search(), key, value)
  return r
end


local function search_get_with_base(url, base, key)
  local r = search.get(get_search_with_base(url, base), key)
  return r
end
local function search_get(url, key)
  local r = search.get(get_search(url), key)
  return r
end
function mt:search_get(key)
  local r = search.get(self:get_search(), key)
  return r
end


local function search_get_all_with_base(url, base, key)
  local r = search.get_all(get_search_with_base(url, base), key)
  return r
end
local function search_get_all(url, key)
  local r = search.get_all(get_search(url), key)
  return r
end
function mt:search_get_all(key)
  local r = search.get_all(self:get_search(), key)
  return r
end


local function search_size_with_base(url, base)
  local r = search.size(get_search_with_base(url, base))
  return r
end
local function search_size(url)
  local r = search.size(get_search(url))
  return r
end
function mt:search_size()
  local r = search.size(self:get_search())
  return r
end


local function search_pairs_with_base(url, base)
  local pairs_iter, entries_iter = search.pairs(get_search_with_base(url, base))
  return pairs_iter, entries_iter
end
local function search_pairs(url)
  local pairs_iter, entries_iter = search.pairs(get_search(url))
  return pairs_iter, entries_iter
end
function mt:search_pairs()
  local pairs_iter, entries_iter = search.pairs(self:get_search())
  return pairs_iter, entries_iter
end


local function search_ipairs_with_base(url, base)
  local ipairs_iter, entries_iter, invariant_state = search.ipairs(get_search_with_base(url, base))
  return ipairs_iter, entries_iter, invariant_state
end
local function search_ipairs(url)
  local ipairs_iter, entries_iter, invariant_state = search.ipairs(get_search(url))
  return ipairs_iter, entries_iter, invariant_state
end
function mt:search_ipairs()
  local ipairs_iter, entries_iter, invariant_state = search.ipairs(self:get_search())
  return ipairs_iter, entries_iter, invariant_state
end


local function search_each_with_base(url, base)
  local each_iter, entries_iter = search.each(get_search_with_base(url, base))
  return each_iter, entries_iter
end
local function search_each(url)
  local each_iter, entries_iter = search.each(get_search(url))
  return each_iter, entries_iter
end
function mt:search_each()
  local each_iter, entries_iter = search.each(self:get_search())
  return each_iter, entries_iter
end


local function search_each_key_with_base(url, base)
  local each_key_iter, keys_iter = search.each_key(get_search_with_base(url, base))
  return each_key_iter, keys_iter
end
local function search_each_key(url)
  local each_key_iter, keys_iter = search.each_key(get_search(url))
  return each_key_iter, keys_iter
end
function mt:search_each_key()
  local each_key_iter, keys_iter = search.each_key(self:get_search())
  return each_key_iter, keys_iter
end


local function search_each_value_with_base(url, base)
  local each_value_iter, values_iter = search.each_value(get_search_with_base(url, base))
  return each_value_iter, values_iter
end
local function search_each_value(url)
  local each_value_iter, values_iter = search.each_value(get_search(url))
  return each_value_iter, values_iter
end
function mt:search_each_value()
  local each_value_iter, values_iter = search.each_value(self:get_search())
  return each_value_iter, values_iter
end


local functions = {
  _VERSION = _VERSION,
  search = search,
  parse = parse,
  parse_with_base = parse_with_base,
  is_valid = is_valid,
  can_parse = can_parse,
  can_parse_with_base = can_parse_with_base,
  get_components = get_components,
  get_components_with_base = get_components_with_base,
  has_credentials = has_credentials,
  has_credentials_with_base = has_credentials_with_base,
  has_empty_hostname = has_empty_hostname,
  has_empty_hostname_with_base = has_empty_hostname_with_base,
  has_hostname = has_hostname,
  has_hostname_with_base = has_hostname_with_base,
  has_port = has_port,
  has_port_with_base = has_port_with_base,
  has_non_empty_username = has_non_empty_username,
  has_non_empty_username_with_base = has_non_empty_username_with_base,
  has_password = has_password,
  has_password_with_base = has_password_with_base,
  has_non_empty_password = has_non_empty_password,
  has_non_empty_password_with_base = has_non_empty_password_with_base,
  has_hash = has_hash,
  has_hash_with_base = has_hash_with_base,
  has_search = has_search,
  has_search_with_base = has_search_with_base,
  get_origin = get_origin,
  get_origin_with_base = get_origin_with_base,
  get_href = get_href,
  get_href_with_base = get_href_with_base,
  get_username = get_username,
  get_username_with_base = get_username_with_base,
  get_password = get_password,
  get_password_with_base = get_password_with_base,
  get_port = get_port,
  get_port_with_base = get_port_with_base,
  get_hash = get_hash,
  get_hash_with_base = get_hash_with_base,
  get_host = get_host,
  get_host_with_base = get_host_with_base,
  get_hostname = get_hostname,
  get_hostname_with_base = get_hostname_with_base,
  get_pathname = get_pathname,
  get_pathname_with_base = get_pathname_with_base,
  get_search = get_search,
  get_search_with_base = get_search_with_base,
  get_protocol = get_protocol,
  get_protocol_with_base = get_protocol_with_base,
  get_host_type = get_host_type,
  get_host_type_with_base = get_host_type_with_base,
  get_scheme_type = get_scheme_type,
  get_scheme_type_with_base = get_scheme_type_with_base,
  set_href = set_href,
  set_href_with_base = set_href_with_base,
  set_host = set_host,
  set_host_with_base = set_host_with_base,
  set_hostname = set_hostname,
  set_hostname_with_base = set_hostname_with_base,
  set_protocol = set_protocol,
  set_protocol_with_base = set_protocol_with_base,
  set_username = set_username,
  set_username_with_base = set_username_with_base,
  set_password = set_password,
  set_password_with_base = set_password_with_base,
  set_port = set_port,
  set_port_with_base = set_port_with_base,
  set_pathname = set_pathname,
  set_pathname_with_base = set_pathname_with_base,
  set_search = set_search,
  set_search_with_base = set_search_with_base,
  set_hash = set_hash,
  set_hash_with_base = set_hash_with_base,
  clear_port = clear_port,
  clear_port_with_base = clear_port_with_base,
  clear_search = clear_search,
  clear_search_with_base = clear_search_with_base,
  clear_hash = clear_hash,
  clear_hash_with_base = clear_hash_with_base,
  idna_to_unicode = idna_to_unicode,
  idna_to_ascii = idna_to_ascii,
  search_sort = search_sort,
  search_sort_with_base = search_sort_with_base,
  search_append = search_append,
  search_append_with_base = search_append_with_base,
  search_set = search_set,
  search_set_with_base = search_set_with_base,
  search_remove = search_remove,
  search_remove_with_base = search_remove_with_base,
  search_remove_value = search_remove_value,
  search_remove_value_with_base = search_remove_value_with_base,
  search_has = search_has,
  search_has_with_base = search_has_with_base,
  search_has_value = search_has_value,
  search_has_value_with_base = search_has_value_with_base,
  search_get = search_get,
  search_get_with_base = search_get_with_base,
  search_get_all = search_get_all,
  search_get_all_with_base = search_get_all_with_base,
  search_size = search_size,
  search_size_with_base = search_size_with_base,
  search_pairs = search_pairs,
  search_pairs_with_base = search_pairs_with_base,
  search_ipairs = search_ipairs,
  search_ipairs_with_base = search_ipairs_with_base,
  search_each = search_each,
  search_each_with_base = search_each_with_base,
  search_each_key = search_each_key,
  search_each_key_with_base = search_each_key_with_base,
  search_each_value = search_each_value,
  search_each_value_with_base = search_each_value_with_base,
}


return functions
