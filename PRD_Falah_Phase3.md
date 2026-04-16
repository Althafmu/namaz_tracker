# FALAH PHASE 3 — PRODUCT + ENGINEERING PRD

## 1. OBJECTIVE

Phase 3 focuses on:
- Fixing behavioral gaps in Phase 2
- Strengthening habit formation logic
- Introducing optional growth systems (Sunnah)

---

## 2. CORE PROBLEMS IDENTIFIED (FROM PHASE 2)

### 2.1 Streak System Gaps
- No weekly limit on protector tokens
- System can be gamed via unlimited recovery
- No chronological enforcement
- No pre-miss intervention

### 2.2 Behavioral Gaps
- Analytics shows data but no insights
- No habit reinforcement loops
- No intelligent nudges

### 2.3 Validation Gaps
- Time offset has no bounds validation

---

## 3. EPIC 1 — ADVANCED STREAK ECONOMY

### Objective
Introduce scarcity and fairness to prevent gaming and improve habit formation.

### Features

#### 1. Weekly Protector Limit ✅
- Max 3 tokens per week — DONE (Sprint 1)
- Reset every week (Sunday 3 AM local time) — DONE (Sprint 1)

#### 2. Token Earning Rule ⏳ DEFERRED
- Earn 1 token after X consecutive valid days (configurable) — Not yet implemented
- This is a future enhancement to the token economy

#### 3. Token Cap ✅
- Max tokens stored: 3 — Already existed from Phase 2

#### 4. Anti-Gaming Rule ✅
- Cannot recover more than 1 day per 24h — DONE (Sprint 1)

---

## 4. EPIC 2 — CHRONOLOGICAL CONSISTENCY ENGINE

### Objective
Ensure logical prayer sequence integrity

### Rules

IF user logs next prayer without previous:
→ auto-mark previous as MISSED (after prompt)

### Implementation
- Add validation in frontend logging flow
- Backend double-check in evaluation service

---

## 5. EPIC 3 — PRE-MISS INTERVENTION SYSTEM

### Objective
Reduce streak breaks before they happen

### Features

- Smart reminders:
  - If prayer not logged within X minutes
  - Trigger "You haven’t logged Asr"

- Escalation:
  - Soft → Strong reminder before 3AM cutoff

---

## 6. EPIC 4 — BEHAVIORAL ANALYTICS

### Objective
Move from data → insight

### Features

- Insights:
  - "You miss Asr most often"
  - "Your consistency improved this week"

- Streak milestones:
  - 7 day / 30 day reinforcement

- Weekly report generation

---

## 7. EPIC 5 — TIME OFFSET VALIDATION

### Rules

- Allowed range: -30 min to +30 min
- Reject invalid values

---

## 8. EPIC 6 — SUNNAH PRAYER LAYER

(From new PRD)

### Objective
Optional growth system without pressure

### Key Rules

- No streak impact
- No penalties
- Positive reinforcement only

---

### Backend

Model:
SunnahLog

Endpoints:
- POST /api/v2/sunnah/log/
- GET /api/v2/sunnah/daily/
- GET /api/v2/sunnah/weekly/

---

### Frontend

- Toggle in settings
- Separate UI section
- Score-based tracking

---

## 9. SCALABILITY UPDATES

### Phase 3 Additions

- Introduce Celery for:
  - Pre-miss reminders
  - Analytics aggregation

- Keep cron as fallback

---

## 10. PRIORITY ORDER

- [x] ~~1. Streak Economy Fix~~ → **COMPLETED (Sprint 1)**
2. Chronological Engine
3. Pre-Miss System
4. Behavioral Analytics
5. Sunnah Layer
6. Validation

---

## 11. SUCCESS METRICS

- Reduction in streak breaks
- Increase in DAU
- Increase in average streak length
- Sunnah adoption rate

---

END OF PHASE 3 PRD

Here is a **Phase 3 breakdown at execution level**, aligned with your current codebase (Flutter + Django) and structured so a coding agent (or you) can implement without ambiguity.

I’m not going to keep this high-level—this is **file-level + task-level decomposition**.

---

# PHASE 3 — IMPLEMENTATION BREAKDOWN

---

# EPIC 1 — STREAK ECONOMY (Token Limits + Anti-Gaming)

> ✅ **COMPLETED (Sprint 1)**

## Backend (Django)

### 1. Modified Streak Model

**File:** `prayers/models.py`

Added:
- `weekly_tokens_used = models.PositiveIntegerField(default=0)`
- `last_token_used_at = models.DateTimeField(null=True, blank=True)`
- Constants: `WEEKLY_TOKEN_LIMIT = 3`, `ANTI_GAMING_COOLDOWN_HOURS = 24`
- Changed weekly reset from Monday → **Sunday** (via `_current_week_start` using Sunday-based calculation)

### 2. Weekly Reset Logic

Integrated into `recalculate()` method + `_is_new_week()` helper:
- Resets `weekly_tokens_used = 0` when new week detected (Sunday 3 AM local)
- Updates `tokens_reset_date` to current Sunday

### 3. Token Consumption Rule

Modified `consume_protector_token()`:
- Checks `weekly_tokens_used >= WEEKLY_TOKEN_LIMIT` → rejects if limit hit
- Tracks `weekly_tokens_used += 1` on each consumption
- Sets `last_token_used_at = timezone.now()`

### 4. Anti-Gaming Rule

New `can_use_token()` method:
- Enforces 24h cooldown between token uses
- Returns `{'allowed': bool, 'reason': string}` for frontend messaging

### 5. API Changes

**File:** `prayers/views.py` — `consume_protector_token` endpoint
- Added weekly limit + anti-gaming checks before consuming
- Updated error messages to reflect Sunday reset

**File:** `prayers/serializers.py` — `StreakSerializer`
- Added `weekly_token_limit`, `weekly_tokens_remaining`, `anti_gaming_cooldown_hours` fields

**Migration:** `0007_sprint1_streak_economy.py` — Applied

---

## Frontend (Flutter)

### Files Modified

* `domain/entities/streak.dart` — Added weekly token fields
* `data/models/streak_model.dart` — Parse new backend fields
* `presentation/bloc/streak/streak_event.dart` — Updated `UpdateStreak`
* `presentation/bloc/streak/streak_bloc.dart` — Updated `_onUpdateStreak`
* `presentation/pages/home/widgets/streak_header.dart` — Show weekly tokens remaining badge
* `presentation/pages/home/widgets/qada_recovery_dialog.dart` — Disable button + message when weekly limit hit

### Tasks Implemented

✅ Show weekly tokens remaining in streak header (e.g., `2/3` badge)
✅ Disable recovery button if weekly limit reached
✅ Show message: “Weekly recovery limit reached. Reset every Sunday.”

---

# EPIC 2 — CHRONOLOGICAL ENGINE

## Backend

### Add Validation Layer

**File:** `prayers/services/prayer_validation.py`

```python
def enforce_prayer_order(user, prayer_type, date):
    previous_prayer = get_previous_prayer(prayer_type)

    if not logged(previous_prayer):
        mark_as_missed(previous_prayer)
```

---

## Frontend

### Files

* `prayer_bloc.dart`
* `log_prayer_usecase.dart`

---

### Flow

When logging prayer:

1. Check previous prayers

2. If missing:

   * Show prompt:

     > “Mark previous prayer as missed?”

3. If confirmed:

   * auto-mark

---

# EPIC 3 — PRE-MISS INTERVENTION SYSTEM

## This is where Celery becomes useful

---

## Backend

### Create Task

**File:** `prayers/tasks.py`

```python
@shared_task
def send_pre_miss_reminder(user_id, prayer_type):
    if not logged:
        send_notification()
```

---

## Scheduler

* Schedule:

  * X minutes after prayer time
  * Before 3AM cutoff

---

## Frontend

### Update Notification Service

**File:** `notification_service.dart`

Add:

```dart
schedulePreMissReminder()
```

Triggers:

* after prayer time + delay

---

# EPIC 4 — BEHAVIORAL ANALYTICS

## Backend

### New Endpoint

**File:** `analytics/views.py`

```python
GET /api/analytics/insights/
```

---

### Logic

```python
def generate_insights(user):
    return [
        "You miss Asr most often",
        "Your consistency improved by 20%"
    ]
```

---

## Frontend

### Files

* `analytics_screen.dart`
* `insights_widget.dart`

---

### UI

Add section:

```text
📊 Insights
- You improved this week
- You miss Asr most often
```

---

# EPIC 5 — TIME OFFSET VALIDATION

## Backend

**File:** `profile/views.py`

Add:

```python
if offset < -30 or offset > 30:
    return error
```

---

## Frontend

Add validation before API call

---

# EPIC 6 — SUNNAH SYSTEM

(From your new PRD)

---

## Backend

### New App (Recommended)

```bash
python manage.py startapp sunnah
```

---

### Model

```python
class SunnahLog(models.Model):
    user
    date
    prayer_type
    completed
```

---

### APIs

* POST `/api/v2/sunnah/log/`
* GET `/api/v2/sunnah/daily/`
* GET `/api/v2/sunnah/weekly/`

---

## Frontend

### New Module

```
features/sunnah/
  sunnah_bloc.dart
  sunnah_screen.dart
```

---

### Add Toggle

**File:** `settings_page.dart`

```dart
SwitchListTile(
  title: Text("Enable Sunnah")
)
```

---

### UI Rules

* No red states
* No streak
* Only positive indicators

---

# EXECUTION PLAN (SPRINT LEVEL)

---

## Sprint 1 (Core Fix) ✅ COMPLETED

* Token limits — DONE
* Anti-gaming — DONE
* Weekly reset (Sunday 3 AM) — DONE

---

## Sprint 2 (Logic Integrity)

* Chronological enforcement
* Backend validation

---

## Sprint 3 (Behavior Layer)

* Pre-miss reminders
* Notification upgrade

---

## Sprint 4 (Engagement)

* Insights system
* UI integration

---

## Sprint 5 (Expansion)

* Sunnah backend
* Sunnah frontend

---

## Sprint 6 (Polish)

* Validation
* UX messaging
* Edge cases

---

# CRITICAL IMPLEMENTATION NOTES

### 1. Do NOT break existing streak logic

Extend, don’t rewrite.

---

### 2. Keep evaluation idempotent

Re-running should not corrupt streak.

---

### 3. Sunnah must remain isolated

Never mix with:

* streak
* penalties

---

### 4. Introduce Celery ONLY for:

* Pre-miss reminders
* Future group features

---

# Final Assessment

You are now moving into:

> Phase 3 = Behavioral Optimization Layer

If implemented correctly:

* Your app shifts from **tracker → habit system**
* This is where retention actually comes from

---

Here is a **precise, engineering-ready implementation plan** for the “temporary streak protection + Qada recovery messaging system”, aligned with your current architecture (Flutter + Django, streak engine already present).

This is **plug-and-play level**, not conceptual.

---

# 🎯 FEATURE: TEMPORARY STREAK PROTECTION UX

---

# 1. TRIGGER CONDITIONS (BACKEND + FRONTEND CONTRACT)

## Condition to activate protection message

In your existing evaluation logic:

```python
missed_prayer AND within_24h_window AND recovery_possible
```

Expose this state via API:

---

## Backend Change

### File: `streak_service.py`

Add:

```python
def get_recovery_status(user, prayer_log):
    return {
        "is_protected": True,
        "expires_at": prayer_log.time + timedelta(hours=24),
        "requires_qada": True
    }
```

---

### API Response Update

Example (`/api/prayers/today/` or similar):

```json
{
  "prayer": "Asr",
  "status": "MISSED",
  "recovery": {
    "is_protected": true,
    "expires_at": "2026-04-16T23:59:00Z",
    "requires_qada": true
  }
}
```

---

# 2. FRONTEND STATE MODEL

## Update Prayer Model

### File: `prayer_entity.dart`

```dart
class RecoveryState {
  final bool isProtected;
  final DateTime? expiresAt;
  final bool requiresQada;
}
```

Attach to Prayer:

```dart
final RecoveryState? recoveryState;
```

---

# 3. UI DISPLAY LOGIC

---

## CASE 1 — MISSED BUT RECOVERABLE

### Condition

```dart
if (prayer.isMissed && prayer.recoveryState?.isProtected == true)
```

---

## UI COMPONENT

### File: `prayer_tile.dart` (or equivalent)

Add warning card:

```dart
Container(
  padding: EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: Colors.orange.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    "Your streak is protected for now. Complete this prayer before the day ends to keep it.",
    style: TextStyle(fontSize: 12),
  ),
)
```

---

## OPTIONAL: Time-sensitive message

If < 6 hours remaining:

```dart
"Complete this prayer soon to keep your streak"
```

---

# 4. TIMER / COUNTDOWN (OPTIONAL BUT STRONG)

---

## Add countdown logic

### File: `utils/time_utils.dart`

```dart
Duration getRemainingTime(DateTime expiresAt) {
  return expiresAt.difference(DateTime.now());
}
```

---

## UI (optional enhancement)

```dart
Text("Time left: ${formatDuration(remaining)}")
```

⚠️ Do NOT show exact hours like “24h”
→ Show relative:

* “Ends today”
* “Ending soon”

---

# 5. ESCALATION LOGIC (IMPORTANT)

---

## Level 1 (just missed)

> “Your streak is protected for now…”

---

## Level 2 (mid window)

Trigger when:

```dart
remainingTime < 12h
```

Message:

> “Complete this prayer today to keep your streak”

---

## Level 3 (urgent)

```dart
remainingTime < 4h
```

Message:

> “Complete this prayer soon to avoid losing your streak”

---

# 6. NOTIFICATION INTEGRATION

---

## Add Pre-expiry Reminder

### File: `notification_service.dart`

Add:

```dart
scheduleRecoveryReminder(prayer) {
  // schedule at expiry - 2h
}
```

---

## Notification Text

> “Complete your missed prayer to keep your streak”

---

# 7. BACKEND VALIDATION (CRITICAL)

---

## In streak evaluation

### File: `streak_service.py`

Before breaking streak:

```python
if within_24h and has_token:
    preserve_streak
else:
    break_streak
```

---

## Ensure:

* Expired → no protection
* Qada logged → restore

---

# 8. UX EDGE CASES

---

## Case: User logs Qada

Immediately:

* Remove warning
* Show:

> “Streak maintained”

---

## Case: Expired

Replace UI with:

> “Streak ended. Start again today.”

---

## Case: Multiple missed prayers

Show only:

* highest priority (latest missed)

Avoid clutter.

---

# 9. DO NOT IMPLEMENT (IMPORTANT)

---

❌ No “Use token” button
❌ No token count display
❌ No “24h remaining” exact timer
❌ No “recovery system” wording

---

# 10. FINAL FLOW SUMMARY

---

### Step 1 — User misses prayer

→ mark as MISSED (pending → missed)

---

### Step 2 — Recovery active

→ show protection message

---

### Step 3 — User logs Qada

→ remove warning
→ preserve streak

---

### Step 4 — If time expires

→ streak breaks

---

# 11. FILE CHANGE SUMMARY

---

## Backend

* `streak_service.py` → recovery status
* API response update

---

## Frontend

* `prayer_entity.dart` → recoveryState
* `prayer_tile.dart` → warning UI
* `notification_service.dart` → reminder
* optional: `time_utils.dart`

---

# 12. FINAL RESULT

User perceives:

* “I still have a chance”
* “I need to act now”

Without ever knowing:

* tokens
* limits
* system logic

---

# One-line implementation intent

> Show **temporary protection + required action + urgency**, without exposing system mechanics.



