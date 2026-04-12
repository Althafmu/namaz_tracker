# 🕌 Falah: Prayer Tracker

A beautifully designed, offline-first Flutter application that helps Muslims build consistent prayer habits through gamification, smart reminders, and insightful progress tracking.

> **Falah** (فلاح) means *success* and *prosperity* in Arabic — the very word used in the Adhan.

---

## ✨ Features

### 🏠 Dashboard
- **Daily Prayer Checklist** — Track all 5 daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) at a glance
- **Real-time Prayer Times** — Accurate salah times calculated via GPS using the [Adhan](https://pub.dev/packages/adhan) library with support for 11+ calculation methods
- **Streak Counter** — Track your current consecutive day streak with a fire badge
- **Motivational Quotes** — Daily Islamic reminders embedded between prayer cards

### 📝 Smart Prayer Logger
- **Jama'at Tracking** — Log whether you prayed in congregation (+10 XP bonus)
- **Location Logging** — Record where you prayed: Mosque, Home, or Work
- **Status Tracking** — Mark prayers as On Time, Late, or Missed
- **Reason Tracking** — Optionally log why a prayer was missed or late (fully customizable reasons)
- **Edit & Delete** — Modify or remove a logged prayer anytime

### 📊 Progress Room
- **Streak Ring** — A custom-painted circular progress indicator showing today's completion across all 5 prayers
- **Monthly Calendar Heatmap** — Visual calendar with color-coded cells (green → fully prayed, yellow → partial, gray → missed) with month-by-month navigation
- **Top Reasons Analysis** — See your most common reasons for missing prayers with visual bar charts
- **Achievement Badges** — Unlock badges dynamically:
  - 🌅 **Early Bird** — Complete Fajr
  - 👥 **Congregation Captain** — Pray in Jama'at
  - 📅 **Perfect Month** — 30-day streak
  - 🌙 **Night Owl** — Complete Isha
- **Share Progress** — Share your streak and weekly stats with friends

### ⚙️ Settings & Customization
- **Prayer Calculation Methods** — Choose from 11+ methods (ISNA, MWL, Egyptian, Umm Al-Qura, Karachi, Dubai, Kuwait, Qatar, Singapore, Tehran, Turkey)
- **Juristic Method** — Toggle between Standard (Shafi/Maliki/Hanbali) and Hanafi for Asr timing
- **Manual Time Offsets** — Fine-tune each prayer time with ±120 minute adjustments
- **Custom Notification Sounds** — Choose between built-in Islamic alarm sounds (Hayya Ala Salat, Namaz Reminder) or system defaults
- **Customizable Missed Reasons** — Add, remove, or reorder the reasons list to match your needs
- **Profile Management** — Edit your name and view your streak badge

### 🔔 Notifications & Alarms
- **Exact Alarm Scheduling** — Precise prayer-time notifications via Android exact alarms
- **Per-Prayer Toggles** — Enable/disable notifications for each individual prayer
- **Custom Reminder Offsets** — Set reminders minutes before the actual prayer time
- **Boot-Persistent** — Alarms survive device restarts via `RECEIVE_BOOT_COMPLETED`
- **Sound Preview** — Test your selected notification sound before saving

### 🔐 Authentication
- **Account System** — Sign up and login with username/email and password
- **Secure Token Storage** — JWT-based auth with tokens stored in Flutter Secure Storage
- **Offline-First** — Full app functionality without internet; data syncs when reconnected
- **Profile Editing** — Update first/last name from within the app

### 🔄 Sync & Data
- **Offline Queue** — All prayer logs are queued locally and synced to the backend when connectivity is restored
- **HydratedBloc Persistence** — Full app state (prayers, streaks, history, settings) persisted across app launches via Hive
- **Backend Sync** — Prayer data syncs with a Django REST backend for cross-device access
- **Smart Fetching** — Monthly data fetched on-demand for the calendar; reason analytics fetched once and cached

---

## 🏗️ Architecture

The app follows **Clean Architecture** with a feature-based folder structure:

```
lib/
├── core/
│   ├── network/          # Dio HTTP client, token interceptor
│   ├── router/           # GoRouter with auth-guarded navigation
│   ├── services/         # Prayer times, notifications, offline sync, alarm scheduler
│   ├── theme/            # Neo-Brutalist design system (colors, typography, theme)
│   └── widgets/          # Reusable UI components (NeoButton, NeoCard, NeoTextField, etc.)
├── features/
│   ├── auth/
│   │   ├── data/         # AuthRemoteDataSource, AuthRepositoryImpl
│   │   ├── domain/       # User entity, AuthRepository interface
│   │   └── presentation/ # AuthBloc, Login/Signup/Onboarding pages
│   └── prayer/
│       ├── data/         # PrayerRemoteDataSource, OfflineQueue, RepositoryImpl
│       ├── domain/       # Prayer/Streak entities, UseCases
│       └── presentation/
│           ├── bloc/
│           │   ├── prayer/    # PrayerBloc (hydrated), events, state
│           │   └── settings/  # SettingsBloc for app preferences
│           └── pages/
│               ├── home/           # Dashboard + widgets
│               ├── progress/       # Progress room + widgets
│               ├── prayer_logger/  # Bottom sheet logger + widgets
│               ├── profile/        # Settings/Profile + widgets
│               └── settings/       # Notifications, Calculation, Reasons pages
├── injection_container.dart  # GetIt dependency injection
└── main.dart                 # App entry point
```

### Key Architectural Decisions
- **BLoC Pattern** with `flutter_bloc` + `hydrated_bloc` for state management and persistence
- **GetIt** for dependency injection across all layers
- **GoRouter** with auth redirect guards and shell route for bottom navigation
- **Offline-First** — local state is the source of truth; backend sync is opportunistic
- **Neo-Brutalist Design** — Bold borders, solid shadows, vibrant colors, thick outlines

---

## 🎨 Design System

The app uses a **Neo-Brutalist** aesthetic with:

| Token | Value |
|-------|-------|
| Primary | `#FF6B6B` (Coral Red) |
| Streak | `#4ADE80` (Green) |
| Jama'at | `#2DD4BF` (Teal) |
| Background | `#FFF8F0` (Warm Cream) |
| Surface | `#FFFFFF` |
| Border | `#1A1A2E` (Dark Navy) |
| Shadows | Solid offset (no blur) |
| Corners | 16px rounded |
| Font | Google Fonts (system-configured) |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x (Dart 3.10+) |
| State Management | flutter_bloc + hydrated_bloc |
| Navigation | go_router |
| DI | get_it |
| Local Storage | Hive (via hive_flutter) |
| Secure Storage | flutter_secure_storage |
| HTTP Client | Dio |
| Prayer Times | adhan (astronomical calculation) |
| Location | geolocator |
| Notifications | flutter_local_notifications |
| Timezone | flutter_timezone + timezone |
| Sharing | share_plus |
| Audio | audioplayers |
| Fonts | google_fonts |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.10.7`
- Android Studio / VS Code
- A physical device or emulator (notifications require Android 8+)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/falah-prayer-tracker.git
cd falah-prayer-tracker

# Install dependencies
flutter pub get

# Run on a device
flutter run
```

### Backend (Optional)
The app works fully offline. For cloud sync, set up the companion Django backend:

```bash
cd namaz_backend
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

---

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| Android  | ✅ Full support (primary target) |
| iOS      | ✅ Supported |
| Web      | ⚠️ Basic support (no notifications) |

---

## 📄 License

This project is private and not yet released under an open-source license.

---

<p align="center">
  Built with ❤️ and Flutter<br/>
  <em>"Hayya 'ala al-Falah" — Come to success</em>
</p>
