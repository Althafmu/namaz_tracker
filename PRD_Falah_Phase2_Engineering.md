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

## 4. EPIC 1 — STREAK ENGINE

### 4.1 STATES
ON_TIME, LATE, MISSED, QADA, EXCUSED, PENDING

### 4.2 EVALUATION RULE

IF all prayers valid → increment streak
ELSE IF QADA within 24h AND token available → consume token
ELSE → break streak

### 4.3 DATA MODELS

Streak:
- user_id
- current_streak
- protector_tokens
- last_evaluated_at

PrayerLog:
- is_qada
- is_excused

---

### 4.4 BACKEND TASK

Command:
manage.py evaluate_streaks

Cron (initial):
0 3 * * *

Future:
Celery Beat → per-user timezone scheduling

---

### 4.5 FRONTEND LOGIC

- Maintain PENDING state
- Trigger evaluation on app open if past 3AM
- Qada recovery prompt

---

## 5. EPIC 2 — NOTIFICATIONS

### REQUIREMENTS

- Exact alarm permission onboarding
- Two channels:
  - High priority (Adhan)
  - Default (Reminders)

### SERVICE
notification_service.dart

Triggers:
- App open
- Offset change
- Login

---

## 6. EPIC 3 — CLOUD SYNC

### DATA
manual_offsets JSON

### API
GET /profile
PATCH /profile/offsets

### RULE
Last write wins

---

## 7. EPIC 4 — ANALYTICS

### BACKEND (OPTIONAL AGGREGATION)
/analytics/weekly

### FRONTEND
- Radar chart (fl_chart)
- Weekly summary card
- RepaintBoundary → share_plus

---

## 8. EPIC 5 — GROUPS (HALAQA)

### MODELS
Group
GroupMembership
InviteToken

### API
- create group
- join group
- fetch members
- fetch stats

### PRIVACY
- Streak only
- Summary
- Full logs

---

## 9. EPIC 6 — EXCUSED MODE

### BEHAVIOR
- Freeze streak
- Disable notifications
- Exclude from analytics

---

## 10. SCALABILITY ROADMAP

### STAGE 1 (CURRENT)
- Cron job
- Monolith Django

### STAGE 2
- Introduce Celery workers
- Async group aggregation

### STAGE 3
- Split services:
  - Streak service
  - Notification service

---

## 11. FAILURE HANDLING

- Retry logic (future Celery)
- Local fallback reminders
- Re-evaluation support

---

## 12. METRICS

- DAU
- Streak survival rate
- Group engagement

---

## 13. DELIVERY ORDER

1. Streak Engine
2. Notifications
3. Cloud Sync
4. Analytics
5. Groups
6. Excused Mode

---

## 14. KEY ENGINEERING NOTES

- Always store UTC
- Evaluate in local time
- Ensure idempotency
- Design services for async upgrade

---

END OF PRD
