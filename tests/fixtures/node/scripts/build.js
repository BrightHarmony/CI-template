import { mkdir, writeFile } from "node:fs/promises";

await mkdir("dist", { recursive: true });
await writeFile("dist/build.txt", "fixture build succeeded\n", "utf8");
