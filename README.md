# PowerQueryInfluxHomeAssistant

[![Validate connector](https://github.com/klabir/PowerQueryInfluxHomeAssistant/actions/workflows/ci.yml/badge.svg)](https://github.com/klabir/PowerQueryInfluxHomeAssistant/actions/workflows/ci.yml)
[![Release](https://img.shields.io/badge/release-0.7.0--beta.1-blue)](https://github.com/klabir/PowerQueryInfluxHomeAssistant/releases/tag/v0.7.0-beta.1)

A Power Query custom connector for browsing and loading Home Assistant history from InfluxDB 1.x into Power BI.

## Project status

The connector is a **feature-complete beta**, suitable for testing and controlled internal use. It has been validated with Microsoft's Power Query parser, packaged reproducibly, and exercised against the targeted InfluxDB 1.8/Home Assistant schema.

The current `.mez` is unsigned. A production-trusted `.pqx` still requires an organization-controlled code-signing certificate plus Windows PQTest, Power BI Desktop, and on-premises gateway verification.

**Current test release:** [Download PowerQueryInfluxHomeAssistant 0.7.0 beta 1](https://github.com/klabir/PowerQueryInfluxHomeAssistant/releases/download/v0.7.0-beta.1/PowerQueryInfluxHomeAssistant.mez)

## Features

- InfluxDB username/password authentication through the Power Query credential store
- hierarchical measurement and entity browser with entity counts
- Power BI navigator multi-select support for individual entity tables
- case-insensitive measurement and entity filters
- period presets from 24 hours through all available history
- exact custom start and end timestamps with time-zone support
- bounded server-side entity, field, measurement, and time filtering
- configurable InfluxDB field, including common `value` and `state` fields
- numeric, text, and Boolean history with a stable Power BI schema
- raw data plus `mean`, `min`, `max`, `sum`, `last`, and `count` aggregations
- automatic aggregation windows with an optional manual override
- `RangeStart` and `RangeEnd` pushdown for Incremental Refresh
- UTC `datetimezone` timestamps
- bounded exponential retry for temporary InfluxDB failures
- actionable authentication, permission, query-size, and service errors
- connector diagnostics including the effective range, aggregation, field, and transport-security state
- reproducible `.mez` packaging, connector icons, and GitHub Actions validation
- `.pqx` packaging and signature-verification helpers for a controlled release process

## Browse workflow

Select **Get data > Other > Home Assistant InfluxDB** in Power BI Desktop. The source dialog supports:

- **Period:** 24 hours, 7/30 days, 3/6 months, 1/2/3/5/10 years, all available data, or a custom range
- **Custom start/end:** exact `datetimezone` boundaries; the end is exclusive
- **Measurement contains:** filters the measurement folders before opening the navigator
- **Entity contains:** filters entity leaves before opening the navigator
- **Aggregation:** raw or a supported InfluxQL aggregation
- **Aggregation window override:** optional manual grouping interval
- **InfluxDB field:** defaults to `value`; use `state` where appropriate

The navigator groups entities under **Browse by measurement**. Each entity is a bounded table leaf whose measurement, entity, field, and time predicates are already pushed into InfluxQL. Power BI owns the navigator interface, so the connector cannot inject an additional search box directly into its tree.

## Output schema

History tables use a stable schema across refreshes:

| Column | Type | Description |
| --- | --- | --- |
| `Timestamp` | `datetimezone` | UTC history timestamp |
| `EntityId` | text | Full Home Assistant entity ID when reconstructable |
| `Domain` | text | Home Assistant domain when available |
| `Value` | number | Numeric field value |
| `ValueText` | text | Text field value |
| `ValueBoolean` | logical | Boolean field value |
| `Unit` | text | Unit of measurement when stored as a tag |
| `Measurement` | text | InfluxDB measurement |
| `Field` | text | Selected InfluxDB field |
| `Aggregation` | text | Applied aggregation mode |

Select `raw` for text or Boolean fields because numeric aggregations such as `mean` do not apply to those values.

## Supported Home Assistant schema

The connector targets the common Home Assistant InfluxDB layout:

- entity tag: `entity_id`
- optional domain tag: `domain`
- default field: `value`, configurable to fields such as `state`
- optional unit tag: `unit_of_measurement`

`HomeAssistantInflux.History` also allows callers to override the measurement, entity tag, and field name.

## Requirements

- InfluxDB 1.x with the `/query` endpoint and InfluxQL enabled
- a dedicated read-only InfluxDB user with access to the Home Assistant database
- Power BI Desktop with custom connectors enabled
- Microsoft Power Query SDK tools for `.pqx`, PQTest, and signing workflows

Do not expose InfluxDB publicly solely for this connector. Prefer HTTPS on a private network or VPN. HTTP Basic authentication is only Base64 encoding and does not protect credentials in transit; the Diagnostics table warns when HTTP is used.

## Install the beta in Power BI Desktop

1. Download [`PowerQueryInfluxHomeAssistant.mez`](https://github.com/klabir/PowerQueryInfluxHomeAssistant/releases/download/v0.7.0-beta.1/PowerQueryInfluxHomeAssistant.mez).
2. Copy it to `Documents/Microsoft Power BI Desktop/Custom Connectors/`.
3. In Power BI Desktop, enable loading custom connectors under **Options > Security > Data Extensions**.
4. Restart Power BI Desktop.
5. Select **Get data > Other > Home Assistant InfluxDB**.
6. Enter the InfluxDB server and database.
7. Enter the read-only username and password in Power BI's credential dialog.

The beta package is unsigned and should be used only for testing or controlled internal deployment. A signed `.pqx` is required for trusted distribution with Power BI's recommended connector-security setting.

## Power Query usage

Browse available measurements and entities:

```powerquery
HomeAssistantInflux.Database(
    "https://influx.example.net:8086",
    "homeassistant"
)
```

Load hourly averages suitable for Incremental Refresh:

```powerquery
HomeAssistantInflux.History(
    "https://influx.example.net:8086",
    "homeassistant",
    {"sensor.living_room_temperature"},
    RangeStart,
    RangeEnd,
    "mean",
    #duration(0, 1, 0, 0)
)
```

`RangeStart` and `RangeEnd` must be Power Query `datetimezone` parameters. Each partition is translated into bounded InfluxQL time predicates; the connector does not download complete history before filtering.

Optional `History` parameters after the time range are:

1. aggregation
2. aggregation window
3. measurement
4. entity tag
5. field name

## Gateway deployment

For scheduled refresh in Power BI Service:

1. install the same connector package on every on-premises data gateway node that may execute the refresh;
2. enable custom connectors for the gateway cluster;
3. configure the same server and database values used by the PBIX;
4. store the read-only username and password in the gateway data-source credentials;
5. verify one bounded refresh before enabling a full historical or Incremental Refresh workload.

## Development

Install dependencies and validate the M source, examples, connector resources, credential invariants, and query pushdown:

```bash
npm ci
npm run icons
npm run check
```

Create the reproducible unsigned development package:

```bash
npm run package
```

The package is written to `dist/PowerQueryInfluxHomeAssistant.mez`. GitHub Actions runs the same validation and publishes the `.mez` as a workflow artifact.

See [docs/RELEASE.md](docs/RELEASE.md) for PQTest, gateway, `.pqx`, signing, checksum, and release requirements. Security reports, privacy behavior, and support expectations are documented in [SECURITY.md](SECURITY.md), [PRIVACY.md](PRIVACY.md), and [SUPPORT.md](SUPPORT.md).

## Current limitations

- InfluxDB 2.x and Flux are not supported.
- Binary field values are not returned by `History`.
- Entity discovery uses `SHOW TAG VALUES`; domain prefixes are reconstructed only when history rows include the `domain` tag.
- Friendly names, devices, and areas require Home Assistant metadata that is normally absent from the InfluxDB history schema.
- The beta `.mez` is unsigned.
- Windows PQTest, Power BI Desktop, and gateway release evidence remains outstanding.
- A software license must be selected before a general public release.
