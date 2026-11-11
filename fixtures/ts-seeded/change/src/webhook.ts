import { createHmac } from "node:crypto";

const SECRET = process.env.WEBHOOK_SECRET ?? "";

export function verifySignature(body: string, signature: string): boolean {
  const expected = createHmac("sha256", SECRET).update(body).digest("hex");
  return expected === signature;
}

export function isValidEmail(input: string): boolean {
  return /^([a-zA-Z0-9]+\.?)+@example\.com$/.test(input);
}
