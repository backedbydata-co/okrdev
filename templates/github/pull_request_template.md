KR:

<!-- Fill in the line above. One of:
       1.2          — the key result this PR serves (an id from the active file in okrdev/okrs/)
       side-quest   — sanctioned and time-boxed; logged in okrdev/PARKING_LOT.md
       maintenance  — bugfix, config, docs, small refactor
       emergency    — ship now; gets a two-line post-hoc review at the next check-in
     The okr-gate reads the first line that starts with "KR:". An empty line warns —
     it never blocks unless your repo opted into strict mode. -->

## What changed

<!-- Plain language. A teammate who doesn't read code should understand this. -->

## How to verify

<!-- Preview URL plus the exact clicks to try. For example:
     Preview: <url>
     1. Log in as the test user
     2. Open Settings → Billing
     3. You should see <expected result>
     These steps are the spec (docs/evidence.md — the domain language, made
     falsifiable). If this path ever breaks or burns a DRI, these exact steps
     are what gets promoted into a smoke test — so write them checkable, not
     "make sure it works". -->

## Risk checklist

<!-- Check every box that applies, then request review from the matching domain
     reviewer in .github/CODEOWNERS. Paths catch most of these automatically;
     behavior-shaped risks (like deleting data) are only caught if you check the box. -->

- [ ] Touches database migrations
- [ ] Touches auth or permissions configuration
- [ ] Touches payment code
- [ ] Deletes or bulk-modifies data
