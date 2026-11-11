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
