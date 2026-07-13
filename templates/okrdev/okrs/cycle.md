---
cycle: 2026-Q3                # quarterly: 2026-Q3 | six-week: 2026-C4
start: 2026-07-01
end: 2026-09-30
status: draft                 # draft | active | scored | abandoned — KR ids freeze at active
---

<!-- 1–3 objectives per cycle, each with 2–4 KRs. Focus is the whole point.
     Rules the coach enforces:
     - Ids never change once status is active. A dropped KR keeps its number and gets
       "Status: dropped" under its heading. Renumbering is forbidden.
     - Mid-cycle changes go through a PR that adds a "Revised: <date> — <reason>" block
       preserving the original text. The coach never silently edits an active KR.
     - Every KR is an outcome, not an output. "Launch X" is only valid when paired with
       a usage/outcome KR. "baseline: unknown" is allowed if paired with an
       instrumentation task — "instrument X and establish baseline" is a valid
       first-cycle KR on its own. -->

# O1: <qualitative, inspiring, time-bound objective>
DRI: <name>                   <!-- exactly one human per objective and per KR -->

## KR1.1: <metric> from <baseline> to <target>
Type: aspirational            # committed | aspirational — committed means expected score 1.0; a miss requires a root-cause note
DRI: <name>
Confidence: 0.5               # a good stretch KR is a coin flip at kickoff
Score: —                      # set at retro
Notes: —                      # a volume/speed KR names its quality pair here or in the health table

## KR1.2: <...>
Type: committed
DRI: <name>
Confidence: 0.5
Score: —
Notes: —

# O2: <...>
DRI: <name>

## KR2.1: <...>
Type: aspirational
DRI: <name>
Confidence: 0.5
Score: —
Notes: —

## Health metrics (monitored, not targeted)

<!-- 2–4 per cycle, each with a red line. The coach checks these at every check-in;
     a breach can pause the KR pushing on it. -->

| Metric | Red line | Source |
|--------|----------|--------|
| <metric> | <threshold> | <where to read it> |
