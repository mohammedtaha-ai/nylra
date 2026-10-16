import { test } from "node:test";
import assert from "node:assert/strict";
import { build } from "vite";
test("production includes companion and excludes studio modules and remote assets", async () => {
  const ids: string[] = [];
  const resources: string[] = [];
  await build({
    logLevel: "silent",
    build: { write: false },
    plugins: [
      {
        name: "inspect-companion-output",
        generateBundle(_options, bundle) {
          for (const output of Object.values(bundle)) {
            if (output.type === "chunk")
              ids.push(
                ...output.moduleIds.map((id) => id.replaceAll("\\", "/")),
              );
            else if (/\.(html|css)$/.test(output.fileName))
              resources.push(String(output.source));
          }
        },
      },
    ],
  });
  assert.ok(
    ids.some((id) => id.endsWith("/companion/Companion.tsx")),
    "production companion must be bundled",
  );
  assert.ok(
    !ids.some((id) => id.includes("/companion/studio/")),
    "development studio must not be bundled",
  );
  assert.ok(
    !ids.some((id) => id.includes("/tests/companion/")),
    "test fixture must not be bundled",
  );
  assert.ok(
    resources.every(
      (value) =>
        !value.includes("cdn.tailwindcss.com") &&
        !value.includes("fonts.googleapis.com"),
    ),
  );
});
