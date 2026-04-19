# Changelog

All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## [0.0.3] - 2026-04-18
### Fixed
- Empty route `''` no longer acts as catch-all. It now only matches when `args` is genuinely empty, preventing it from intercepting flag-only (`--help`) or positional args before mounts are evaluated.

## [0.0.2] - 2025-10-13
### Changed
- Shortened `description` in `pubspec.yaml` to meet pub.dev guidelines.
- Updated `homepage` → GitHub and `documentation` → pub.dev for valid URLs.
- Applied `dart format .` and `dart fix --apply` to match Dart style.
- Updated `README.md` with version `^0.0.2` and added pub badge.
- Completed MIT `LICENSE` text.

### Removed
- Removed unused `test/cli_router_test.dart`.

### Docs
- Improved DartDoc coverage for `CliRequest` methods.
- Fixed unresolved reference in doc comment for `CliRequest.matchedCommand`.

### Fixed
- Minor analyzer and formatting warnings reported by pana.

## [0.0.1] - 2025-10-13
### Added
- Initial release of **cli_router**.
  - Space-based routing for commands: `cmd('route subroute', handler)`.
  - Nested routers via `mount('prefix', subRouter)` or `cmd('prefix', subRouter)`.
  - Dynamic parameters `<id>` and wildcard `*`.
  - GNU-style flag parsing (`--k v`, `--k=v`, `-abc`, `--no-k`).
  - Shelf-like middlewares with `use()`.
  - Helpers: `flagBool`, `flagInt`, `flagDouble`, `flagString`, `param('id')`.
  - Simple help output and exit codes (`0`, `64`).
