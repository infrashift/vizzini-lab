import { execSync } from "node:child_process";

export function exportReport(name: string): Buffer {
  return execSync("pdf-render --out /tmp/reports " + name + ".pdf");
}
