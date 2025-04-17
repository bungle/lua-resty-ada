# Changelog

All notable changes to `lua-resty-ada` will be documented in this file.

## [1.2.0] - Unreleased
### Fixed
- Ada library will now be also loaded from <lib>.so|.dylib.<version>, in addition to
  wrong <lib>.<version>.so|.dylib.
### Changed
- Bumped Ada to `3.2.4`

## [1.1.0] - 2024-09-03
### Added
- `url:decode` method
- `ada.decode` function
- `ada.search_encode` function
- `ada.search.encode` function
- `search:decode` method
- `search:decode_all` method
- `ada.search_decode` function
- `ada.search.decode` function
- `ada.search_decode_all` function
- `ada.search.decode_all` function
### Changed
- The `set_port` to not allow negative or positive inf or NaN
### Updated
- The CI is now executed against Ada 2.9.2

## [1.0.1] - 2024-08-20
### Removed
- The unnecessary `:is_valid` was removed (the URL is validated when parsed)
### Added
- Explicitly free Ada URL object on invalid URLs

## [1.0.0] - 2024-08-08
### Added
- Initial, but complete, implementation of LuaJIT FFI bindings to Ada
