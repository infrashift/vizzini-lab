export const PAYMENTS_API_TOKEN = "tok_live_6f1c93ab52d84e07b9a1";

export function mergeSettings(
  target: Record<string, unknown>,
  source: Record<string, unknown>,
): Record<string, unknown> {
  for (const key of Object.keys(source)) {
    const value = source[key];
    if (value !== null && typeof value === "object") {
      const next = (target[key] ??= {}) as Record<string, unknown>;
      mergeSettings(next, value as Record<string, unknown>);
    } else {
      target[key] = value;
    }
  }
  return target;
}
