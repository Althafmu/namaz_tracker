# 📘 FINAL — PHASE 3.1 PRD (CLEAN + NON-REDUNDANT)
This is NOT a rewrite.
This is a **delta PRD (Phase 3 → Phase 3.1 upgrade)**
---
# 1. OBJECTIVE
Extend Phase 3 (which solved correctness) into:
> **A system that supports users emotionally and behaviorally without weakening discipline**
---
# 2. WHAT PHASE 3 ALREADY SOLVED (DO NOT TOUCH)
From your implementation:
* ✅ Recovery system (tokens, protected state)
* ✅ Expiry clarity (`is_expired`)
* ✅ Priority handling
* ✅ Cross-day restriction
* ✅ Hidden mechanics (no token exposure)

👉 Phase 3.1 MUST NOT break these.
---

# 3. NEW LAYER INTRODUCED

```text
Behavior Layer (Phase 3.1)
```

Sits between:

* Streak engine
* UI

---

# 4. EPIC 1 — INTENT-BASED ONBOARDING (CORE ADDITION)

---

## Problem

Your current system assumes:

> same discipline for all users

This causes:

* beginners → overwhelmed
* advanced → under-challenged

---

## Solution

Introduce:

> **User Intent Selection**

---

## 4.1 Onboarding Screen

### Title

```text
What are you working towards?
```

---

### Options

#### 🟢 Foundation

> I want to become consistent with my Fard prayers

#### 🟡 Strengthening

> I want to improve discipline and pray regularly

#### 🔵 Growth

> I want to build Sunnah and go beyond basics

---

## 4.2 Backend

```python
intent_level = ["foundation", "strengthening", "growth"]
```

---

## 4.3 Behavior Mapping

| Feature   | Foundation | Strengthening | Growth  |
| --------- | ---------- | ------------- | ------- |
| Recovery  | Flexible   | Limited       | Minimal |
| Messaging | Soft       | Balanced      | Direct  |
| Pre-miss  | Medium     | Strong        | Light   |
| Sunnah    | Hidden     | Hidden        | Enabled |

---

# 5. EPIC 2 — FLEXIBLE RECOVERY (DIRECTLY FROM YOUR CONCERN)

---

## Problem

Phase 3:

> only priority prayer allowed

---

## Your concern

> someone trying to redeem feels blocked

---

## Solution

### Foundation Mode ONLY:

```text
ANY one missed prayer → valid Qada recovery
```

---

## Backend Patch

```python
if config["flexible_recovery"]:
    allow any missed prayer
else:
    use priority system
```

---

## Constraint (unchanged)

* 1 token consumed
* 1 break prevented

---

# 6. EPIC 3 — PRE-MISS INTERVENTION (PREVENTION)

---

## Problem

Current system:

> reacts after failure

---

## Solution

Add prevention layer

---

## Trigger

```text
prayer_time + 30 min AND not logged
```

---

## Notification Flow

| Stage | Message                                  |
| ----- | ---------------------------------------- |
| Early | Don’t forget your prayer                 |
| Mid   | Take a moment for your prayer            |
| Late  | Complete this prayer to keep your streak |

---

## Important

Only last message references streak.

---

# 7. EPIC 4 — NEAR-EXPIRY STATE (MISSING IN PHASE 3)

---

## Add state

```text
NEAR_EXPIRY
```

---

## Trigger

```dart
remainingTime < 4h
```

---

## Message

> Complete this prayer soon to keep your streak

---

# 8. EPIC 5 — FAILURE SOFT LANDING

---

## Problem

Even with improvements:

> streak break still feels harsh

---

## Replace messaging

### Old

> Streak ended

---

### New

> Start again today. Stay consistent.

---

---

## Add memory

```text
Best streak: X
Last streak: Y
```

---

# 9. EPIC 6 — MICRO REINFORCEMENT

---

## Add feedback moments

---

### After Qada

> You stayed consistent. Keep going.

---

### Milestones

| Day | Message            |
| --- | ------------------ |
| 3   | Good start         |
| 7   | Strong consistency |
| 14  | Habit forming      |

---

# 10. EPIC 7 — ONBOARDING PSYCHOLOGY (MOST IMPORTANT FOR YOU)

---

## This directly addresses your concern

---

## Messaging design

---

### Screen 1

> This app helps you stay consistent with your prayers

---

### Screen 2

> Consistency matters more than perfection

---

### Screen 3 (key)

> If you miss occasionally, you still have a chance to make it right

---

### Screen 4

> Start today. One prayer at a time

---

## DO NOT SAY

* tokens
* recovery system
* limits

---

# 11. EPIC 8 — PROGRESSION SYSTEM

---

## Suggest upgrade

After:

* 7 days → suggest Strengthening
* 21 days → suggest Growth

---

## Prompt

> You’ve been consistent. Want to take the next step?

---

# 12. BACKEND CHANGES

---

Add:

* `intent_level`
* `get_user_config()`

Modify:

* recovery logic (flexible mode)
* notification scheduling

---

# 13. FRONTEND CHANGES

---

Add:

* onboarding goal screen
* intent-based UI logic
* near-expiry messaging
* reinforcement banners

---

# 14. EXECUTION ORDER

---

## Step 1

Intent onboarding + config

---

## Step 2

Flexible recovery

---

## Step 3

Pre-miss reminders

---

## Step 4

Near-expiry state

---

## Step 5

Soft landing + reinforcement

---

# 🧠 FINAL PRODUCT SHIFT

---

## Phase 3

> System is correct

---

## Phase 3.1

> System is **human-aware**

---

# 🎯 FINAL ANSWER TO YOUR CORE CONCERN

> “Strictness is harsh for someone trying to redeem”

Correct.

So you **don’t reduce strictness**.

You:

* adapt entry point (intent)
* soften experience (UX)
* keep system strong (rules)

---

# ONE-LINE SUMMARY

> Phase 3.1 turns your system from a strict engine into a guided journey that supports beginners without compromising discipline.

---

