# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-23

### Added
- Initial release of libprovn
- Complete PROV-N parser based on W3C specification
- PROV-JSON reader and writer for bidirectional conversion
- Support for all PROV-N expression types:
  - Entity, Activity, and Agent expressions
  - Generation and Usage relationships
  - Derivation, Attribution, Association, and Delegation
  - Communication, Start, End, and Invalidation
  - Specialization, Alternate, and Membership
  - Influence expressions
  - Bundle support for nested provenance
  - Extensibility expressions for custom qualified names
- Command-line tool for converting between PROV-N and PROV-JSON
- Comprehensive test suite with W3C examples
- Full documentation and examples