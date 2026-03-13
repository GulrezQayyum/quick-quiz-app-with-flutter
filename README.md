# ⚡ Quick Quiz App

A feature-rich Flutter quiz application with AI integration, real-time leaderboard, XP system, and a beautiful custom UI — built as a portfolio project.

---

## 📸 Category Cards — Designed from Scratch in Figma

Every category card was **hand-designed in Figma** — not templates, not stock UI kits. Each card has its own unique color palette, custom illustration placement, and visual identity.

| Category | Color | Theme |
|----------|-------|-------|
| 🖥️ Computer Science | Teal / Blue | Tech & Programming |
| 🤖 AI & Machine Learning | Purple / Violet | Futuristic |
| 🎨 Art & Literature | Pink / Coral | Creative |
| 🏛️ History & Geography | Brown / Warm | Classic |
| 🏗️ World Architecture | Gray / Monochrome | Structural |
| 🔬 Science & Nature | Green / Earth | Natural |
| 🏆 Sports & Games | Orange / Red | Energetic |

> All 7 category card illustrations were carefully curated and composed in Figma — each one designed to match its subject's visual identity.

---

## ✨ Features

### 🎬 Onboarding Slider
- Beautiful **multi-screen onboarding** shown on first launch
- Smooth slide transitions introducing the app's key features
- "Get Started" button on the final slide navigates to authentication
- Skippable for returning users

### 🔐 Authentication
- **Sign Up** — create an account with email & password via Firebase Auth
- **Login** — returning users sign in securely
- Form validation with error feedback
- Auth state persisted — users stay logged in between sessions
- On first login, a **Firestore profile document** is auto-created

### 🧠 Quiz System
- **Full Quiz Flow** — fully implemented and functional for the **Computer Science** category
- **12 Quiz Topics** within Computer Science: Pointers & Memory, OOP, Algorithm Analysis, Data Structures, Recursion, The Internet, SQL & Databases, Basic Security, and more
- **Other categories** showcase the UI and navigation as portfolio demonstrations
- **Customizable settings** — choose question count, difficulty, and duration before every quiz

### ⏱️ Timer System
- Choose quiz duration: **30 seconds / 1 min / 2 min / 5 min**
- Live countdown with **color feedback** — Green → Orange → Red as time runs out
- Auto-submits with **"⏰ Time's Up!"** result when timer expires
- Displayed in clean `mm:ss` format

### 💡 AI Hint System (Groq)
- **💡 Hint button** in the quiz app bar — powered by Groq AI
- Sends the current question + all answer options to `llama-3.1-8b-instant`
- Returns a **short guiding hint** without spoiling the answer
- One hint per question — greys out after use, disabled after answering

### 🤖 AI Tutor Chatbot (Groq)
- Animated floating **"Ask AI Tutor"** button on the Categories screen
- Slides up as a beautiful **bottom sheet** with a full chat UI
- Maintains **conversation history** for context-aware replies
- Animated **typing indicator** while Groq is thinking
- Powered by `llama-3.1-8b-instant` via Groq REST API

### ⚡ XP & Level System
- Earn XP after every quiz based on score and accuracy
- Formula: `10 base XP + up to 20 accuracy bonus`
- **Level progression** with increasing XP thresholds per level
- Real-time XP bar showing progress within the current level
- XP persisted to Firebase Firestore on the user's profile

### 🏆 Leaderboard
- Real-time leaderboard powered by **Firestore**
- **Top 3 podium** — Gold / Silver / Bronze with special styling
- Ranks 4–20 in a scrollable list below
- Current user row **highlighted** with a `YOU` badge
- Global leaderboard filter

### 👤 Profile Screen
- Display name, bio, location, and favorite categories
- **DiceBear avatars** — randomly generated SVG avatars (`adventurer` style)
- XP progress bar with current level display
- Quizzes played counter
- Fully editable with Firestore sync

---

## 🏗️ Architecture

The app follows **Clean Architecture** with the **BLoC pattern** for state management.

```
lib/
├── core/
│   ├── services/
│   │   └── groq_service.dart          # Groq AI API (hints + chatbot)
│   └── utils/
│       ├── xp_system.dart             # XP calculation & level logic
│       └── avatar_helper.dart         # DiceBear avatar URL generator
│
├── data/
│   └── datasources/
│       ├── quiz_remote_data_source.dart
│       └── profile_remote_data_source.dart
│
├── domain/
│   ├── entities/
│   │   ├── profile_model.dart
│   │   └── quiz_settings.dart         # questionCount, duration, difficulty
│   ├── repositories/
│   │   ├── quiz_repository.dart
│   │   └── profile_repository.dart
│   └── usecases/
│       └── start_quiz.dart
│
├── presentation/
│   ├── blocs/
│   │   ├── quiz_bloc.dart
│   │   ├── quiz_event.dart
│   │   ├── quiz_state.dart
│   │   ├── profile_bloc.dart
│   │   └── profile_event.dart
│   ├── screens/
│   │   ├── categories.dart            # Main category selection screen
│   │   ├── profile_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   └── quiz_home_page.dart
│   └── UI_Widget/
│       ├── ai_chat_sheet.dart         # AI chatbot bottom sheet
│       ├── dialogs/
│       │   └── quiz_start_dialog.dart
│       └── pages/
│           ├── compSciencePage.dart
│           ├── aiPage.dart
│           ├── artLiteraturePage.dart
│           ├── historyGeoPage.dart
│           ├── architecturePage.dart
│           ├── natureSciPage.dart
│           └── sportsPage.dart
│
└── injection_container.dart           # GetIt dependency injection
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter / Dart |
| **Architecture** | BLoC + Clean Architecture |
| **State Management** | flutter_bloc |
| **Dependency Injection** | GetIt |
| **Backend** | Firebase Firestore + Firebase Auth |
| **AI** | Groq API (`llama-3.1-8b-instant`) |
| **Avatars** | DiceBear API v7 |
| **Animations** | Lottie |
| **HTTP** | dart:http |

---

## 📦 Key Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.x
  get_it: ^7.x
  firebase_core: ^4.4.0
  firebase_auth: ^5.5.1
  cloud_firestore: ^5.6.5
  firebase_storage: ^12.4.3
  flutter_svg: ^2.0.10+1
  lottie: ^3.1.0
  http: ^1.x
```

---

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0
- A Firebase project
- Groq API key — free at [console.groq.com](https://console.groq.com)

### Installation

```bash
# 1. Clone the repo
git clone https://github.com/GulrezQayyum/quick-quiz-app-with-flutter.git
cd quick-quiz-app-with-flutter

# 2. Install dependencies
flutter pub get

# 3. Add Firebase config
# Place google-services.json → android/app/
# Place GoogleService-Info.plist → ios/Runner/

# 4. Create Groq service file
# lib/core/services/groq_service.dart
# Set: static const _apiKey = 'your_gsk_key_here';
# Set: static const _model  = 'llama-3.1-8b-instant';

# 5. Run
flutter run
```

### Android — Internet Permission
Add to `android/app/src/main/AndroidManifest.xml` above `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---



## 📱 Full App Flow

```
App Launch
    ↓
Onboarding Slider  (first launch only)
    ↓ swipe through slides → "Get Started"
    ↓
Authentication
    ├── New user  → Sign Up (email + password) → Firestore profile created
    └── Returning → Login  (email + password) → auth state restored
    ↓
Categories Screen  (🤖 Ask AI Tutor floating button)
    ↓ tap a category card
Category Page  (e.g. Computer Science)
    ↓ tap ▶️ on a topic
QuizHomePage
    ↓ auto-opens QuizStartDialog (Lottie animation)
    ↓ select time & tap "Start Quiz"
Quizpage
    ↓ countdown timer runs
    ↓ answer questions  (💡 one AI hint available per question)
    ↓ timer ends  OR  all questions answered
Result Dialog
    ↓ score  •  accuracy %  •  +XP badge
    ↓ XP saved to Firestore profile
Back to Category Page ✅
```

---

## 👨‍💻 Author

**Gulrez Qayyum**

[LinkedIn](https://linkedin.com/in/GulrezQayyum)
[GitHub](https://github.com/GulrezQayyum)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
