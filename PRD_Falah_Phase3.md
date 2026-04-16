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

#### 1. Weekly Protector Limit
- Max 3 tokens per week
- Reset every week (Sunday 3 AM local time)

#### 2. Token Earning Rule
- Earn 1 token after X consecutive valid days (configurable)

#### 3. Token Cap
- Max tokens stored: 3

#### 4. Anti-Gaming Rule
- Cannot recover more than 1 day per 24h

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

1. Streak Economy Fix
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
