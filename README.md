# PowerQueryInfluxHomeAssistant

A Power Query custom connector for loading Home Assistant history from InfluxDB 1.x into Power BI.

## MVP features

- InfluxDB username/password authentication through the Power Query credential store
- navigation tables for discovered entities, measurements, and connector diagnostics
- hierarchical browsing from measurement to multi-selectable entity history tables
- bounded history queries with server-side entity, field, measurement, and time filters
- `raw`, `mean`, `min`, `max`, `sum`, `last`, and `count` modes
- server-side InfluxQL grouping and aggregation
- stable Power BI schema with UTC `datetimezone` timestamps
- `RangeStart` and `RangeEnd` support for Incremental Refresh
- explicit handling for common InfluxDB HTTP failures
- bounded exponential retry for temporary HTTP failures
- stable numeric, text, and Boolean value columns

The connector targets the common Home Assistant InfluxDB layout:

- entity tag: `entity_id`
- optional domain tag: `domain`
- default field: `value` (configurable, for example `state`)
- optional unit tag: `unit_of_measurement`

The history function and Browse dialog let callers override the measurement, entity tag, and field name. Numeric values are returned in `Value`, strings in `ValueText`, and Boolean values in `ValueBoolean`; this keeps the Power BI schema stable across refreshes. Select `raw` when loading a text or Boolean field because numeric aggregations such as `mean` do not apply to those values.

The navigator includes **Browse by measurement**. Measurement folders show their entity counts; each entity is a bounded table leaf with the measurement and entity filter already pushed into InfluxQL. Table leaves are eligible for the host's multi-select feature.

The source dialog accepts optional case-insensitive **Measurement contains** and **Entity contains** filters. Because the navigator UI itself is owned by Power BI or Excel, a custom connector cannot inject a search box into the tree. Change these filters through the source settings and reopen the navigation step.

New connections use `HomeAssistantInflux.Browse`, which requires a **Period** selection: 24 hours, 7/30 days, 3/6 months, 1/2/3/5/10 years, all available data, or **Custom range**. For a custom range, enter both **Custom start time** and **Custom end time** with their time-zone offsets. The end is exclusive. The connector automatically uses a safe server-side window from five minutes for short ranges through one day for yearly/all-data requests. Existing `HomeAssistantInflux.Database` queries remain supported; `HomeAssistantInflux.BrowseRange` provides the same exact-range capability for hand-written queries and `HomeAssistantInflux.History` supports Incremental Refresh.

## Prerequisites

- InfluxDB 1.x with its `/query` endpoint enabled
- a read-only InfluxDB username and password for the Home Assistant database
- Power BI Desktop with custom connectors enabled
- the Microsoft Power Query SDK when building through Visual Studio Code or MSBuild

Do not expose InfluxDB publicly only for this connector. Prefer HTTPS on a private network or VPN route.

## Development

Install the JavaScript validation dependency and run the checks:

```bash
npm install
npm run check
```

The check parses every connector source file with Microsoft's Power Query parser and verifies security and query-pushdown invariants.

Create an unsigned development package without the Microsoft SDK:

```bash
npm run package
```

The package is written to `dist/PowerQueryInfluxHomeAssistant.mez`. The included `.proj` can also be opened and built using the Microsoft Power Query SDK.

## Install for Power BI Desktop

1. Copy the `.mez` file to:
   `Documents/Microsoft Power BI Desktop/Custom Connectors/`
2. In Power BI Desktop, enable loading custom connectors under **Options > Security > Data Extensions**.
3. Restart Power BI Desktop.
4. Select **Get data > Other > Home Assistant InfluxDB**.
5. Enter the server URL and database.
6. Enter the read-only InfluxDB username and password when Power BI requests credentials.

The connector trims accidental spaces and tabs around the server and database values before sending requests. Its Diagnostics table explicitly warns when HTTP is used because Basic credentials are not encrypted in transit.

Unsigned connectors should only be used during development. Sign releases before broader deployment.

## Usage

Browse available entities:

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

`RangeStart` and `RangeEnd` must be Power Query `datetimezone` parameters. Each partition is translated directly into bounded InfluxQL time predicates; the connector does not download all history before filtering.

Optional parameters after the time range are:

1. aggregation
2. aggregation window
3. measurement
4. entity tag
5. field name

See [docs/RELEASE.md](docs/RELEASE.md) for PQTest, gateway, `.pqx`, signing, and release requirements.

## Gateway deployment

For scheduled refresh in Power BI Service:

1. install the connector on every On-premises Data Gateway node that may execute the refresh;
2. enable custom connectors for the gateway cluster;
3. configure the same server and database values used by the PBIX;
4. store the read-only username and password in the gateway data-source credentials;
5. verify one bounded refresh before enabling a full historical refresh.

## Current limitations

- InfluxDB 2.x and Flux are not yet supported.
- Binary field values are not returned by `History`.
- Entity discovery uses `SHOW TAG VALUES`; domain prefixes are reconstructed only when history rows include the `domain` tag.
- The development `.mez` package is unsigned.
- A Power BI Desktop and Gateway integration test still requires a Windows environment with the Microsoft SDK.
- Friendly names, devices, and areas require Home Assistant metadata that is normally absent from the InfluxDB history schema.
