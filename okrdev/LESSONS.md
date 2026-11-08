# Lessons

Append-only. `/okrdev:retro` adds one block per cycle. Planning reads this file
before drafting the next cycle's OKRs — never rewrite or delete old blocks.

<!-- Block format — the retro skill fills this in at the end of each cycle.
     One list of scores: every KR is a stretch, so there is nothing to separate.

## 2026-Q3 — scored 2026-10-01
Committed: KR2.1 1.0, KR2.2 0.8 — one miss, root cause in cycle file.
Aspirational: KR1.1 0.7, KR1.2 0.4 — avg 0.55. (KR1.3 dropped W33.)
Check-in adherence: 11/13 weeks.
Revisions: KR1.1 target raised in W31 (early sandbag flag) — right call.
Lessons:
1. <what you learned about the business or the numbers>
2. <what you learned about how you work>
3. <what you'll do differently next cycle>
-->

## 2026-Q3 — scored 2026-11-08 (66 days after its 09-03 end; solo, DRI and coach)
Scores: KR1.1 0.5, KR1.2 1.0, KR1.3 1.0, KR2.1 1.0, KR2.2 0.7 — avg 0.84.
Confidence collapse: KR1.1 rode 0.9 out of W35 and scored 0.5 — W36 was never held. Root cause
in the cycle file.
Calibration: 0.84 sits above the healthy 0.6–0.7 band, and three 1.0s say the targets were soft.
KR1.2's bar was crossed at mid-cycle on an install already under way in week one. KR1.3's count
is mostly unverifiable from this repo. KR2.1's 1.0 is a merged fix that nobody re-timed. Read the
average as an upper bound.
Check-in adherence: 4/6 weeks (W33 and W36 dark), and the retro came eight weeks late.
Revisions: seven amendment blocks in a six-week cycle. Type removal (08-23): agreed, it moved no
bar. Cycle shortened with KR1.1 re-cut (08-23): visible and honest, but it lifted KR1.1 from 0.3
to 0.5 under the old anchors. Health row added 08-20 and retired 08-21 into a stricter external
model: the right call at the time, but that model was not maintained after the cycle ended either.
Side quests: box-hours overran the 4h/week budget in W32 (~7.5h) and W34–35 (8h box). No
emergencies.
Lessons:
1. The cycle ends when the calendar says, not when someone remembers. W36 and the retro were both
   "next week" items with no date, and the cycle sat unscored for two months with no successor.
   Planning books the last check-in, the retro and the next planning session as calendar events
   on the day the cycle activates. A solo DRI running cycles in two repos lost both cadences in
   the same weeks, so next planning sets one check-in slot that covers every live cycle.
2. Don't rewrite the method inside the cycle that measures it. Seven amendments in six weeks —
   the KR types removed, the cycle shortened, a KR re-cut, a health row added and retired — meant
   the cycle was scoring a moving target, and the one re-cut bought 0.2. From now on, doctrine
   changes ship between cycles. Mid-cycle amendments are for errors in the plan only.
3. We can't score adoption we don't instrument. okrdev has two install timings and no way to see
   who installs from a directory. KR1.3 was counted from history this repo can't show, and
   KR2.1/KR2.2 closed without a re-timed run. Next cycle's first KR gives installers a way to make
   themselves known and re-times a clean-repo install. Only then does an adoption target get set.
