# FALAH PHASE 2 — ENGINEERING PRD (SCALABLE VERSION)

## 1. OBJECTIVE
Transform the system from a passive logging app into a state-driven behavioral engine that maximizes retention, engagement, and social accountability.

---

## 2. SYSTEM ARCHITECTURE (TARGET)

### Layers
1. Client Layer (Flutter - Offline First)
2. API Layer (Django REST)
3. Domain Layer (Services - Streak, Analytics, Groups)
4. Task Layer (Scheduler - Cron → Celery upgrade path)
5. Data Layer (PostgreSQL)

---

## 3. CORE DESIGN PRINCIPLES

- Offline-first with eventual consistency
- Idempotent evaluation logic
- Timezone-safe computation
- Replaceable scheduler (Cron → Celery)

---

## 4. EPIC 1 — STREAK ENGINE ✅ COMPLETED

### 4.1 STATES
ON_TIME, LATE, MISSED, QADA, EXCUSED, PENDING ✅

### 4.2 EVALUATION RULE

IF all prayers valid → increment streak
ELSE IF QADA within 24h AND token available → consume token
ELSE → break streak ✅

### 4.3 DATA MODELS

Streak:
- user_id ✅
- current_streak ✅
- protector_tokens ✅
- last_evaluated_at ✅

PrayerLog:
- is_qada ✅
- is_excused ✅

---

### 4.4 BACKEND TASK

Command: ✅
`manage.py evaluate_streaks`

Cron (initial): ✅
`0 3 * * *`

Future:
Celery Beat → per-user timezone scheduling

---

### 4.5 FRONTEND LOGIC

- Maintain PENDING state ✅
- Trigger evaluation on app open if past 3AM ✅
- Qada recovery prompt ✅

---

## 5. EPIC 2 — NOTIFICATIONS ✅ COMPLETED

### REQUIREMENTS

- Exact alarm permission onboarding ✅
- Two channels: ✅
  - High priority (Adhan) ✅
  - Default (Reminders) ✅

### SERVICE
`notification_service.dart` ✅

Triggers:
- App open ✅
- Offset change ✅
- Login ✅

---

## 6. EPIC 3 — CLOUD SYNC ✅ COMPLETED

### DATA
manual_offsets JSON ✅

### API
GET /profile ✅
PATCH /profile/offsets ✅ (wired into urls.py)

### RULE
Last write wins ✅

---

## 7. EPIC 4 — ANALYTICS ✅ COMPLETED

### BACKEND ✅
`/api/analytics/weekly/` endpoint implemented in `views.py` ✅
Returns per-prayer-type counts and status breakdown for last 7 days, excluding excused.

### FRONTEND ✅
- Radar chart using `fl_chart: ^0.69.0` package ✅ (`widgets/radar_chart.dart`)
- `PrayerRadarChart` widget added to `ProgressPage` ✅
- Weekly summary card ✅ (integrated in ProgressPage via `HistoryState.weeklyPrayerCount` and `weeklyDayLabels`)
- RepaintBoundary → share_plus ✅ (`_shareProgress` uses `SharePlus.instance.share`)

---

## 8. EPIC 5 — GROUPS (HALAQA) 📋 PENDING

### MODELS 📋 PENDING
- `Group` model 📋
- `GroupMembership` model 📋
- `InviteToken` model 📋

### API 📋 PENDING
- create group
- join group
- fetch members
- fetch stats

### PRIVACY 📋 PENDING
- Streak only
- Summary
- Full logs

**Largest remaining gap.** Requires: Group CRUD, invite system, privacy-gated stats, member list, Flutter UI (create/join group, member view, privacy settings).

---

## 9. EPIC 6 — EXCUSED MODE ✅ COMPLETED

### BEHAVIOR
- Freeze streak ✅ (all 5 prayers set to `is_valid_for_streak=True` on backend, `isValidForStreak` includes `isExcused` on frontend)
- Disable notifications ✅ (`excusedDays: Set<String>` in `SettingsState`, `NotificationService.schedulePrayerNotifications` skips excused dates)
- Exclude from analytics ✅ (`weeklyPrayerCount` and `weeklyPercentages` filter `!isExcused`, backend `analytics_view` excludes excused)

---

## 10. SCALABILITY ROADMAP

### STAGE 1 (CURRENT)
- Cron job ✅
- Monolith Django ✅

### STAGE 2
- Introduce Celery workers
- Async group aggregation

### STAGE 3
- Split services:
  - Streak service
  - Notification service

---

## 11. FAILURE HANDLING

- Retry logic (future Celery) 📋
- Local fallback reminders ✅
- Re-evaluation support ✅

---

## 12. METRICS

- DAU 📋
- Streak survival rate 📋
- Group engagement 📋

---

## 13. DELIVERY ORDER

1. ~~Streak Engine~~ ✅
2. ~~Notifications~~ ✅
3. ~~Cloud Sync~~ ✅
4. ~~Excused Mode~~ ✅
5. ~~Analytics~~ ✅ (backend + frontend)
6. **Groups** — largest gap 📋

---

## 14. KEY ENGINEERING NOTES

- Always store UTC ✅
- Evaluate in local time ✅
- Ensure idempotency ✅
- Design services for async upgrade ✅

---

## 15. COMPLETED ITEMS SUMMARY

### Backend
- `Streak` model with `protector_tokens`, `recalculate()` ✅
- `DailyPrayerLog.is_valid_for_streak` property ✅
- `/api/streak/consume-token/` endpoint ✅
- `/api/prayers/excused/` endpoint ✅
- `/api/profile/offsets/` endpoint (PATCH) ✅
- `/api/analytics/weekly/` endpoint ✅
- `evaluate_streaks` management command ✅

### Frontend
- `Prayer` entity with `isQada`, `isExcused`, `isValidForStreak` ✅
- `SettingsBloc` with `excusedDays`, cloud sync events ✅
- `AuthRepository.patchProfileOffsets()` ✅
- `NotificationService.schedulePrayerNotifications` skips `excusedDays` ✅
- `PrayerSchedulerService` passes `excusedDays` through ✅
- `StreakBloc._onSetExcusedDay` wires excused day → cancel notifications ✅
- `HistoryState.weeklyPrayerCount` and `weeklyPercentages` exclude excused ✅
- `StreakRingPainter` renders `isExcused` as muted gray ✅
- `AppColorPalette.statusExcused` color added ✅
- `ProgressPage._shareProgress` excludes excused from todayCount ✅

---

END OF PRD