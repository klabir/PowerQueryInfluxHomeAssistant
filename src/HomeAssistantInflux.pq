section HomeAssistantInflux;

ConnectorVersion = "0.7.0";
SupportedAggregations = {"raw", "mean", "min", "max", "sum", "last", "count"};

[DataSource.Kind = "HomeAssistantInflux", Publish = "HomeAssistantInflux.Publish"]
shared HomeAssistantInflux.Browse = Value.ReplaceType(HomeAssistantInflux.BrowseImpl, HomeAssistantInflux.BrowseType);

[DataSource.Kind = "HomeAssistantInflux"]
shared HomeAssistantInflux.Database = Value.ReplaceType(HomeAssistantInflux.DatabaseImpl, HomeAssistantInflux.DatabaseType);

[DataSource.Kind = "HomeAssistantInflux"]
shared HomeAssistantInflux.BrowseRange = Value.ReplaceType(HomeAssistantInflux.BrowseRangeImpl, HomeAssistantInflux.BrowseRangeType);

[DataSource.Kind = "HomeAssistantInflux"]
shared HomeAssistantInflux.History = Value.ReplaceType(HomeAssistantInflux.HistoryImpl, HomeAssistantInflux.HistoryType);

HomeAssistantInflux.BrowseType = type function (
    server as (type text meta [Documentation.FieldCaption = "InfluxDB server", Documentation.FieldDescription = "Base URL, for example http://homeassistant.local:8086", Uri.Type = true]),
    database as (type text meta [Documentation.FieldCaption = "Database"]),
    period as (type text meta [DataSource.Path = false, Documentation.FieldCaption = "Period", Documentation.AllowedValues = {"Last 24 hours", "Last 7 days", "Last 30 days", "Last 3 months", "Last 6 months", "Last 1 year", "Last 2 years", "Last 3 years", "Last 5 years", "Last 10 years", "All available data", "Custom range"}]),
    optional measurementFilter as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Measurement contains"]),
    optional entityFilter as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Entity contains"]),
    optional aggregation as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Aggregation", Documentation.AllowedValues = {"raw", "mean", "min", "max", "sum", "last", "count"}]),
    optional window as (type nullable duration meta [DataSource.Path = false, Documentation.FieldCaption = "Aggregation window override"]),
    optional customStartTime as (type nullable datetimezone meta [DataSource.Path = false, Documentation.FieldCaption = "Custom start time", Documentation.FieldDescription = "Required when Period is Custom range. Include the time zone offset."]),
    optional customEndTime as (type nullable datetimezone meta [DataSource.Path = false, Documentation.FieldCaption = "Custom end time", Documentation.FieldDescription = "Required when Period is Custom range. The end is exclusive; include the time zone offset."]),
    optional fieldName as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "InfluxDB field", Documentation.FieldDescription = "Field to load. Defaults to value; use state for Home Assistant schemas that store text states there.", Documentation.SampleValues = {"value", "state"}])
) as table meta [Documentation.Name = "Browse Home Assistant history", Documentation.LongDescription = "Select a preset or exact custom period, filter measurements and entities, and load bounded history tables."];

HomeAssistantInflux.BrowseRangeType = type function (
    server as (type text meta [Documentation.FieldCaption = "InfluxDB server", Uri.Type = true]),
    database as (type text meta [Documentation.FieldCaption = "Database"]),
    startTime as (type datetimezone meta [DataSource.Path = false, Documentation.FieldCaption = "Start time"]),
    endTime as (type datetimezone meta [DataSource.Path = false, Documentation.FieldCaption = "End time"]),
    optional measurementFilter as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Measurement contains"]),
    optional entityFilter as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Entity contains"]),
    optional aggregation as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Aggregation", Documentation.AllowedValues = {"raw", "mean", "min", "max", "sum", "last", "count"}]),
    optional window as (type nullable duration meta [DataSource.Path = false, Documentation.FieldCaption = "Aggregation window"])
) as table meta [Documentation.Name = "Browse an exact range", Documentation.LongDescription = "Advanced entry point for an exact start and end time."];

HomeAssistantInflux.DatabaseType = type function (
    server as (type text meta [Documentation.FieldCaption = "InfluxDB server", Documentation.FieldDescription = "Base URL, for example http://homeassistant.local:8086", Uri.Type = true]),
    database as (type text meta [Documentation.FieldCaption = "Database"]),
    optional measurementFilter as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Measurement contains"]),
    optional entityFilter as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Entity contains"]),
    optional startTime as (type nullable datetimezone meta [DataSource.Path = false, Documentation.FieldCaption = "Browse start time"]),
    optional endTime as (type nullable datetimezone meta [DataSource.Path = false, Documentation.FieldCaption = "Browse end time"]),
    optional aggregation as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Browse aggregation", Documentation.AllowedValues = {"raw", "mean", "min", "max", "sum", "last", "count"}]),
    optional window as (type nullable duration meta [DataSource.Path = false, Documentation.FieldCaption = "Browse aggregation window"]),
    optional fieldName as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "InfluxDB field", Documentation.SampleValues = {"value", "state"}])
) as table meta [Documentation.Name = "Home Assistant InfluxDB", Documentation.LongDescription = "Browse Home Assistant entities and measurements stored in InfluxDB 1.x."];

HomeAssistantInflux.HistoryType = type function (
    server as (type text meta [Documentation.FieldCaption = "InfluxDB server", Uri.Type = true]),
    database as (type text meta [Documentation.FieldCaption = "Database"]),
    entityIds as (type list meta [DataSource.Path = false, Documentation.FieldCaption = "Entity IDs", Documentation.FieldDescription = "One or more IDs, for example {""sensor.living_room_temperature""}."]),
    startTime as (type datetimezone meta [DataSource.Path = false, Documentation.FieldCaption = "Start time"]),
    endTime as (type datetimezone meta [DataSource.Path = false, Documentation.FieldCaption = "End time"]),
    optional aggregation as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Aggregation", Documentation.AllowedValues = {"raw", "mean", "min", "max", "sum", "last", "count"}]),
    optional window as (type nullable duration meta [DataSource.Path = false, Documentation.FieldCaption = "Aggregation window", Documentation.FieldDescription = "Required for every aggregation except raw."]),
    optional measurement as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Measurement"]),
    optional entityTag as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Entity tag", Documentation.SampleValues = {"entity_id"}]),
    optional fieldName as (type nullable text meta [DataSource.Path = false, Documentation.FieldCaption = "Numeric field", Documentation.SampleValues = {"value"}])
) as table meta [Documentation.Name = "Home Assistant history", Documentation.LongDescription = "Loads bounded numeric Home Assistant history and pushes filters and aggregations into InfluxDB 1.x."];

HomeAssistantInflux.BrowseImpl = (
    server as text,
    database as text,
    period as text,
    optional measurementFilter as nullable text,
    optional entityFilter as nullable text,
    optional aggregation as nullable text,
    optional window as nullable duration,
    optional customStartTime as nullable datetimezone,
    optional customEndTime as nullable datetimezone,
    optional fieldName as nullable text
) as table =>
    let
        range = ResolveBrowsePeriod(period, DateTimeZone.UtcNow(), customStartTime, customEndTime),
        effectiveWindow = if window = null then range[Window] else window
    in
        HomeAssistantInflux.DatabaseImpl(server, database, measurementFilter, entityFilter, range[Start], range[End], aggregation, effectiveWindow, fieldName);

HomeAssistantInflux.BrowseRangeImpl = (
    server as text,
    database as text,
    startTime as datetimezone,
    endTime as datetimezone,
    optional measurementFilter as nullable text,
    optional entityFilter as nullable text,
    optional aggregation as nullable text,
    optional window as nullable duration
) as table => HomeAssistantInflux.DatabaseImpl(server, database, measurementFilter, entityFilter, startTime, endTime, aggregation, window);

ResolveBrowsePeriod = (
    period as text,
    currentTime as datetimezone,
    optional customStartTime as nullable datetimezone,
    optional customEndTime as nullable datetimezone
) as record =>
    let
        normalized = Text.Lower(Text.Trim(period)),
        isCustom = normalized = "custom range",
        checkedCustomStart = if isCustom and customStartTime = null then error Error.Record("MissingCustomStart", "Enter a custom start time when Period is Custom range.", null) else customStartTime,
        checkedCustomEnd = if isCustom and customEndTime = null then error Error.Record("MissingCustomEnd", "Enter a custom end time when Period is Custom range.", null) else customEndTime,
        checkedCustomRange = if isCustom and checkedCustomEnd <= checkedCustomStart then error Error.Record("InvalidTimeRange", "Custom end time must be after custom start time.", [Start = checkedCustomStart, End = checkedCustomEnd]) else true,
        settings =
            if isCustom then [Days = null, Window = AutomaticBrowseWindow(checkedCustomStart, checkedCustomEnd)]
            else if normalized = "last 24 hours" then [Days = 1, Window = #duration(0, 0, 5, 0)]
            else if normalized = "last 7 days" then [Days = 7, Window = #duration(0, 0, 15, 0)]
            else if normalized = "last 30 days" then [Days = 30, Window = #duration(0, 1, 0, 0)]
            else if normalized = "last 3 months" then [Days = 92, Window = #duration(0, 6, 0, 0)]
            else if normalized = "last 6 months" then [Days = 183, Window = #duration(0, 12, 0, 0)]
            else if normalized = "last 1 year" then [Days = 365, Window = #duration(1, 0, 0, 0)]
            else if normalized = "last 2 years" then [Days = 730, Window = #duration(1, 0, 0, 0)]
            else if normalized = "last 3 years" then [Days = 1095, Window = #duration(1, 0, 0, 0)]
            else if normalized = "last 5 years" then [Days = 1825, Window = #duration(1, 0, 0, 0)]
            else if normalized = "last 10 years" then [Days = 3650, Window = #duration(1, 0, 0, 0)]
            else if normalized = "all available data" then [Days = null, Window = #duration(1, 0, 0, 0)]
            else error Error.Record("UnsupportedPeriod", "Select one of the supported browse periods.", [Period = period]),
        endTime = if isCustom then checkedCustomEnd else currentTime,
        startTime = if isCustom then checkedCustomStart else if settings[Days] = null then #datetimezone(1970, 1, 1, 0, 0, 0, 0, 0) else endTime - #duration(settings[Days], 0, 0, 0)
    in
        if checkedCustomRange then [Start = startTime, End = endTime, Window = settings[Window]] else error Error.Record("InvalidTimeRange", "Custom end time must be after custom start time.", null);

AutomaticBrowseWindow = (startTime as datetimezone, endTime as datetimezone) as duration =>
    let
        days = Duration.TotalDays(endTime - startTime)
    in
        if days <= 1 then #duration(0, 0, 5, 0)
        else if days <= 7 then #duration(0, 0, 15, 0)
        else if days <= 30 then #duration(0, 1, 0, 0)
        else if days <= 92 then #duration(0, 6, 0, 0)
        else if days <= 183 then #duration(0, 12, 0, 0)
        else #duration(1, 0, 0, 0);

HomeAssistantInflux.DatabaseImpl = (
    server as text,
    database as text,
    optional measurementFilter as nullable text,
    optional entityFilter as nullable text,
    optional startTime as nullable datetimezone,
    optional endTime as nullable datetimezone,
    optional aggregation as nullable text,
    optional window as nullable duration,
    optional fieldName as nullable text
) as table =>
    let
        connection = NormalizeConnectionArguments(server, database),
        normalizedServer = connection[Server],
        normalizedDatabase = connection[Database],
        entities = DiscoverEntities(normalizedServer, normalizedDatabase, "entity_id"),
        filteredEntities = FilterEntityCatalog(entities, measurementFilter, entityFilter),
        measurements = DiscoverMeasurements(normalizedServer, normalizedDatabase),
        effectiveEnd = if endTime = null then DateTimeZone.UtcNow() else endTime,
        effectiveStart = if startTime = null then effectiveEnd - #duration(1, 0, 0, 0) else startTime,
        requestedAggregation = if aggregation = null or Text.Trim(aggregation) = "" then "mean" else Text.Lower(Text.Trim(aggregation)),
        effectiveWindow = if requestedAggregation = "raw" then null else if window = null then #duration(0, 0, 5, 0) else window,
        effectiveAggregation = ValidateAggregation(requestedAggregation, effectiveWindow),
        effectiveFieldName = if fieldName = null or Text.Trim(fieldName) = "" then "value" else Text.Trim(fieldName),
        checkedRange = if effectiveEnd <= effectiveStart then error Error.Record("InvalidTimeRange", "Browse end time must be after browse start time.", [Start = effectiveStart, End = effectiveEnd]) else true,
        measurementBrowser = if checkedRange then BuildMeasurementBrowser(filteredEntities, normalizedServer, normalizedDatabase, effectiveStart, effectiveEnd, effectiveAggregation, effectiveWindow, effectiveFieldName) else #table({}, {}),
        diagnostics = #table(
            type table [Property = text, Value = text],
            {
                {"Connector version", ConnectorVersion},
                {"Backend", "InfluxDB 1.x / InfluxQL"},
                {"Server", normalizedServer},
                {"Database", normalizedDatabase},
                {"Measurement filter", if measurementFilter = null then "" else Text.Trim(measurementFilter)},
                {"Entity filter", if entityFilter = null then "" else Text.Trim(entityFilter)},
                {"Browse start", FormatUtc(effectiveStart)},
                {"Browse end", FormatUtc(effectiveEnd)},
                {"Browse aggregation", effectiveAggregation},
                {"Browse window", if effectiveWindow = null then "" else InfluxDuration(effectiveWindow)},
                {"InfluxDB field", effectiveFieldName},
                {"Transport security", if Text.StartsWith(normalizedServer, "https://", Comparer.OrdinalIgnoreCase) then "HTTPS" else "WARNING: HTTP sends Basic credentials without transport encryption"},
                {"Default entity tag", "entity_id"},
                {"Default numeric field", "value"}
            }
        ),
        objects = #table(
            {"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"},
            {
                {"Browse by measurement", "measurement-browser", measurementBrowser, "Folder", "Folder", false},
                {"Filtered entities", "filtered-entities", filteredEntities, "Table", "Table", true},
                {"All entities", "entities", entities, "Table", "Table", true},
                {"Measurements", "measurements", measurements, "Table", "Table", true},
                {"Diagnostics", "diagnostics", diagnostics, "Table", "Table", true}
            }
        )
    in
        Table.ToNavigationTable(objects, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf");

FilterEntityCatalog = (entities as table, measurementFilter as nullable text, entityFilter as nullable text) as table =>
    let
        normalizedMeasurementFilter = if measurementFilter = null then "" else Text.Lower(Text.Trim(measurementFilter)),
        normalizedEntityFilter = if entityFilter = null then "" else Text.Lower(Text.Trim(entityFilter)),
        filtered = Table.SelectRows(
            entities,
            each
                let
                    measurementText = if [Measurement] = null then "" else Text.Lower(Text.From([Measurement])),
                    entityText = if [EntityId] = null then "" else Text.Lower(Text.From([EntityId]))
                in
                    (normalizedMeasurementFilter = "" or Text.Contains(measurementText, normalizedMeasurementFilter))
                    and (normalizedEntityFilter = "" or Text.Contains(entityText, normalizedEntityFilter))
        )
    in
        filtered;

BuildMeasurementBrowser = (
    entities as table,
    server as text,
    database as text,
    startTime as datetimezone,
    endTime as datetimezone,
    aggregation as text,
    window as nullable duration,
    fieldName as text
) as table =>
    let
        usableEntities = Table.SelectRows(entities, each [EntityId] <> null and [Measurement] <> null),
        measurements = List.Sort(List.Distinct(Table.Column(usableEntities, "Measurement"))),
        rows = List.Transform(
            measurements,
            (measurement as text) =>
                let
                    matchingEntities = Table.SelectRows(usableEntities, each [Measurement] = measurement),
                    entityCount = Table.RowCount(matchingEntities),
                    label = measurement & " (" & Number.ToText(entityCount, "0", "en-US") & ")"
                in
                    {
                        label,
                        measurement,
                        BuildEntityBrowser(matchingEntities, server, database, measurement, startTime, endTime, aggregation, window, fieldName),
                        "Folder",
                        "Folder",
                        false
                    }
        ),
        browser = #table({"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"}, rows)
    in
        Table.ToNavigationTable(browser, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf");

BuildEntityBrowser = (
    entities as table,
    server as text,
    database as text,
    measurement as text,
    startTime as datetimezone,
    endTime as datetimezone,
    aggregation as text,
    window as nullable duration,
    fieldName as text
) as table =>
    let
        entityIds = List.Sort(List.Distinct(Table.Column(entities, "EntityId"))),
        rows = List.Transform(
            entityIds,
            (entityId as text) =>
                {
                    entityId,
                    entityId,
                    HomeAssistantInflux.HistoryImpl(server, database, {entityId}, startTime, endTime, aggregation, window, measurement, "entity_id", fieldName),
                    "Table",
                    "Table",
                    true
                }
        ),
        browser = #table({"Name", "Key", "Data", "ItemKind", "ItemName", "IsLeaf"}, rows)
    in
        Table.ToNavigationTable(browser, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf");

HomeAssistantInflux.HistoryImpl = (
    server as text,
    database as text,
    entityIds as list,
    startTime as datetimezone,
    endTime as datetimezone,
    optional aggregation as nullable text,
    optional window as nullable duration,
    optional measurement as nullable text,
    optional entityTag as nullable text,
    optional fieldName as nullable text
) as table =>
    let
        connection = NormalizeConnectionArguments(server, database),
        normalizedServer = connection[Server],
        normalizedDatabase = connection[Database],
        normalizedEntities = ValidateEntityIds(entityIds),
        normalizedAggregation = ValidateAggregation(aggregation, window),
        normalizedEntityTag = if entityTag = null or Text.Trim(entityTag) = "" then "entity_id" else Text.Trim(entityTag),
        normalizedFieldName = if fieldName = null or Text.Trim(fieldName) = "" then "value" else Text.Trim(fieldName),
        query = BuildHistoryQuery(normalizedEntities, startTime, endTime, normalizedAggregation, window, measurement, normalizedEntityTag, normalizedFieldName),
        parsed = InfluxQuery(normalizedServer, normalizedDatabase, query),
        normalized = NormalizeHistory(parsed, normalizedEntityTag, normalizedAggregation, normalizedFieldName)
    in
        normalized;

NormalizeConnectionArguments = (server as text, database as text) as record =>
    let
        trimmedServer = Text.Trim(server),
        trimmedDatabase = Text.Trim(database),
        scheme = try Text.Lower(Uri.Parts(trimmedServer)[Scheme]) otherwise null,
        validScheme = scheme = "http" or scheme = "https",
        normalizedServer = if Text.EndsWith(trimmedServer, "/") then Text.Start(trimmedServer, Text.Length(trimmedServer) - 1) else trimmedServer
    in
        if not validScheme then error Error.Record("InvalidServer", "InfluxDB server must be an absolute HTTP or HTTPS URL.", [Server = server])
        else if trimmedDatabase = "" then error Error.Record("InvalidDatabase", "InfluxDB database must not be empty.", null)
        else [Server = normalizedServer, Database = trimmedDatabase];

ValidateEntityIds = (entityIds as list) as list =>
    let
        textIds = List.Transform(entityIds, each if _ is text then Text.Trim(_) else error Error.Record("InvalidEntity", "Every entity ID must be text.", [Value = _])),
        nonEmpty = List.Select(textIds, each _ <> ""),
        distinct = List.Distinct(nonEmpty)
    in
        if List.IsEmpty(distinct) then error Error.Record("MissingEntity", "At least one entity ID is required.", null)
        else if List.Count(distinct) > 100 then error Error.Record("TooManyEntities", "A single query supports at most 100 entity IDs.", [Count = List.Count(distinct)])
        else distinct;

ValidateAggregation = (aggregation as nullable text, window as nullable duration) as text =>
    let
        normalized = if aggregation = null or Text.Trim(aggregation) = "" then "raw" else Text.Lower(Text.Trim(aggregation)),
        supported = List.Contains(SupportedAggregations, normalized),
        hasValidWindow = window <> null and Duration.TotalSeconds(window) >= 1
    in
        if not supported then error Error.Record("UnsupportedAggregation", "Aggregation must be raw, mean, min, max, sum, last, or count.", [Aggregation = aggregation])
        else if normalized <> "raw" and not hasValidWindow then error Error.Record("InvalidWindow", "A positive aggregation window of at least one second is required.", [Aggregation = normalized])
        else normalized;

BuildHistoryQuery = (
    entityIds as list,
    startTime as datetimezone,
    endTime as datetimezone,
    aggregation as text,
    window as nullable duration,
    measurement as nullable text,
    entityTag as text,
    fieldName as text
) as text =>
    let
        checkedRange = if endTime <= startTime then error Error.Record("InvalidTimeRange", "End time must be after start time.", [Start = startTime, End = endTime]) else true,
        entityPredicate = Text.Combine(List.Transform(entityIds, each BuildEntityPredicate(_, entityTag)), " OR "),
        source = if measurement = null or Text.Trim(measurement) = "" then "/.*/" else InfluxIdentifier(Text.Trim(measurement)),
        selector = if aggregation = "raw" then
            Text.Combine({InfluxIdentifier(fieldName), InfluxIdentifier(entityTag), InfluxIdentifier("domain"), InfluxIdentifier("unit_of_measurement")}, ", ")
        else
            aggregation & "(" & InfluxIdentifier(fieldName) & ") AS " & InfluxIdentifier(fieldName),
        whereClause = "time >= " & InfluxString(FormatUtc(startTime)) & " AND time < " & InfluxString(FormatUtc(endTime)) & " AND (" & entityPredicate & ")",
        groupClause = if aggregation = "raw" then "" else " GROUP BY time(" & InfluxDuration(window) & "), " & InfluxIdentifier(entityTag) & ", " & InfluxIdentifier("domain") & ", " & InfluxIdentifier("unit_of_measurement") & " fill(none)",
        query = "SELECT " & selector & " FROM " & source & " WHERE " & whereClause & groupClause & " ORDER BY time ASC"
    in
        if checkedRange then query else "";

BuildEntityPredicate = (entityId as text, entityTag as text) as text =>
    let
        segments = Text.Split(entityId, "."),
        hasDomain = List.Count(segments) > 1,
        domain = if hasDomain then List.First(segments) else null,
        objectId = if hasDomain then Text.Combine(List.Skip(segments), ".") else entityId,
        directMatch = InfluxIdentifier(entityTag) & " = " & InfluxString(entityId),
        splitMatch = if hasDomain then "(" & InfluxIdentifier(entityTag) & " = " & InfluxString(objectId) & " AND " & InfluxIdentifier("domain") & " = " & InfluxString(domain) & ")" else null
    in
        if splitMatch = null then "(" & directMatch & ")" else "(" & directMatch & " OR " & splitMatch & ")";

DiscoverEntities = (server as text, database as text, entityTag as text) as table =>
    let
        query = "SHOW TAG VALUES ON " & InfluxIdentifier(database) & " WITH KEY = " & InfluxIdentifier(entityTag),
        parsed = InfluxQuery(server, database, query),
        withEntity = if Table.HasColumns(parsed, "value") then Table.AddColumn(parsed, "EntityId", each Text.From([value]), type text) else #table(type table [EntityId = nullable text], {}),
        withMeasurement = if Table.HasColumns(withEntity, "Measurement") then withEntity else Table.AddColumn(withEntity, "Measurement", each null, type nullable text),
        selected = Table.SelectColumns(withMeasurement, {"EntityId", "Measurement"}),
        distinct = if Table.HasColumns(selected, "Measurement") then Table.Distinct(selected, {"Measurement", "EntityId"}) else Table.Distinct(selected, {"EntityId"}),
        sorted = Table.Sort(distinct, {{"EntityId", Order.Ascending}})
    in
        sorted;

DiscoverMeasurements = (server as text, database as text) as table =>
    let
        query = "SHOW MEASUREMENTS ON " & InfluxIdentifier(database),
        parsed = InfluxQuery(server, database, query),
        withoutSeriesName = if Table.HasColumns(parsed, "Measurement") then Table.RemoveColumns(parsed, {"Measurement"}) else parsed,
        renamed = if Table.HasColumns(withoutSeriesName, "name") then Table.RenameColumns(withoutSeriesName, {{"name", "Measurement"}}) else #table(type table [Measurement = nullable text], {}),
        selected = Table.SelectColumns(renamed, List.Intersect({{"Measurement"}, Table.ColumnNames(renamed)})),
        sorted = Table.Sort(selected, {{"Measurement", Order.Ascending}})
    in
        sorted;

InfluxQuery = (server as text, database as text, query as text) as table =>
    let
        credential = Extension.CurrentCredential(),
        username = Record.FieldOrDefault(credential, "Username", null),
        password = Record.FieldOrDefault(credential, "Password", null),
        checkedUsername = if username = null or Text.Trim(username) = "" then error Error.Record("MissingCredential", "Enter the InfluxDB username and password.", null) else username,
        checkedPassword = if password = null then error Error.Record("MissingCredential", "Enter the InfluxDB username and password.", null) else password,
        basicCredential = Binary.ToText(Text.ToBinary(checkedUsername & ":" & checkedPassword, TextEncoding.Utf8), BinaryEncoding.Base64),
        checkedResponse = RequestInfluxWithRetry(server, database, query, basicCredential, 0),
        document = Json.Document(checkedResponse),
        apiError = Record.FieldOrDefault(document, "error", null),
        checkedDocument = if apiError <> null then error Error.Record("InfluxDbQueryError", Text.From(apiError), null) else document,
        parsed = ParseInfluxJson(checkedDocument)
    in
        parsed;

RequestInfluxWithRetry = (server as text, database as text, query as text, basicCredential as text, attempt as number) as binary =>
    let
        response = Web.Contents(
            server,
            [
                RelativePath = "query",
                Query = [db = database, q = query],
                Headers = [Authorization = "Basic " & basicCredential, Accept = "application/json"],
                ManualCredentials = true,
                ManualStatusHandling = {400, 401, 403, 404, 408, 413, 429, 500, 502, 503, 504},
                Timeout = #duration(0, 0, 2, 0),
                IsRetry = attempt > 0
            ]
        ),
        metadata = Value.Metadata(response),
        status = Record.FieldOrDefault(metadata, "Response.Status", 200),
        retryable = List.Contains({408, 429, 500, 502, 503, 504}, status),
        delay = #duration(0, 0, 0, Number.Power(2, attempt))
    in
        if status >= 200 and status < 300 then response
        else if retryable and attempt < 3 then Function.InvokeAfter(() => @RequestInfluxWithRetry(server, database, query, basicCredential, attempt + 1), delay)
        else RaiseHttpError(status, response);

ParseInfluxJson = (document as record) as table =>
    let
        results = Record.FieldOrDefault(document, "results", {}),
        resultErrors = List.RemoveNulls(List.Transform(results, each Record.FieldOrDefault(_, "error", null))),
        checkedResults = if not List.IsEmpty(resultErrors) then error Error.Record("InfluxDbQueryError", Text.From(List.First(resultErrors)), null) else results,
        series = List.Combine(List.Transform(checkedResults, each Record.FieldOrDefault(_, "series", {}))),
        tables = List.Transform(series, each SeriesToTable(_)),
        combined = if List.IsEmpty(tables) then #table({}, {}) else Table.Combine(tables)
    in
        combined;

SeriesToTable = (series as record) as table =>
    let
        columns = Record.FieldOrDefault(series, "columns", {}),
        values = Record.FieldOrDefault(series, "values", {}),
        base = Table.FromRows(values, columns),
        measurement = Record.FieldOrDefault(series, "name", null),
        withMeasurement = Table.AddColumn(base, "Measurement", each measurement, type nullable text),
        tags = Record.FieldOrDefault(series, "tags", []),
        withTags = List.Accumulate(Record.FieldNames(tags), withMeasurement, (state as table, tag as text) => if Table.HasColumns(state, tag) then state else Table.AddColumn(state, tag, each Record.Field(tags, tag)))
    in
        withTags;

RaiseHttpError = (status as number, response as binary) =>
    let
        responseText = try Text.FromBinary(response, TextEncoding.Utf8) otherwise "",
        safeDetail = if Text.Length(responseText) > 1000 then Text.Start(responseText, 1000) & "..." else responseText,
        message = if status = 401 then "InfluxDB rejected the username or password."
            else if status = 403 then "The InfluxDB user cannot read the requested database. Verify the database name and the user's read permission."
            else if status = 404 then "InfluxDB query endpoint or database was not found."
            else if status = 413 then "InfluxDB rejected the query because the response is too large. Reduce the time range or aggregate the data."
            else if status = 429 then "InfluxDB rate limit exceeded. Retry later or reduce refresh concurrency."
            else if status >= 500 then "InfluxDB is temporarily unavailable."
            else "InfluxDB rejected the InfluxQL query."
    in
        error Error.Record("InfluxDbHttpError", message, [Status = status, Response = safeDetail]);

NormalizeHistory = (source as table, entityTag as text, aggregation as text, fieldName as text) as table =>
    let
        empty = #table(type table [Timestamp = nullable datetimezone, EntityId = nullable text, Domain = nullable text, Value = nullable number, ValueText = nullable text, ValueBoolean = nullable logical, Unit = nullable text, Measurement = nullable text, Field = nullable text, Aggregation = text], {}),
        result = if not Table.HasColumns(source, {"time", fieldName}) then empty else
            let
                withTimestamp = Table.AddColumn(source, "Timestamp", each try DateTimeZone.FromText(Text.From([time]), "en-US") otherwise null, type nullable datetimezone),
                withEntity = Table.AddColumn(withTimestamp, "EntityId", each FullEntityId(Record.FieldOrDefault(_, entityTag, null), Record.FieldOrDefault(_, "domain", null)), type nullable text),
                withValue = Table.AddColumn(withEntity, "Value", each let raw = Record.Field(_, fieldName) in if raw is number then Number.From(raw) else null, type nullable number),
                withValueText = Table.AddColumn(withValue, "ValueText", each let raw = Record.Field(_, fieldName) in if raw is text then raw else null, type nullable text),
                withValueBoolean = Table.AddColumn(withValueText, "ValueBoolean", each let raw = Record.Field(_, fieldName) in if raw is logical then raw else null, type nullable logical),
                withUnit = Table.AddColumn(withValueBoolean, "Unit", each try Text.From(Record.FieldOrDefault(_, "unit_of_measurement", null)) otherwise null, type nullable text),
                withField = Table.AddColumn(withUnit, "Field", each fieldName, type text),
                withAggregation = Table.AddColumn(withField, "Aggregation", each aggregation, type text),
                selected = Table.SelectColumns(withAggregation, List.Intersect({{"Timestamp", "EntityId", "domain", "Value", "ValueText", "ValueBoolean", "Unit", "Measurement", "Field", "Aggregation"}, Table.ColumnNames(withAggregation)})),
                renamed = Table.RenameColumns(selected, {{"domain", "Domain"}}, MissingField.Ignore),
                ordered = Table.ReorderColumns(renamed, {"Timestamp", "EntityId", "Domain", "Value", "ValueText", "ValueBoolean", "Unit", "Measurement", "Field", "Aggregation"}, MissingField.UseNull),
                typed = Value.ReplaceType(ordered, Value.Type(empty))
            in
                typed
    in
        result;

FullEntityId = (rawEntity as any, rawDomain as any) as nullable text =>
    let
        entity = if rawEntity = null then null else Text.From(rawEntity),
        domain = if rawDomain = null then null else Text.From(rawDomain)
    in
        if entity = null or entity = "" then null
        else if Text.Contains(entity, ".") or domain = null or domain = "" then entity
        else domain & "." & entity;

InfluxIdentifier = (value as text) as text =>
    let
        quote = Character.FromNumber(34),
        backslash = Character.FromNumber(92)
    in
        quote & Text.Replace(value, quote, backslash & quote) & quote;

InfluxString = (value as text) as text =>
    let
        apostrophe = Character.FromNumber(39),
        backslash = Character.FromNumber(92),
        escapedBackslash = Text.Replace(value, backslash, backslash & backslash),
        escapedApostrophe = Text.Replace(escapedBackslash, apostrophe, backslash & apostrophe)
    in
        apostrophe & escapedApostrophe & apostrophe;

InfluxDuration = (value as nullable duration) as text => Number.ToText(Number.RoundDown(Duration.TotalSeconds(value)), "0", "en-US") & "s";

FormatUtc = (value as datetimezone) as text => DateTimeZone.ToText(DateTimeZone.SwitchZone(value, 0), "yyyy-MM-ddTHH:mm:ss.fffffffZ", "en-US");

Table.ToNavigationTable = (table as table, keyColumns as list, nameColumn as text, dataColumn as text, itemKindColumn as text, itemNameColumn as text, isLeafColumn as text) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta [
            NavigationTable.NameColumn = nameColumn,
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn,
            Preview.DelayColumn = itemNameColumn,
            NavigationTable.IsLeafColumn = isLeafColumn
        ]
    in
        Value.ReplaceType(table, newTableType);

HomeAssistantInflux = [
    TestConnection = (dataSourcePath) =>
        let
            path = Json.Document(dataSourcePath)
        in
            {"HomeAssistantInflux.Database", path[server], path[database]},
    Authentication = [UsernamePassword = []],
    Label = "Home Assistant InfluxDB"
];

HomeAssistantInflux.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = {"Home Assistant InfluxDB", "Load Home Assistant history from InfluxDB 1.x"},
    LearnMoreUrl = "https://github.com/klabir/PowerQueryInfluxHomeAssistant",
    SourceImage = HomeAssistantInflux.Icons,
    SourceTypeImage = HomeAssistantInflux.Icons
];

HomeAssistantInflux.Icons = [
    Icon16 = {
        Extension.Contents("HomeAssistantInflux16.png"),
        Extension.Contents("HomeAssistantInflux20.png"),
        Extension.Contents("HomeAssistantInflux24.png"),
        Extension.Contents("HomeAssistantInflux32.png")
    },
    Icon32 = {
        Extension.Contents("HomeAssistantInflux32.png"),
        Extension.Contents("HomeAssistantInflux40.png"),
        Extension.Contents("HomeAssistantInflux48.png"),
        Extension.Contents("HomeAssistantInflux64.png")
    }
];
