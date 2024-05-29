local ffi = require("ffi")


local error = error
local pcall = pcall
local ipairs = ipairs
local ffi_load = ffi.load


ffi.cdef([[
typedef struct {
  const char* data;
  size_t length;
} ada_string;

typedef struct {
  const char* data;
  size_t length;
} ada_owned_string;

typedef struct {
  uint32_t protocol_end;
  uint32_t username_end;
  uint32_t host_start;
  uint32_t host_end;
  uint32_t port;
  uint32_t pathname_start;
  uint32_t search_start;
  uint32_t hash_start;
} ada_url_components;

typedef struct {
  ada_string key;
  ada_string value;
} ada_string_pair;

typedef void* ada_url;
typedef void* ada_strings;
typedef void* ada_url_search_params;
typedef void* ada_url_search_params_keys_iter;
typedef void* ada_url_search_params_values_iter;
typedef void* ada_url_search_params_entries_iter;

const ada_url_components* ada_get_components(ada_url result);

ada_url ada_parse(const char* input, size_t length);
ada_url ada_parse_with_base(const char* input, size_t input_length, const char* base, size_t base_length);
ada_url_search_params ada_parse_search_params(const char* input, size_t length);

bool ada_can_parse(const char* input, size_t length);
bool ada_can_parse_with_base(const char* input, size_t input_length, const char* base, size_t base_length);

void ada_free(ada_url result);
void ada_free_owned_string(ada_owned_string owned);
void ada_free_search_params(ada_url_search_params result);
void ada_free_strings(ada_strings result);
void ada_free_search_params_keys_iter(ada_url_search_params_keys_iter result);
void ada_free_search_params_values_iter(ada_url_search_params_values_iter result);
void ada_free_search_params_entries_iter(ada_url_search_params_entries_iter result);

ada_url ada_copy(ada_url input);

bool ada_is_valid(ada_url result);

ada_owned_string ada_get_origin(ada_url result);
ada_string ada_get_href(ada_url result);
ada_string ada_get_username(ada_url result);
ada_string ada_get_password(ada_url result);
ada_string ada_get_port(ada_url result);
ada_string ada_get_hash(ada_url result);
ada_string ada_get_host(ada_url result);
ada_string ada_get_hostname(ada_url result);
ada_string ada_get_pathname(ada_url result);
ada_string ada_get_search(ada_url result);
ada_string ada_get_protocol(ada_url result);
uint8_t ada_get_host_type(ada_url result);
uint8_t ada_get_scheme_type(ada_url result);

bool ada_set_href(ada_url result, const char* input, size_t length);
bool ada_set_host(ada_url result, const char* input, size_t length);
bool ada_set_hostname(ada_url result, const char* input, size_t length);
bool ada_set_protocol(ada_url result, const char* input, size_t length);
bool ada_set_username(ada_url result, const char* input, size_t length);
bool ada_set_password(ada_url result, const char* input, size_t length);
bool ada_set_port(ada_url result, const char* input, size_t length);
bool ada_set_pathname(ada_url result, const char* input, size_t length);
void ada_set_search(ada_url result, const char* input, size_t length);
void ada_set_hash(ada_url result, const char* input, size_t length);

void ada_clear_port(ada_url result);
void ada_clear_hash(ada_url result);
void ada_clear_search(ada_url result);

bool ada_has_credentials(ada_url result);
bool ada_has_empty_hostname(ada_url result);
bool ada_has_hostname(ada_url result);
bool ada_has_non_empty_username(ada_url result);
bool ada_has_non_empty_password(ada_url result);
bool ada_has_port(ada_url result);
bool ada_has_password(ada_url result);
bool ada_has_hash(ada_url result);
bool ada_has_search(ada_url result);

ada_owned_string ada_idna_to_unicode(const char* input, size_t length);
ada_owned_string ada_idna_to_ascii(const char* input, size_t length);

ada_owned_string ada_search_params_to_string(ada_url_search_params result);
size_t ada_search_params_size(ada_url_search_params result);
void ada_search_params_append(ada_url_search_params result, const char* key, size_t key_length, const char* value, size_t value_length);
void ada_search_params_set(ada_url_search_params result, const char* key, size_t key_length, const char* value, size_t value_length);
bool ada_search_params_has(ada_url_search_params result, const char* key, size_t key_length);
bool ada_search_params_has_value(ada_url_search_params result, const char* key, size_t key_length, const char* value, size_t value_length);
ada_string ada_search_params_get(ada_url_search_params result, const char* key, size_t key_length);
ada_strings ada_search_params_get_all(ada_url_search_params result, const char* key, size_t key_length);

ada_url_search_params_keys_iter ada_search_params_get_keys(ada_url_search_params result);
ada_url_search_params_values_iter ada_search_params_get_values(ada_url_search_params result);
ada_url_search_params_entries_iter ada_search_params_get_entries(ada_url_search_params result);

bool ada_search_params_keys_iter_has_next(ada_url_search_params_keys_iter result);
bool ada_search_params_values_iter_has_next(ada_url_search_params_values_iter result);
bool ada_search_params_entries_iter_has_next(ada_url_search_params_entries_iter result);

ada_string ada_search_params_keys_iter_next(ada_url_search_params_keys_iter result);
ada_string ada_search_params_values_iter_next(ada_url_search_params_values_iter result);
ada_string_pair ada_search_params_entries_iter_next(ada_url_search_params_entries_iter result);

size_t ada_strings_size(ada_strings result);
ada_string ada_strings_get(ada_strings result, size_t index);

void ada_search_params_remove(ada_url_search_params result, const char* key, size_t key_length);
void ada_search_params_remove_value(ada_url_search_params result, const char* key, size_t key_length, const char* value, size_t value_length);
]])


local function load_lib(name)
  local pok, lib = pcall(ffi_load, name)
  if pok then
    return lib
  end
end


local load_lib_from_cpath do
  local gmatch = string.gmatch
  local match = string.match
  local open = io.open
  local close = io.close
  local cpath = package.cpath
  function load_lib_from_cpath(name)
    for path, _ in gmatch(cpath, "[^;]+") do
      if path == "?.so" or path == "?.dylib" then
        path = "./"
      end
      local file_path = match(path, "(.*/)")
      file_path = file_path .. name
      local file = open(file_path)
      if file ~= nil then
        close(file)
        return load_lib(file_path)
      end
    end
  end
end


do
  local library_names = {
    "libada",
    "ada",
  }

  local library_versions = {
    "",
    ".2",
  }

  local library_extensions = {
    ".so",
    ".dylib",
  }

  local lib

  -- try to load ada library from package.cpath
  for _, library_name in ipairs(library_names) do
    for _, library_version in ipairs(library_versions) do
      for _, library_extension in ipairs(library_extensions) do
        lib = load_lib_from_cpath(library_name .. library_version .. library_extension)
        if lib then
          return lib
        end
      end
    end
  end

  -- try to load ada library from normal system path
  for _, library_name in ipairs(library_names) do
    for _, library_version in ipairs(library_versions) do
      lib = load_lib(library_name .. library_version)
      if lib then
        return lib
      end
    end
  end
end


error("unable to load ada library - please make sure that it can be found in package.cpath or system library path")
