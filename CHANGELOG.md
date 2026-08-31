# Changelog

## [Unreleased]

### Added

- Add the initial InfluxDB 1.x/InfluxQL Power Query connector for numeric Home Assistant history.
- Add entity and measurement navigation, server-side aggregation, Incremental Refresh parameters, and HTTP error handling.
- Add Microsoft Power Query parser validation and unsigned development packaging.
- Add a hierarchical measurement browser with entity counts and entity-bound history access.
- Add case-insensitive measurement/entity filters and bounded table leaves eligible for navigator multi-select.
- Add a published `Browse` entry point with period presets from 24 hours through all available data.
- Retain exact custom ranges through `BrowseRange` and existing queries through `Database`.
- Add a `Custom range` period with exact start and end inputs to the main Browse dialog.
- Add selectable InfluxDB fields and stable numeric, text, and Boolean value columns.
- Retry temporary InfluxDB failures with bounded exponential backoff.
- Show an explicit diagnostics warning when the connector uses unencrypted HTTP.
- Add connector icons, CI packaging, release documentation, and `.pqx` pack/verification helpers.

### Changed

- Target InfluxDB 1.8 after live discovery of the Home Assistant instance instead of assuming InfluxDB 2.x.
- Make development `.mez` packages reproducible so release checksums remain stable.

### Fixed

- Trim tabs and surrounding whitespace from the database name before discovery and history queries.
- Clarify HTTP 403 errors by pointing to both database-name and read-permission checks.
- Avoid the `Measurement` column collision when parsing `SHOW MEASUREMENTS` results.
- Preserve entity-to-measurement relationships when the same entity ID occurs under multiple measurements.
- Keep advanced history access in the shared function while using safe 24-hour, five-minute-mean defaults in the browser.
