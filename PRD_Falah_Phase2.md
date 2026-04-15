# Falah Phase 2 PRD (Celery Architecture)

## Overview
This document defines Phase 2 of the Namaz Tracker system with a time-aware backend using Celery and Redis.

---

## Architecture

- Django (API)
- Celery (Worker)
- Redis (Broker)
- Celery Beat (Scheduler)

All time-based logic is executed asynchronously.

---

## Feature 1: Streak Engine

- Daily evaluation at 3:00 AM
- Protector tokens for Qada recovery
- Backend-controlled streak logic

---

## Feature 2: Notifications

- Local (Flutter) for Adhan
- Backend (Celery) for reminders

---

## Feature 3: Cloud Offsets

- Store prayer time adjustments in backend
- Sync via API

---

## Feature 4: Analytics

- Precomputed using Celery
- DailySummary model

---

## Feature 5: Halaqa (Future)

- Group tracking system
- Requires aggregation layer

---

## Feature 6: Excused Mode

- Freeze streak
- Disable notifications

---

## Notes

- Backend is source of truth
- Flutter is display layer only
- All time-based rules handled via Celery
