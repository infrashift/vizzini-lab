/**
 * Lowercases a title and joins its ASCII letters and digits with hyphens,
 * e.g. "Hello, World!" gives "hello-world".
 */
export function slugify(title: string): string {
  return title
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
