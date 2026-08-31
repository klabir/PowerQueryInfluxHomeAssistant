import { mkdir, writeFile } from "node:fs/promises";
import { deflateSync } from "node:zlib";

const sizes = [16, 20, 24, 32, 40, 48, 64];
const outputDirectory = new URL("../assets/", import.meta.url);
await mkdir(outputDirectory, { recursive: true });

const crcTable = Array.from({ length: 256 }, (_, index) => {
  let value = index;
  for (let bit = 0; bit < 8; bit += 1) {
    value = (value & 1) !== 0 ? 0xedb88320 ^ (value >>> 1) : value >>> 1;
  }
  return value >>> 0;
});

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) crc = crcTable[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}

function chunk(name, data) {
  const type = Buffer.from(name, "ascii");
  const length = Buffer.alloc(4);
  length.writeUInt32BE(data.length);
  const checksum = Buffer.alloc(4);
  checksum.writeUInt32BE(crc32(Buffer.concat([type, data])));
  return Buffer.concat([length, type, data, checksum]);
}

function segmentDistance(x, y, x1, y1, x2, y2) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const projection = Math.max(0, Math.min(1, ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)));
  return Math.hypot(x - (x1 + projection * dx), y - (y1 + projection * dy));
}

function pixel(x, y) {
  const radius = 0.19;
  const edgeX = Math.max(radius - x, 0, x - (1 - radius));
  const edgeY = Math.max(radius - y, 0, y - (1 - radius));
  const insideBackground = edgeX * edgeX + edgeY * edgeY <= radius * radius;
  if (!insideBackground) return [0, 0, 0, 0];

  const whiteWidth = 0.065;
  const roof = Math.min(segmentDistance(x, y, 0.2, 0.49, 0.5, 0.22), segmentDistance(x, y, 0.5, 0.22, 0.8, 0.49));
  const wall = Math.min(
    segmentDistance(x, y, 0.25, 0.45, 0.25, 0.78),
    segmentDistance(x, y, 0.75, 0.45, 0.75, 0.78),
    segmentDistance(x, y, 0.25, 0.78, 0.75, 0.78),
  );
  if (Math.min(roof, wall) < whiteWidth) return [255, 255, 255, 255];

  const chart = Math.min(
    segmentDistance(x, y, 0.32, 0.67, 0.43, 0.56),
    segmentDistance(x, y, 0.43, 0.56, 0.53, 0.64),
    segmentDistance(x, y, 0.53, 0.64, 0.68, 0.44),
  );
  if (chart < 0.05) return [255, 193, 7, 255];
  return [19, 128, 125, 255];
}

function createPng(size) {
  const scale = 4;
  const rows = [];
  for (let y = 0; y < size; y += 1) {
    const row = [0];
    for (let x = 0; x < size; x += 1) {
      const totals = [0, 0, 0, 0];
      for (let sy = 0; sy < scale; sy += 1) {
        for (let sx = 0; sx < scale; sx += 1) {
          const sample = pixel((x + (sx + 0.5) / scale) / size, (y + (sy + 0.5) / scale) / size);
          sample.forEach((value, channel) => { totals[channel] += value; });
        }
      }
      row.push(...totals.map((value) => Math.round(value / (scale * scale))));
    }
    rows.push(...row);
  }

  const header = Buffer.alloc(13);
  header.writeUInt32BE(size, 0);
  header.writeUInt32BE(size, 4);
  header[8] = 8;
  header[9] = 6;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk("IHDR", header),
    chunk("IDAT", deflateSync(Buffer.from(rows))),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}

for (const size of sizes) {
  await writeFile(new URL(`HomeAssistantInflux${size}.png`, outputDirectory), createPng(size));
}

console.log(`Generated ${sizes.length} connector icons.`);
