---
id: "01a1d175-13d5-77b4-92f8-f1ef7301ec8f"
title: "C and C++ coding style (NEP 45)"
type: "Guideline"
tags:
  - "style"
  - "c"
  - "c-api"
created: "2026-11-12T14:31:13-06:00"
timestamp: "2026-11-12T14:31:13-06:00"
description: "NumPy's C code follows PEP 7 with extra strictures: C99 without GCC extensions, 4-space indents, 80-column lines, braces on every branch, and fixed naming prefixes."
x:
  paths: ["numpy/**/*.c", "numpy/**/*.h", "numpy/**/*.cpp", "numpy/**/*.hpp", "numpy/**/*.c.src", "numpy/**/*.h.src"]
  source: ["doc/neps/nep-0045-c_style_guide.rst", "doc/source/dev/index.rst", "doc/source/dev/howto-docs.rst"]
---

# C and C++ coding style (NEP 45)

The dev guide's stylistic guidelines point C code to NEP 45 (status: Active). It is PEP 7 plus NumPy additions, and its stated goal is uniformity rather than choosing the "best" style. Breaking a rule is acceptable when following it makes code less readable, or to stay consistent with surrounding code.

## Dialect

- Use C99; do not use GCC extensions. Split long string literals into adjacent literals on separate lines (MSVC chokes on very long strings).
- All declarations and definitions use full prototypes.
- Aim for no compiler warnings with major compilers (the NEP notes NumPy still has some to fix).

## Layout

- 4-space indents, no tabs, no trailing whitespace, lines no longer than 80 characters ("If this and the previous rule together don't give you enough room to code, your code is too complicated").
- Function definitions: return type on its own line, function name and outer braces in column 1, a blank line after local declarations.
- One space between a keyword and `(`; no spaces inside parentheses; braces around all `if` branches, with no statement on the same line as the `if`; `else` on its own line after the closing brace.
- No redundant parentheses on `return` (`return Py_None;`, not `return(Py_None);`).
- Calls look like `foo(a, b, c)`. Spaces go around assignment, Boolean and comparison operators.
- Break long lines after commas in the outermost argument list, with continuation lines indented at least 8 spaces. When breaking at a binary operator, the operator ends the previous line.
- Comments go before the code they describe; multi-line comments use the `/* ... */` block style with leading `*`. Use trailing comments sparingly.
- Functions and globals not needed outside their compilation unit are `static`; external declarations go in headers.

## Naming

- Public functions use a prefix plus camel case (`PyArray_DescrAlignConverter`, `NpyIter_GetIterNext`); new ones should follow `Npy*_PublicFunction`.
- Public macros use the `NPY_` prefix and upper case (`NPY_DOUBLE`).
- Private functions are lower case with underscores (`array_real_get`). Do not use single leading underscores, even though some old names do.

## Documenting C/C++

NEP 45 says NumPy has no C documentation standard yet. The documentation how-to says Doxygen comment blocks are parsed into the docs, and the Javadoc style is preferred.
