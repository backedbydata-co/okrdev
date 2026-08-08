#!/usr/bin/env node
/**
 * build.mjs — render this repository as a single, readable PDF.
 *
 *   node tools/repo-pdf/build.mjs [--out dist/okrdev-repo.pdf] [--no-running-heads]
 *
 * Markdown files are rendered as documents (headings, tables, callouts, code),
 * not dumped as source. Everything else is rendered as a numbered listing with
 * syntax highlighting. `examples/` is excluded by default.
 *
 * The build runs Chromium twice: the first pass discovers which PDF page each
 * file lands on, the second bakes those page numbers into the contents pages.
 */

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

import MarkdownIt from 'markdown-it';
import anchorPlugin from 'markdown-it-anchor';
import taskListPlugin from 'markdown-it-task-lists';
import hljs from 'highlight.js';

const require = createRequire(import.meta.url);
const HERE = path.dirname(fileURLToPath(import.meta.url));

/* ------------------------------------------------------------------ config -- */

const PAGE = {
  widthMm: 210,          // A4
  marginMm: { top: 16, bottom: 16, left: 22, right: 22 },
};
const CONTENT_MM = PAGE.widthMm - PAGE.marginMm.left - PAGE.marginMm.right;
const CONTENT_PT = mmToPt(CONTENT_MM);
const MONO_ADVANCE = 0.602;   // DejaVu Sans Mono advance width, in em

/** Extensions that make a file source rather than prose. */
const CODE_EXT = /\.(m?js|cjs|ts|tsx|jsx|ya?ml|json|sh|bash|zsh|css|scss|html?|py|rb|go|rs|toml|ini)$/i;

/**
 * Source, workflows, manifests and dotfile config. Detected by extension, by a
 * leading dot on the filename, or by a shebang — which is how the extensionless
 * scripts in this repo (tests/hooks/pre-push) get caught.
 */
function isCodeFile(root, p) {
  const base = path.basename(p);
  if (CODE_EXT.test(base) || base.startsWith('.')) return true;
  try {
    const fd = fs.openSync(path.join(root, p), 'r');
    const buf = Buffer.alloc(2);
    fs.readSync(fd, buf, 0, 2, 0);
    fs.closeSync(fd);
    return buf.toString('latin1') === '#!';
  } catch { return false; }
}

/** Paths never included, whatever else the tree looks like. */
function exclusions({ withCode, root }) {
  const rules = [
    { match: (p) => p === 'examples' || p.startsWith('examples/'),
      why: 'Worked example of a fictional company using okrdev — excluded by request.' },
    { match: (p) => p.startsWith('dist/'),
      why: 'Build output — including this document itself.' },
    { match: (p) => p.endsWith('package-lock.json') || p.endsWith('pnpm-lock.yaml'),
      why: 'Dependency lockfiles — machine-generated noise.' },
    { match: (p) => /\.(png|jpe?g|gif|svg|ico|pdf|zip|woff2?|ttf|otf)$/i.test(p),
      why: 'Binary assets — nothing to typeset.' },
  ];
  if (!withCode) {
    rules.push({
      match: (p) => isCodeFile(root, p),
      why: 'Source and config — scripts, workflows, manifests and dotfiles.',
    });
  }
  return rules;
}

/**
 * Reading order. Each part claims files by explicit list, by prefix, or both;
 * anything a part claims but does not order explicitly is appended
 * alphabetically, so new files still land somewhere sensible.
 */
const PARTS = [
  {
    id: 'overview',
    title: 'Overview',
    blurb: 'The pitch, the argument underneath it, and the coach contract this repository runs on itself.',
    order: ['README.md', 'MANIFESTO.md', 'CLAUDE.md', 'LICENSE'],
  },
  {
    id: 'docs',
    title: 'The method, documented',
    blurb: 'Reference documentation: every rule and its mechanics, the rituals as runnable scripts, the roles, the adoption ladder, and the optional stack module.',
    prefix: 'docs/',
    order: [
      'docs/method.md', 'docs/rituals.md', 'docs/parking-lot.md', 'docs/roles.md',
      'docs/dri-onboarding.md', 'docs/adoption.md', 'docs/ai-coach.md',
      'docs/live-coached-sessions.md', 'docs/evidence.md', 'docs/shipping-explained.md',
      'docs/stack.md', 'docs/testing.md',
    ],
  },
  {
    id: 'skills',
    title: 'Coach skills',
    blurb: 'The prompt files behind each /okrdev: command — the coach’s actual instructions, shipped as a Claude Code plugin.',
    prefix: 'skills/',
    order: [
      'skills/install/SKILL.md', 'skills/plan/SKILL.md', 'skills/checkin/SKILL.md',
      'skills/coach/SKILL.md', 'skills/park/SKILL.md', 'skills/triage/SKILL.md',
      'skills/side-quest/SKILL.md', 'skills/retro/SKILL.md',
    ],
  },
  {
    id: 'instance',
    title: 'okrdev running on okrdev',
    blurb: 'The live instance in this repository: its mission, config, the active cycle, weekly check-ins, the parking lot and the lessons file.',
    prefix: 'okrdev/',
    order: [
      'okrdev/MISSION.md', 'okrdev/config.md', 'okrdev/okrs/2026-Q3.md',
      'okrdev/checkins/2026-Q3/2026-W31.md', 'okrdev/checkins/2026-Q3/2026-W32.md',
      'okrdev/PARKING_LOT.md', 'okrdev/LESSONS.md',
    ],
  },
  {
    id: 'templates',
    title: 'Templates',
    blurb: 'What /okrdev:install writes into a target repo — the OKR scaffolding, the coach block, and the collaboration rails a team opts into at Level 2.',
    prefix: 'templates/',
    order: [
      'templates/CLAUDE-okrdev.md', 'templates/okrdev/config.md', 'templates/okrdev/MISSION.md',
      'templates/okrdev/okrs/cycle.md', 'templates/okrdev/checkins/checkin.md',
      'templates/okrdev/PARKING_LOT.md', 'templates/okrdev/LESSONS.md',
      'templates/github/pull_request_template.md', 'templates/github/CODEOWNERS',
      'templates/github/workflows/okr-gate.yml', 'templates/github/workflows/ci.yml',
      'templates/github/workflows/neon-cleanup.yml',
      'templates/stack/README.md', 'templates/stack/branch-protection.sh',
    ],
  },
  {
    id: 'tests',
    title: 'Tests and verification',
    blurb: 'How a prompt framework proves itself: what an install is allowed to write, enumerated, so the checks have something to hold it to.',
    prefix: 'tests/',
    order: ['tests/install-footprint.md', 'tests/check.sh', 'tests/gate-grammar.test.js', 'tests/hooks/pre-push'],
  },
  {
    id: 'plumbing',
    title: 'Plugin and CI plumbing',
    blurb: 'The plugin and marketplace manifests, this repository’s own CI workflow, and the headless installer.',
    prefixes: ['.claude-plugin/', '.github/'],
    order: ['.claude-plugin/plugin.json', '.claude-plugin/marketplace.json', '.github/workflows/check.yml', 'install.sh'],
  },
  {
    id: 'tooling',
    title: 'Build tooling',
    blurb: 'The generator that produced this document.',
    prefix: 'tools/',
  },
  {
    id: 'other',
    title: 'Other files',
    blurb: 'Everything else tracked in the repository.',
    catchAll: true,
  },
];

/** Language hints for files whose extension does not settle it. */
const LANG_BY_NAME = {
  'CODEOWNERS': 'plaintext',
  'LICENSE': 'plaintext',
  'pre-push': 'bash',
};
const LANG_BY_EXT = {
  '.sh': 'bash', '.bash': 'bash', '.yml': 'yaml', '.yaml': 'yaml', '.json': 'json',
  '.js': 'javascript', '.mjs': 'javascript', '.cjs': 'javascript', '.ts': 'typescript',
  '.css': 'css', '.html': 'xml', '.py': 'python', '.txt': 'plaintext',
};
const FENCE_LANG_ALIAS = {
  ts: 'typescript', js: 'javascript', sh: 'bash', shell: 'bash', console: 'bash',
  yml: 'yaml', md: 'markdown', text: 'plaintext', txt: 'plaintext', '': 'plaintext',
};

/* ------------------------------------------------------------------- utils -- */

function mmToPt(mm) { return (mm * 72) / 25.4; }

function git(args, cwd) {
  return execFileSync('git', args, { cwd, encoding: 'utf8' }).trim();
}

function escapeHtml(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function slugifyPath(p) {
  return p.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function slugifyHeading(s) {
  return s.trim().toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/^-|-$/g, '') || 'section';
}

function longestLine(text) {
  let max = 0;
  for (const line of text.split('\n')) if (line.length > max) max = line.length;
  return max;
}

/**
 * Line width at the given quantile. Sizing a long listing to its single widest
 * line shrinks the whole file for the sake of one outlier; sizing it to the 97th
 * percentile keeps the body readable and lets the handful of stragglers wrap.
 */
function percentileLine(text, q) {
  const widths = text.split('\n').map((l) => l.length).sort((a, b) => a - b);
  if (!widths.length) return 0;
  return widths[Math.min(widths.length - 1, Math.floor(q * widths.length))];
}

/** Font size that keeps `cols` monospace columns inside `availPt`, clamped. */
function fitMonoSize(cols, availPt, min, max) {
  if (!cols) return max;
  const fit = availPt / (cols * MONO_ADVANCE);
  return Math.round(Math.max(min, Math.min(max, fit)) * 10) / 10;
}

/* --------------------------------------------------------- file discovery -- */

function collectFiles(root, { withCode }) {
  const rules = exclusions({ withCode, root });
  const tracked = git(['ls-files', '-z'], root).split('\0').filter(Boolean);
  const kept = [];
  const dropped = new Map();          // reason -> [paths]
  for (const p of tracked) {
    const rule = rules.find((r) => r.match(p));
    if (rule) {
      if (!dropped.has(rule.why)) dropped.set(rule.why, []);
      dropped.get(rule.why).push(p);
      continue;
    }
    kept.push(p);
  }
  return { kept, dropped };
}

function assignParts(paths) {
  const remaining = new Set(paths);
  const parts = [];

  for (const spec of PARTS) {
    const prefixes = spec.prefixes || (spec.prefix ? [spec.prefix] : []);
    const claimed = [];

    for (const p of spec.order || []) {
      if (remaining.has(p)) { claimed.push(p); remaining.delete(p); }
    }
    if (!spec.catchAll) {
      const rest = [...remaining].filter((p) => prefixes.some((pre) => p.startsWith(pre))).sort();
      for (const p of rest) { claimed.push(p); remaining.delete(p); }
    }
    if (claimed.length) parts.push({ ...spec, files: claimed });
  }

  const leftovers = [...remaining].sort();
  if (leftovers.length) {
    const catchAll = PARTS.find((p) => p.catchAll);
    const existing = parts.find((p) => p.id === catchAll.id);
    if (existing) existing.files.push(...leftovers);
    else parts.push({ ...catchAll, files: leftovers });
  }
  return parts;
}

/* ------------------------------------------------------------ markdown ------ */

let currentSlug = 'doc';   // set before each render; used by the anchor plugin

const md = new MarkdownIt({
  html: false,             // angle-bracket placeholders like <name> are content here
  linkify: false,
  typographer: false,
  breaks: false,
});

md.use(anchorPlugin, {
  slugify: (s) => `${currentSlug}--${slugifyHeading(s)}`,
  tabIndex: false,
});
md.use(taskListPlugin, { enabled: false, label: false });

/**
 * Pull HTML comments out of the source before markdown sees them, so they can be
 * typeset as visible notes instead of vanishing. Fenced code is left untouched:
 * several files show `<!-- okrdev:start -->` as example content.
 */
function extractComments(src) {
  const lines = src.split('\n');
  const out = [];
  const blocks = [];
  const inlines = [];
  let fence = null;
  let i = 0;

  while (i < lines.length) {
    const line = lines[i];
    const fenceMatch = line.match(/^(\s*)(`{3,}|~{3,})(.*)$/);

    if (fence) {
      if (fenceMatch && fenceMatch[2][0] === fence.char && fenceMatch[2].length >= fence.len
          && fenceMatch[3].trim() === '') fence = null;
      out.push(line); i++; continue;
    }
    if (fenceMatch) {
      fence = { char: fenceMatch[2][0], len: fenceMatch[2].length };
      out.push(line); i++; continue;
    }

    const indent = (line.match(/^\s*/) || [''])[0];
    if (line.trim().startsWith('<!--')) {
      let j = i;
      const buf = [];
      let closed = false;
      while (j < lines.length) {
        buf.push(lines[j]);
        if (lines[j].includes('-->')) { closed = true; break; }
        j++;
      }
      if (closed) {
        const raw = buf.join('\n');
        const end = raw.lastIndexOf('-->');
        const body = raw.slice(raw.indexOf('<!--') + 4, end);
        const after = raw.slice(end + 3);
        out.push(indent.slice(0, 3) + `@@SCB${blocks.length}@@`);
        blocks.push(dedent(body));
        if (after.trim()) out.push(after);
        i = j + 1;
        continue;
      }
    }

    if (line.includes('<!--') && line.includes('-->')) {
      out.push(line.replace(/<!--([\s\S]*?)-->/g, (_, body) => {
        inlines.push(body.trim());
        return `@@SCI${inlines.length - 1}@@`;
      }));
      i++; continue;
    }

    out.push(line); i++;
  }
  return { text: out.join('\n'), blocks, inlines, unbalancedFence: Boolean(fence) };
}

function dedent(text) {
  const lines = text.replace(/^\n/, '').replace(/\s+$/, '').split('\n');
  const indents = lines.slice(1).filter((l) => l.trim()).map((l) => l.match(/^\s*/)[0].length);
  const cut = indents.length ? Math.min(...indents) : 0;
  return [lines[0].trim(), ...lines.slice(1).map((l) => l.slice(cut))].join('\n').trim();
}

function commentBlockHtml(text) {
  if (!text.includes('\n') && text.length <= 60) {
    return `<p><span class="sc-inline">${escapeHtml(text)}</span></p>`;
  }
  return `<aside class="srccomment"><div class="sc-label">note in source</div>`
    + `<pre>${escapeHtml(text)}</pre></aside>`;
}

/* -------------------------------------------------------------- code render -- */

function highlightTo(code, lang) {
  const resolved = FENCE_LANG_ALIAS[lang] ?? lang;
  if (resolved && resolved !== 'plaintext' && hljs.getLanguage(resolved)) {
    try {
      return { html: hljs.highlight(code, { language: resolved, ignoreIllegals: true }).value,
               lang: resolved };
    } catch { /* fall through to plain */ }
  }
  return { html: escapeHtml(code), lang: resolved || 'plaintext' };
}

/** Split highlighted HTML on newlines, reopening any spans that straddle a break. */
function splitHighlightedLines(html) {
  const lines = [];
  const stack = [];
  let cur = '';

  const pushText = (text) => {
    const parts = text.split('\n');
    for (let i = 0; i < parts.length; i++) {
      if (i > 0) {
        cur += '</span>'.repeat(stack.length);
        lines.push(cur);
        cur = stack.join('');
      }
      cur += parts[i];
    }
  };

  const tagRe = /(<\/?[a-zA-Z][^>]*>)/g;
  let last = 0;
  let m;
  while ((m = tagRe.exec(html)) !== null) {
    pushText(html.slice(last, m.index));
    if (m[1].startsWith('</')) { stack.pop(); cur += m[1]; }
    else { stack.push(m[1]); cur += m[1]; }
    last = tagRe.lastIndex;
  }
  pushText(html.slice(last));
  lines.push(cur);
  return lines;
}

/** Wrap each highlighted line in its own element so wrapped lines hang. */
function codeLinesHtml(highlighted) {
  return splitHighlightedLines(highlighted)
    .map((line) => `<div class="cl">${line || '&nbsp;'}</div>`)
    .join('');
}

function codeBlockHtml(code, lang) {
  const body = code.replace(/\n+$/, '');
  const { html, lang: resolved } = highlightTo(body, lang);
  // Fenced blocks carry ASCII diagrams and aligned command lines, so they are
  // sized to their longest line: a wrap here destroys the picture.
  const size = fitMonoSize(longestLine(body), CONTENT_PT - mmToPt(7), 6.6, 8.6);
  const lineCount = body.split('\n').length;
  const tag = resolved && resolved !== 'plaintext'
    ? `<span class="code-lang">${escapeHtml(resolved)}</span>` : '';
  return `<div class="codeblock${lineCount <= 20 ? ' short' : ''}" style="font-size:${size}pt">`
    + `${tag}${codeLinesHtml(html)}</div>`;
}

md.renderer.rules.fence = (tokens, idx) => {
  const token = tokens[idx];
  const info = (token.info || '').trim().split(/\s+/)[0].toLowerCase();
  return codeBlockHtml(token.content, info);
};
md.renderer.rules.code_block = (tokens, idx) => codeBlockHtml(tokens[idx].content, '');

md.renderer.rules.table_open = () => '<div class="tablewrap"><table>';
md.renderer.rules.table_close = () => '</table></div>';

/* ------------------------------------------------------------ link rewriting -- */

let linkContext = { doc: null, index: null };

md.renderer.rules.link_open = function (tokens, idx, options, env, self) {
  const token = tokens[idx];
  const href = token.attrGet('href') || '';
  env.deadLinks = env.deadLinks || [];

  if (/^(https?:|mailto:|tel:)/i.test(href)) return self.renderToken(tokens, idx, options);

  if (href.startsWith('#')) {
    token.attrSet('href', `#${currentSlug}--${slugifyHeading(href.slice(1))}`);
    return self.renderToken(tokens, idx, options);
  }

  const [rawPath, fragment] = href.split('#');
  const resolved = path.posix.normalize(
    path.posix.join(path.posix.dirname(linkContext.doc.path), rawPath || '.'),
  ).replace(/^\.\//, '');
  // A link to a directory (`skills/`, `docs/`) lands on its first file.
  const target = linkContext.index.get(resolved)
    ?? linkContext.index.get(`${resolved}/README.md`)
    ?? firstUnder(linkContext.index, resolved);

  if (target) {
    token.attrSet('href', fragment
      ? `#${target.slug}--${slugifyHeading(fragment)}`
      : `#${target.slug}`);
    return self.renderToken(tokens, idx, options);
  }

  // Points somewhere outside this export (examples/, or a path that moved).
  env.deadLinks.push(idx);
  return '<span class="extref">';
};

md.renderer.rules.link_close = function (tokens, idx, options, env, self) {
  const openIdx = (env.deadLinks || []).length
    ? env.deadLinks[env.deadLinks.length - 1] : -1;
  if (openIdx >= 0 && !hasCloserBefore(tokens, openIdx, idx)) {
    env.deadLinks.pop();
    return '</span>';
  }
  return self.renderToken(tokens, idx, options);
};

function firstUnder(index, dir) {
  const prefix = `${dir.replace(/\/$/, '')}/`;
  for (const [p, doc] of index) if (p.startsWith(prefix)) return doc;
  return null;
}

function hasCloserBefore(tokens, openIdx, closeIdx) {
  let depth = 0;
  for (let i = openIdx + 1; i < closeIdx; i++) {
    if (tokens[i].type === 'link_open') depth++;
    if (tokens[i].type === 'link_close') { if (depth === 0) return true; depth--; }
  }
  return false;
}

/* -------------------------------------------------------------- doc loading -- */

const FRONT_MATTER = /^---\r?\n([\s\S]*?)\r?\n---\r?\n?/;

function loadMarkdown(doc, index) {
  const raw = fs.readFileSync(doc.abs, 'utf8');
  const fmMatch = raw.match(FRONT_MATTER);
  const frontMatter = fmMatch ? fmMatch[1] : null;
  const source = fmMatch ? raw.slice(fmMatch[0].length) : raw;

  const { text, blocks, inlines, unbalancedFence } = extractComments(source);
  if (unbalancedFence) console.warn(`  ! ${doc.path}: unbalanced code fence`);

  currentSlug = doc.slug;
  linkContext = { doc, index };
  const env = {};
  const tokens = md.parse(text, env);

  // A file whose single h1 opens the document has that h1 promoted to the title.
  const h1s = tokens.filter((t) => t.type === 'heading_open' && t.tag === 'h1');
  let shift = 2;
  if (h1s.length === 1 && tokens[0] && tokens[0].type === 'heading_open' && tokens[0].tag === 'h1') {
    doc.title = tokens[1].content.replace(/`/g, '');
    tokens.splice(0, 3);
    shift = 1;
  }

  // Push every remaining heading below the part (h1) and file (h2) levels, so
  // Chromium's generated PDF outline nests correctly.
  for (const token of tokens) {
    if (token.type === 'heading_open' || token.type === 'heading_close') {
      const level = Number(token.tag.slice(1));
      token.tag = `h${Math.min(6, level + shift)}`;
    }
  }

  let html = md.renderer.render(tokens, md.options, env);

  html = html
    .replace(/<p>@@SCB(\d+)@@<\/p>/g, (_, n) => commentBlockHtml(blocks[Number(n)]))
    .replace(/@@SCB(\d+)@@/g, (_, n) => commentBlockHtml(blocks[Number(n)]))
    .replace(/@@SCI(\d+)@@/g, (_, n) => `<span class="sc-inline">${escapeHtml(inlines[Number(n)])}</span>`)
    .replace(/<input([^>]*)class="task-list-item-checkbox"([^>]*)>/g,
      (m) => `<span class="cb${/checked/.test(m) ? ' on' : ''}"></span>`);

  if (frontMatter) {
    const size = fitMonoSize(percentileLine(frontMatter, 0.9), CONTENT_PT - mmToPt(7), 7, 8);
    html = `<div class="frontmatter" style="font-size:${size}pt">`
      + `<div class="fm-label">front matter</div>`
      + codeLinesHtml(highlightTo(frontMatter, 'yaml').html) + '</div>'
      + html;
  }

  doc.html = `<div class="md">${html}</div>`;
  doc.summary = firstSentence(source);
}

function loadListing(doc) {
  const raw = fs.readFileSync(doc.abs, 'utf8').replace(/\n$/, '');
  const base = path.basename(doc.path);
  const lang = LANG_BY_NAME[base] ?? LANG_BY_EXT[path.extname(doc.path)] ?? 'plaintext';
  const { html } = highlightTo(raw, lang);
  const lines = splitHighlightedLines(html);
  const size = fitMonoSize(percentileLine(raw, 0.97), CONTENT_PT - mmToPt(16), 7, 8.4);

  const rows = lines
    .map((line, i) => `<div class="row"><span class="n">${i + 1}</span><span class="c">${line || '&nbsp;'}</span></div>`)
    .join('');

  doc.language = lang;
  doc.html = `<div class="listing" style="font-size:${size}pt">${rows}</div>`;
  doc.summary = firstCommentSummary(raw);
}

function firstSentence(markdown) {
  const cleaned = markdown
    .replace(/```[\s\S]*?```/g, '')
    .replace(/<!--[\s\S]*?-->/g, '')
    .replace(/^#{1,6}\s.*$/gm, '')
    .replace(/^\s*[-*|>]\s?.*$/gm, '');
  for (const block of cleaned.split(/\n\s*\n/)) {
    const t = block.trim().replace(/\s+/g, ' ');
    if (t.length < 25) continue;
    const plain = t.replace(/\*\*(.+?)\*\*/g, '$1').replace(/[*_`]/g, '')
      .replace(/\[([^\]]+)\]\([^)]*\)/g, '$1');
    const sentence = plain.split(/(?<=[.!?])\s/)[0];
    return sentence.length > 150 ? `${sentence.slice(0, 147)}…` : sentence;
  }
  return '';
}

function firstCommentSummary(source) {
  for (const line of source.split('\n').slice(0, 12)) {
    const m = line.match(/^\s*(?:#|\/\/|\/\*\*?)\s*(.+?)\s*$/);
    if (!m) continue;
    const t = m[1].replace(/^[-!]+\s*/, '').trim();
    if (t.length > 20 && !/^!/.test(line.trim())) {
      return t.length > 150 ? `${t.slice(0, 147)}…` : t;
    }
  }
  return '';
}

/* ------------------------------------------------------------ page assembly -- */

function fontFaceCss() {
  const faces = [
    ['Inter', 400, 'normal', '@fontsource/inter/files/inter-latin-400-normal.woff2'],
    ['Inter', 500, 'normal', '@fontsource/inter/files/inter-latin-500-normal.woff2'],
    ['Inter', 600, 'normal', '@fontsource/inter/files/inter-latin-600-normal.woff2'],
    ['Inter', 700, 'normal', '@fontsource/inter/files/inter-latin-700-normal.woff2'],
    ['Source Serif 4', 400, 'normal', '@fontsource/source-serif-4/files/source-serif-4-latin-400-normal.woff2'],
    ['Source Serif 4', 400, 'italic', '@fontsource/source-serif-4/files/source-serif-4-latin-400-italic.woff2'],
    ['Source Serif 4', 600, 'normal', '@fontsource/source-serif-4/files/source-serif-4-latin-600-normal.woff2'],
    ['Source Serif 4', 600, 'italic', '@fontsource/source-serif-4/files/source-serif-4-latin-600-italic.woff2'],
    ['Source Serif 4', 700, 'normal', '@fontsource/source-serif-4/files/source-serif-4-latin-700-normal.woff2'],
  ];
  const out = [];
  for (const [family, weight, style, spec] of faces) {
    let file;
    try { file = require.resolve(spec); } catch { continue; }
    const b64 = fs.readFileSync(file).toString('base64');
    out.push(`@font-face{font-family:"${family}";font-style:${style};font-weight:${weight};`
      + `font-display:block;src:url(data:font/woff2;base64,${b64}) format("woff2");}`);
  }
  return out.join('\n');
}

function coverHtml(meta) {
  return `<section class="cover">
  <div class="cover-top">
    <div class="cover-mark">${escapeHtml(meta.remote)}</div>
    <div class="cover-rule"></div>
    <div class="cover-title">okrdev</div>
    <p class="cover-sub">${escapeHtml(meta.tagline)}</p>
    <p class="cover-scope">${meta.fileCount} files across ${meta.partCount} parts,
      ${meta.lineCount.toLocaleString('en-US')} lines, typeset for reading.
      What is left out — and why — is listed overleaf.</p>
  </div>
  <dl class="cover-meta">
    <div><dt>Repository</dt><dd>${escapeHtml(meta.remote)}</dd></div>
    <div><dt>Branch</dt><dd>${escapeHtml(meta.branch)}</dd></div>
    <div><dt>Commit</dt><dd>${escapeHtml(meta.commit)} &middot; ${escapeHtml(meta.commitDate)}</dd></div>
    <div><dt>Generated</dt><dd>${escapeHtml(meta.generated)}</dd></div>
  </dl>
</section>`;
}

function aboutHtml(meta, dropped) {
  const excluded = [...dropped.entries()].map(([why, paths]) => {
    const shown = paths.length > 6
      ? `${paths.slice(0, 4).map((p) => `<code>${escapeHtml(p)}</code>`).join(', ')} and ${paths.length - 4} more`
      : paths.map((p) => `<code>${escapeHtml(p)}</code>`).join(', ');
    return `<li>${escapeHtml(why)}<br><span class="extref">${shown}</span></li>`;
  }).join('');

  return `<section class="front">
  <h1>About this document</h1>
  <p class="lede">Tracked files in reading order, rendered rather than dumped. Markdown becomes
    typeset prose; anything else becomes a numbered listing. What is not here comes first,
    so nothing goes missing quietly.</p>

  <h2>What is not here</h2>
  <ul>${excluded}</ul>

  <h2>How to read it</h2>
  <dl class="legend">
    <dt>File openers</dt>
    <dd>Every file starts on a new page under its repository path. The running head at the top of
      each page repeats that path, so you always know which file you are inside.</dd>
    <dt>Front matter</dt>
    <dd>YAML front matter is shown verbatim in a bordered panel — including its inline comments,
      which a parsed table would have thrown away.</dd>
    <dt>Notes in source</dt>
    <dd>HTML comments are invisible on GitHub but often carry the real instructions. They are
      lifted out and set in grey as <span class="sc-inline">notes</span>. Comments shown inside
      fenced code blocks are left alone — there they are example content, not asides.</dd>
    <dt>Links</dt>
    <dd>Cross-references between files are live: tapping <code>docs/method.md</code> in the text
      jumps to that file. References to files outside this export are set in
      <span class="extref">plain monospace</span> instead of being linked into a dead end.</dd>
    <dt>Code</dt>
    <dd>Code blocks are syntax highlighted and auto-sized so ASCII diagrams and wide command
      lines stay on one line wherever they fit. Listings of non-markdown files carry line
      numbers matching the file on disk.</dd>
    <dt>Navigation</dt>
    <dd>The contents pages carry page numbers, and the PDF outline mirrors the heading structure
      of every file — parts, then files, then each file's own headings.</dd>
  </dl>

  <h2>Regenerating</h2>
  <p>This document is built from the repository itself:</p>
  ${codeBlockHtml('npm --prefix tools/repo-pdf install\nnode tools/repo-pdf/build.mjs', 'bash')}
  <p>Add <code>--with-code</code> to take in the source and config files listed above. The
    generator lives in <code>tools/repo-pdf/</code>${meta.toolingPart
    ? ` and is itself included in Part ${meta.toolingPart} of this document`: ''}.</p>
</section>`;
}

function tocHtml(parts) {
  const rows = parts.map((part, i) => {
    const files = part.files.map((doc) => `<div class="toc-row">
      <a href="#${doc.slug}"><span class="p">${escapeHtml(doc.path)}</span></a>
      <span class="d">${escapeHtml(doc.title === doc.path ? '' : doc.title)}</span>
      <span class="fill"></span>
      <span class="pg">@@PG:${doc.slug}@@</span>
    </div>`).join('');
    return `<div class="toc-part">
        <span class="n">Part ${i + 1}</span>
        <span class="t">${escapeHtml(part.title)}</span>
        <span class="fill"></span>
        <span class="pg">@@PG:part-${part.id}@@</span>
      </div>${files}`;
  }).join('');

  return `<section class="toc front">
  <h1>Contents</h1>
  ${rows}
</section>`;
}

function partHtml(part, number) {
  const files = part.files
    .map((doc) => `<div>${escapeHtml(doc.path)}</div>`).join('');
  // The locator token sits outside every heading: Chromium builds the PDF
  // outline from heading text, and a marker inside would show up in it.
  return `<section class="part" id="part-${part.id}">
  <div class="part-eyebrow">Part ${number}<span class="pgmark">${part.marker}</span></div>
  <h1>${escapeHtml(part.title)}</h1>
  <p class="part-blurb">${escapeHtml(part.blurb)}</p>
  <div class="part-files">${files}</div>
</section>`;
}

function fileHtml(doc, part, runningHeads) {
  // With running heads on, the part name is already at the top of every page.
  const kicker = runningHeads ? (doc.kind === 'markdown' ? 'markdown' : doc.language) : part.title;
  const badge = `${doc.lines} lines`;

  const banner = `<header class="file-banner">
    <div class="file-kicker"><span>${escapeHtml(kicker)}</span><span class="badge">${badge}</span>
      <span class="pgmark">${doc.marker}</span></div>
    <h2 class="file-path">${escapeHtml(doc.path)}</h2>
    ${doc.title && doc.title !== doc.path ? `<p class="file-title">${escapeHtml(doc.title)}</p>` : ''}
    <div class="file-rule"></div>
  </header>`;

  const head = `<div class="runhead">
      <span class="rh-part">${escapeHtml(part.title)}</span>
      <span class="rh-path">${escapeHtml(doc.path)}</span>
    </div>`;

  const body = banner + doc.html;

  if (!runningHeads) {
    return `<section class="file" id="${doc.slug}">${body}</section>`;
  }
  return `<section class="file" id="${doc.slug}"><table class="filewrap">`
    + `<thead><tr><th>${head}</th></tr></thead>`
    + `<tbody><tr><td>${body}</td></tr></tbody></table></section>`;
}

function buildHtml({ parts, meta, dropped, runningHeads }) {
  const css = fs.readFileSync(path.join(HERE, 'print.css'), 'utf8');
  const body = parts.map((part, i) =>
    partHtml(part, i + 1) + part.files.map((doc) => fileHtml(doc, part, runningHeads)).join('')).join('');

  return `<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>okrdev — repository export</title>
<style>${fontFaceCss()}</style>
<style>${css}</style>
</head><body>
${coverHtml(meta)}
${aboutHtml(meta, dropped)}
${tocHtml(parts)}
${body}
</body></html>`;
}

/* ------------------------------------------------------------------ render -- */

const FOOTER = `<div style="width:100%;font-family:'DejaVu Sans',sans-serif;font-size:7.5px;
  color:#949ca7;padding:0 22mm;display:flex;justify-content:space-between;align-items:center;">
  <span>okrdev &middot; repository export</span>
  <span><span class="pageNumber"></span> / <span class="totalPages"></span></span>
</div>`;

async function renderPdf(html, outPath) {
  const { chromium } = await loadPlaywright();
  const browser = await launchChromium(chromium);
  try {
    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: 'load' });
    await page.evaluate(() => document.fonts.ready);
    return await page.pdf({
      path: outPath,
      format: 'A4',
      printBackground: true,
      displayHeaderFooter: true,
      headerTemplate: '<div></div>',
      footerTemplate: FOOTER,
      margin: {
        top: `${PAGE.marginMm.top}mm`, bottom: `${PAGE.marginMm.bottom}mm`,
        left: `${PAGE.marginMm.left}mm`, right: `${PAGE.marginMm.right}mm`,
      },
      outline: true,
      tagged: true,
    });
  } finally {
    await browser.close();
  }
}

async function loadPlaywright() {
  try { return await import('playwright'); } catch { /* fall back to a global install */ }
  return import('/opt/node22/lib/node_modules/playwright/index.mjs');
}

/**
 * Launch Chromium. Sandboxes that pre-install browsers (CI images, Claude Code
 * on the web) often carry a build Playwright does not recognise, so fall back to
 * whatever binary is actually on disk rather than asking for a download.
 */
async function launchChromium(chromium) {
  const args = ['--font-render-hinting=none'];
  try {
    return await chromium.launch({ args });
  } catch (err) {
    const binary = findChromiumBinary();
    if (!binary) throw err;
    console.log(`  using pre-installed Chromium at ${binary}`);
    return chromium.launch({ args, executablePath: binary });
  }
}

function findChromiumBinary() {
  if (process.env.CHROMIUM_PATH && fs.existsSync(process.env.CHROMIUM_PATH)) {
    return process.env.CHROMIUM_PATH;
  }
  const roots = [process.env.PLAYWRIGHT_BROWSERS_PATH, '/opt/pw-browsers'].filter(Boolean);
  for (const root of roots) {
    if (!fs.existsSync(root)) continue;
    const candidates = [path.join(root, 'chromium')];
    for (const entry of fs.readdirSync(root)) {
      if (!entry.startsWith('chromium')) continue;
      candidates.push(
        path.join(root, entry, 'chrome-linux', 'chrome'),
        path.join(root, entry, 'chrome-linux', 'headless_shell'),
      );
    }
    const hit = candidates.find((c) => { try { return fs.statSync(c).isFile(); } catch { return false; } });
    if (hit) return hit;
  }
  return null;
}

/** Map each marker token to the first PDF page it appears on. */
async function markerPages(pdfBuffer) {
  const pdfjs = await import('pdfjs-dist/legacy/build/pdf.mjs');
  const doc = await pdfjs.getDocument({
    data: new Uint8Array(pdfBuffer),
    disableFontFace: true,
    isEvalSupported: false,
  }).promise;

  const found = new Map();
  for (let n = 1; n <= doc.numPages; n++) {
    const page = await doc.getPage(n);
    const content = await page.getTextContent();
    const text = content.items.map((it) => it.str || '').join('').replace(/\s+/g, '');
    for (const m of text.matchAll(/PGMK[0-9A-Z]+Z/g)) {
      if (!found.has(m[0])) found.set(m[0], n);
    }
  }
  const pages = doc.numPages;
  await doc.destroy();
  return { found, pages };
}

function applyPageNumbers(html, markers, pageByMarker) {
  return html.replace(/@@PG:([a-z0-9-]+)@@/g, (_, slug) => {
    const marker = markers.get(slug);
    const page = marker ? pageByMarker.get(marker) : null;
    return page ? String(page) : '&middot;';
  });
}

/* -------------------------------------------------------------------- main -- */

async function main() {
  const argv = process.argv.slice(2);
  const outArg = argv.indexOf('--out');
  const runningHeads = !argv.includes('--no-running-heads');
  const withCode = argv.includes('--with-code');
  const root = git(['rev-parse', '--show-toplevel'], process.cwd());
  const outPath = path.resolve(root, outArg >= 0 ? argv[outArg + 1] : 'dist/okrdev-repo.pdf');

  const { kept, dropped } = collectFiles(root, { withCode });
  const parts = assignParts(kept);

  // Build the document model first: every file needs a slug and a marker before
  // links between them can be resolved.
  const index = new Map();
  const markers = new Map();
  let counter = 0;
  let lineCount = 0;

  for (const part of parts) {
    part.marker = `PGMK${String(counter++).padStart(4, '0')}Z`;
    markers.set(`part-${part.id}`, part.marker);
    part.files = part.files.map((p) => {
      const abs = path.join(root, p);
      const raw = fs.readFileSync(abs, 'utf8');
      const doc = {
        path: p,
        abs,
        slug: `f-${slugifyPath(p)}`,
        marker: `PGMK${String(counter++).padStart(4, '0')}Z`,
        kind: p.endsWith('.md') ? 'markdown' : 'listing',
        title: p,
        lines: raw.replace(/\n$/, '').split('\n').length,
      };
      lineCount += doc.lines;
      index.set(p, doc);
      markers.set(doc.slug, doc.marker);
      return doc;
    });
  }

  const corpus = [...index.values()].map((d) => fs.readFileSync(d.abs, 'utf8')).join('\n');
  if (/PGMK\d+Z/.test(corpus)) throw new Error('marker token collides with repository content');

  console.log(`Rendering ${index.size} files in ${parts.length} parts…`);
  for (const part of parts) {
    for (const doc of part.files) {
      if (doc.kind === 'markdown') loadMarkdown(doc, index);
      else loadListing(doc);
    }
  }

  const remote = safeRemote(root);
  const meta = {
    remote,
    branch: git(['rev-parse', '--abbrev-ref', 'HEAD'], root),
    commit: git(['rev-parse', '--short', 'HEAD'], root),
    commitDate: git(['log', '-1', '--format=%cs'], root),
    generated: new Date().toISOString().slice(0, 10),
    tagline: readTagline(root),
    fileCount: index.size,
    partCount: parts.length,
    lineCount,
    toolingPart: parts.findIndex((p) => p.id === 'tooling') + 1,   // 0 when absent
  };

  const template = buildHtml({ parts, meta, dropped, runningHeads });
  fs.mkdirSync(path.dirname(outPath), { recursive: true });

  const htmlArg = argv.indexOf('--html');
  if (htmlArg >= 0) {
    const htmlPath = path.resolve(root, argv[htmlArg + 1]);
    fs.writeFileSync(htmlPath, applyPageNumbers(template, markers, new Map()));
    console.log(`  wrote ${path.relative(root, htmlPath)}`);
  }

  let pageByMarker = new Map();
  let pages = 0;
  for (let pass = 1; pass <= 3; pass++) {
    const html = applyPageNumbers(template, markers, pageByMarker);
    const buf = await renderPdf(html, outPath);
    const result = await markerPages(buf);
    pages = result.pages;

    const stable = pass > 1 && [...result.found].every(([k, v]) => pageByMarker.get(k) === v);
    pageByMarker = result.found;
    console.log(`  pass ${pass}: ${pages} pages, ${result.found.size}/${markers.size} markers located`);
    if (stable) break;
    if (pass === 3) console.warn('  ! contents page numbers did not settle after 3 passes');
  }

  const missing = [...markers.entries()].filter(([, m]) => !pageByMarker.has(m));
  if (missing.length) console.warn(`  ! no page found for ${missing.length} contents entries`);

  const kb = Math.round(fs.statSync(outPath).size / 1024);
  console.log(`\n${path.relative(root, outPath)} — ${pages} pages, ${kb} KB`);
}

function safeRemote(root) {
  try {
    const url = git(['config', '--get', 'remote.origin.url'], root);
    const m = url.match(/[:/]([^/:]+\/[^/]+?)(?:\.git)?$/);
    return m ? m[1] : url;
  } catch { return 'okrdev'; }
}

function readTagline(root) {
  const readme = path.join(root, 'README.md');
  if (!fs.existsSync(readme)) return 'An OKR-obsessed operating framework.';
  const m = fs.readFileSync(readme, 'utf8').match(/^\*\*(.+?)\*\*\s*$/m);
  return m ? m[1] : 'An OKR-obsessed operating framework.';
}

main().catch((err) => { console.error(err); process.exit(1); });
