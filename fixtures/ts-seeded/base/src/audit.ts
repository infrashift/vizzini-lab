export interface AuditEvent {
  actor: string;
  action: string;
  at: Date;
}

const events: AuditEvent[] = [];

export async function saveAudit(event: AuditEvent): Promise<void> {
  await Promise.resolve();
  events.push(event);
}

export function recentAudit(limit: number): AuditEvent[] {
  return events.slice(-limit);
}
