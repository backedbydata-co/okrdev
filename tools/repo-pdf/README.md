# repo-pdf

Renders this repository as a single typeset PDF — `dist/okrdev-repo.pdf`.

Markdown files are rendered as documents, not dumped as source: headings, tables, code blocks,
task lists and links all come out formatted. Anything else becomes a syntax-highlighted listing
with line numbers.

By default the export is the prose: `examples/` is excluded, and so is source and config —
scripts, workflows, manifests and dotfiles, detected by extension, by a leading dot, or by a
shebang. `LICENSE` and `CODEOWNERS` are prose with comments, not code, and stay. Pass
`--with-code` for the whole tree.

```bash
npm --prefix tools/repo-pdf install
node tools/repo-pdf/build.mjs
```

Flags:

| Flag | Effect |
|------|--------|
| `--out <path>` | Output path, relative to the repo root. Default `dist/okrdev-repo.pdf`. |
| `--with-code` | Include source and config files as listings. |
| `--no-running-heads` | Drop the per-page file path at the top of each page. |
| `--html <path>` | Also write the intermediate HTML — useful when debugging layout. |

Whatever is excluded is enumerated on the document's own *About this document* page, with the
reason — a file can never drop out of the export silently.

## How it works

`git ls-files` is the source of truth, so the PDF can only contain files the repository
actually tracks. Files are grouped into parts by the `PARTS` table in `build.mjs`; anything
not listed there still lands in a part by path prefix, or in **Other files** if nothing claims
it. Adding a file to the repo never silently drops it from the export.

Rendering is Chromium via Playwright. The build runs it twice: the first pass discovers which
page each file landed on by reading back the PDF's text layer, and the second bakes those
numbers into the contents pages. Passes repeat (up to three) until the numbers stop moving.

## Things worth knowing before editing

- **HTML comments are content.** Several files carry their real instructions in
  `<!-- ... -->`, which GitHub hides. They are lifted out and typeset as grey notes — except
  inside fenced code blocks, where they are example content and must be left alone.
- **Front matter is shown verbatim**, not parsed into a table, because parsing it would throw
  away the inline `#` comments that explain each key.
- **Never let anything exceed the text column.** Chromium responds to a single over-wide
  element by shrink-to-fitting the *whole document*, which silently ruins every page. Long
  unbreakable tokens need `overflow-wrap: anywhere` (`break-word` does not shrink min-content
  width), and the per-file wrapper table needs `table-layout: fixed`. Check with
  `--html` and measure `document.body.scrollWidth`: it must equal the content width.
- **Code blocks are auto-sized** to their longest line so ASCII diagrams survive; listings are
  sized to their 97th-percentile line so one outlier does not shrink a whole file.

## Fonts

Inter and Source Serif 4 are embedded from the `@fontsource` packages as base64 woff2, so the
PDF is self-contained. Monospace is DejaVu Sans Mono from the host: it covers the box-drawing
characters the docs use for diagrams, at a single consistent advance width.
