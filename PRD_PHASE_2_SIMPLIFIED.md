# Product Requirements Document (PRD) – Falah Phase 2 (Simplified Build)

## Context
This version of Phase 2 is designed for a **single-user testing environment** (developer only). 

Assumptions:
- No real users → no migration constraints
- Data can be reset anytime
- Users can edit logs for previous 2 days
- No background workers (Celery) initially

System Design Principle:
> Backend remains the source of truth for time-based logic, but evaluation is triggered lazily (on API calls), not via scheduled jobs.

---

# 1. Objective

Improve:
- Daily engagement
- Streak reliability (without frustration)
- Insight into prayer habits

While keeping implementation:
- Lightweight
- Single-device friendly
- No heavy infra

---

# 2. Feature: Streak Engine (Lazy Evaluation)

## Goal
Maintain streak consistency while allowing recovery within a flexible window.

## Key Rules

### 1. Day Cutoff
- Logical day ends at **3:00 AM local time**
- Not midnight

### 2. Editable Window
- Users can edit logs for **previous 2 days**
- Streak must re-evaluate accordingly

### 3. Qada Recovery
- If a missed prayer is logged as Qada within 24 hours:
  - Streak is preserved

### 4. Protector Tokens (Optional for now)
- Can be skipped in initial version OR
- Simple integer counter

---

## Backend Logic (IMPORTANT)

Streak is NOT stored blindly.

It is:
> Recomputed lazily whenever user interacts

### Trigger Points
- On app open
- On log update
- On analytics request

---

### Evaluation Algorithm

```
1. Get last_evaluated_at
2. Loop through all missing days until today
3. For each day:
   - If excused → skip
   - If complete → increment streak
   - If missed:
       - Check if Qada within 24h
           → preserve
       - Else → reset
4. Update last_evaluated_at
```

---

## Data Model

### Streak

```
user
current_streak
longest_streak
last_evaluated_at
```

---

### DailyLog

```
user
date
fajr / dhuhr / asr / maghrib / isha
is_excused
updated_at
```

---

# 3. Feature: Notifications (Local-First)

## Goal
Reliable reminders without backend dependency

## Implementation

### Channels
- Channel A: Prayer (High priority, Adhan sound)
- Channel B: Reminders (Default)

### Permissions
- Exact alarm permission
- Battery optimization ignore (manual instruction)

---

## Limitations (Accepted)
- Notifications reset on reinstall
- No cross-device sync

---

# 4. Feature: Cloud Offset Sync (Minimal)

## Goal
Persist manual time adjustments

## Backend

```
manual_offsets: JSON
```

Example:
```
{
  "fajr": 5,
  "asr": -2
}
```

---

## Sync Rules
- On login → fetch
- On change → overwrite server

No conflict handling required (single user)

---

# 5. Feature: Analytics (Lightweight)

## Goal
Give basic insights without heavy aggregation

## Approach
- Compute on-demand (acceptable for single user)

## Metrics
- On-time count
- Late count
- Missed count

---

## Visualization
- Radar chart (Flutter)
- Weekly summary card

---

## Sharing

Pipeline:
```
Widget → Image → share_plus
```

---

# 6. Feature: Excused Mode

## Goal
Support valid non-prayer days

## Behavior

When enabled:
- Streak does not increase or break
- Notifications disabled
- Day excluded from analytics

---

# 7. Explicitly Deferred Features

These are intentionally NOT included in this phase:

### ❌ Halaqa (Groups)
Reason:
- Requires aggregation layer
- Requires sync consistency
- Adds complexity not needed now

---

### ❌ Background Jobs (Celery)
Replaced with:
- Lazy evaluation

---

### ❌ Migration Strategy
Reason:
- No production users

---

# 8. Known Trade-offs

| Decision | Trade-off |
|--------|--------|
| No Celery | Slight delay in streak evaluation |
| On-demand analytics | Higher API cost (acceptable) |
| Local notifications | No persistence across reinstall |

---

# 9. Future Upgrade Path

When scaling:

1. Add Celery + Redis
2. Move streak evaluation to scheduled jobs
3. Introduce DailySummary table
4. Add group system (Halaqa)

---

# Final Principle

> Keep logic correct, infrastructure simple.

- Backend = rule engine
- Flutter = UI + trigger

Do not move business logic fully to Flutter even in simplified mode.
