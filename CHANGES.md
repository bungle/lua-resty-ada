# Changelog

All notable changes to `lua-resty-ada` will be documented in this file.


## [1.0.1] - 2024-08-20
### Removed
- The unnecessary `:is_valid` was removed (the URL is validated when parsed)

### Added
- Explicitly free Ada URL object on invalid URLs

## [1.0.0] - 2024-08-08
### Added
- Initial, but complete, implementation of LuaJIT FFI bindings to Ada
