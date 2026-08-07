// The okr-gate's KR grammar, tested against the real workflow file.
//
// The gate states the grammar twice: KR_LINE finds the line in a PR body, and
// a second regex re-parses the captured id into cycle + number. Those two are
// coupled by an unguarded dereference — `idMatch[2]` runs with no null check —
// so if KR_LINE ever accepts an id shape the parser does not, the gate throws
// a TypeError instead of warning, and every PR in the repo reports a failed
// action. That coupling is what this file pins.
//
// Both patterns are read out of templates/github/workflows/okr-gate.yml rather
// than copied here. A test carrying its own copy of the thing under test is a
// fourth place for the grammar to drift.

const { test } = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');

const YML = path.join(__dirname, '..', 'templates', 'github', 'workflows', 'okr-gate.yml');
const source = fs.readFileSync(YML, 'utf8');

function literal(pattern, what) {
  const m = source.match(pattern);
  if (!m) throw new Error(`could not find the ${what} in ${YML} — did the gate get refactored?`);
  return new RegExp(m[1], m[2]);
}

// `const KR_LINE = /…/im;`
const KR_LINE = literal(/const KR_LINE = \/(.+)\/([a-z]*);/, 'KR_LINE regex');
// `raw.match(/…/i)` — the id re-parse in step 4.
const ID = literal(/raw\.match\(\/(.+)\/([a-z]*)\)/, 'id re-parse regex');

const CLASSIFICATIONS = ['side-quest', 'maintenance', 'emergency'];

// What the gate should accept, and what each line's captured id is.
const ACCEPTED = [
  ['KR: 1.2', '1.2'],
  ['KR: KR1.2', 'KR1.2'],
  ['KR: 2026-Q3/KR1.2', '2026-Q3/KR1.2'],
  ['KR: 2026-C4/KR1.2', '2026-C4/KR1.2'],
  ['KR: 2026-Q3/1.2', '2026-Q3/1.2'],
  ['kr: 1.2', '1.2'],                        // case-insensitive
  ['KR:1.2', '1.2'],                         // no space
  ['KR:   1.2   ', '1.2'],                   // padded
  ['KR: 1.23', '1.23'],                      // two-digit KR number
  ['KR: 12.3', '12.3'],                      // two-digit objective
  ['KR: side-quest', 'side-quest'],
  ['KR: maintenance', 'maintenance'],
  ['KR: emergency', 'emergency'],
  ['KR: EMERGENCY', 'EMERGENCY'],
];

const REJECTED = [
  'KR: 1',                 // not a KR id — no minor number
  'KR:1.2 and more',       // trailing prose
  'KR: 1.2.3',             // three parts
  'KR: side quest',        // space, not hyphen
  'KR:',                   // empty
  'KR: 2026-X3/KR1.2',     // Q or C only
  'Serves KR: 1.2',        // must start the line
];

test('accepts every documented KR: form', () => {
  for (const [body, expected] of ACCEPTED) {
    const m = KR_LINE.exec(body);
    assert.ok(m, `should have matched: ${JSON.stringify(body)}`);
    assert.strictEqual(m[1], expected, `captured id for ${JSON.stringify(body)}`);
  }
});

test('rejects malformed KR: lines', () => {
  for (const body of REJECTED) {
    assert.strictEqual(KR_LINE.exec(body), null, `should NOT have matched: ${JSON.stringify(body)}`);
  }
});

test('the first matching line in a multi-line body wins', () => {
  const body = ['## What changed', '', 'KR: 1.2', 'some prose', 'KR: maintenance'].join('\n');
  assert.strictEqual(KR_LINE.exec(body)[1], '1.2');
});

test('finds the line with CRLF endings', () => {
  assert.strictEqual(KR_LINE.exec('## Title\r\nKR: 1.2\r\nmore')[1], '1.2');
});

// The coupling. This is the reason this file exists.
test('every id KR_LINE accepts, the id re-parse also parses', () => {
  for (const [body] of ACCEPTED) {
    const raw = KR_LINE.exec(body)[1];
    if (CLASSIFICATIONS.includes(raw.toLowerCase())) continue; // step 3 returns before step 4
    const idMatch = raw.match(ID);
    assert.ok(
      idMatch,
      `KR_LINE accepts ${JSON.stringify(raw)} but the id re-parse returns null — ` +
      'okr-gate.yml dereferences idMatch[2] unguarded, so this throws at runtime',
    );
    assert.ok(idMatch[3], `no KR number captured from ${JSON.stringify(raw)}`);
  }
});

test('KR1.2 is not confused with KR1.23', () => {
  assert.strictEqual('KR1.2'.match(ID)[3], '1.2');
  assert.strictEqual('KR1.23'.match(ID)[3], '1.23');
});

test('the cross-cycle form yields both the cycle and the short id', () => {
  const m = '2026-Q3/KR1.2'.match(ID);
  assert.strictEqual(m[2], '2026-Q3');
  assert.strictEqual('KR' + m[3], 'KR1.2');
});
