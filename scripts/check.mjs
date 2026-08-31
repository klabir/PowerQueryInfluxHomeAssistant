import { access, readFile, readdir } from "node:fs/promises";
import { DefaultSettings, TaskUtils } from "@microsoft/powerquery-parser";

const sourceDirectory = new URL("../src/", import.meta.url);
const exampleDirectory = new URL("../examples/", import.meta.url);
const sourceFiles = (await readdir(sourceDirectory)).filter((file) => file.endsWith(".pq"));
const exampleFiles = (await readdir(exampleDirectory)).filter((file) => file.endsWith(".pq"));

if (sourceFiles.length === 0) {
  throw new Error("No Power Query source files found.");
}

for (const [directory, file] of [
  ...sourceFiles.map((file) => [sourceDirectory, file]),
  ...exampleFiles.map((file) => [exampleDirectory, file]),
]) {
  const text = await readFile(new URL(file, directory), "utf8");
  const result = await TaskUtils.tryLexParse(DefaultSettings, text);

  if (!TaskUtils.isParseStageOk(result)) {
    throw new Error(`${file}: ${result.error.message}`);
  }
}

const connector = await readFile(new URL("../src/HomeAssistantInflux.pq", import.meta.url), "utf8");
const project = await readFile(new URL("../PowerQueryInfluxHomeAssistant.proj", import.meta.url), "utf8");
const requiredFragments = [
  "Extension.CurrentCredential()",
  "ManualCredentials = true",
  "RelativePath = \"query\"",
  "SHOW MEASUREMENTS ON",
  "shared HomeAssistantInflux.Browse",
  "shared HomeAssistantInflux.BrowseRange",
  "HomeAssistantInflux.BrowseType",
  "All available data",
  "Custom range",
  "Custom start time",
  "Custom end time",
  "InfluxDB field",
  "ResolveBrowsePeriod",
  "AutomaticBrowseWindow",
  "MissingCustomStart",
  "MissingCustomEnd",
  "#datetimezone(1970, 1, 1",
  "FilterEntityCatalog",
  "BuildMeasurementBrowser",
  "BuildEntityBrowser",
  "ValueText",
  "ValueBoolean",
  "RequestInfluxWithRetry",
  "IsRetry = attempt > 0",
  "SourceImage = HomeAssistantInflux.Icons",
  "SourceTypeImage = HomeAssistantInflux.Icons",
  "Measurement contains",
  "Entity contains",
  "HomeAssistantInflux.HistoryImpl(server, database, {entityId}",
  "BuildEntityPredicate",
  "GROUP BY time(",
  "Database = trimmedDatabase",
  "DiscoverEntities(normalizedServer, normalizedDatabase",
  "InfluxQuery(normalizedServer, normalizedDatabase",
  "Table.RemoveColumns(parsed, {\"Measurement\"})",
  "DataSource.Path = false",
  "ManualStatusHandling",
];

for (const fragment of requiredFragments) {
  if (!connector.includes(fragment)) {
    throw new Error(`Missing required connector behavior: ${fragment}`);
  }
}

for (const size of [16, 20, 24, 32, 40, 48, 64]) {
  const iconName = `HomeAssistantInflux${size}.png`;
  await access(new URL(`../assets/${iconName}`, import.meta.url));
  if (!connector.includes(`Extension.Contents(\"${iconName}\")`)) {
    throw new Error(`${iconName} is not referenced by the connector.`);
  }
  if (!project.includes(`assets\\${iconName}`)) {
    throw new Error(`${iconName} is missing from the .proj package manifest.`);
  }
}

const forbiddenPatterns = [
  /Token\s+[A-Za-z0-9_-]{20,}/,
  /api[_-]?token\s*=\s*"[^"]+"/i,
  /password\s*=\s*"[^"]+"/i,
];

for (const pattern of forbiddenPatterns) {
  if (pattern.test(connector)) {
    throw new Error(`Potential credential found in source: ${pattern}`);
  }
}

for (const file of sourceFiles) {
  const projectPath = `src\\${file}`;
  if (!project.includes(projectPath)) {
    throw new Error(`${projectPath} is missing from the .proj package manifest.`);
  }
}

const packageJson = JSON.parse(await readFile(new URL("../package.json", import.meta.url), "utf8"));
if (packageJson.name !== "power-query-influx-home-assistant") {
  throw new Error("Unexpected package name.");
}
if (packageJson.version !== connector.match(/ConnectorVersion = "([^"]+)";/)?.[1]) {
  throw new Error("package.json and ConnectorVersion must match.");
}

console.log(`Validated ${sourceFiles.length} connector source and ${exampleFiles.length} example.`);
