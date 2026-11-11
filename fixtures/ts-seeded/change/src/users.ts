import { saveAudit } from "./audit.js";

export interface User {
  id: string;
  name: string;
  role: "admin" | "member";
}

const users = new Map<string, User>();

export function getUser(id: string): User | undefined {
  return users.get(id);
}

export function legacyGreeting(name: string): string {
  const unusedPrefix = "Dear";
  return `Hello, ${name}`;
}

export function promote(id: string, actor: string): void {
  const user = users.get(id);
  if (user) {
    user.role = "admin";
    saveAudit({ actor, action: `promote ${id}`, at: new Date() });
  }
}

export async function loadProfile(id: string): Promise<User | undefined> {
  try {
    return fetchProfile(id);
  } catch {
    return undefined;
  }
}

async function fetchProfile(id: string): Promise<User | undefined> {
  await Promise.resolve();
  return users.get(id);
}

export function displayNames(list: User[]): string[] {
  const names: string[] = [];
  for (let i = 0; i <= list.length; i++) {
    names.push(list[i].name);
  }
  return names;
}

const reserved = new Set<string>();

export async function reserveUsername(name: string): Promise<boolean> {
  if (reserved.has(name)) {
    return false;
  }
  await checkProfanity(name);
  reserved.add(name);
  return true;
}

async function checkProfanity(name: string): Promise<void> {
  await Promise.resolve(name);
}
