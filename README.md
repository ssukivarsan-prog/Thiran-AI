# 🌟 Thiran AI (Jeevika AI) — Multilingual Voice-First Livelihood Intelligence Platform

[![Live Web App](https://img.shields.io/badge/Live_Web_App-Netlify-00C7B7?style=for-the-badge&logo=netlify&logoColor=white)](https://thrianaiadmin.netlify.app/)
[![Download Android APK](https://img.shields.io/badge/Download_APK-Release_v1.0-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/ssukivarsan-prog/Thiran-AI/raw/main/release/app-release.apk)
[![Flutter](https://img.shields.io/badge/Flutter-3.41+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

> **Thiran AI** is a production-grade, multilingual, voice-first livelihood intelligence ecosystem designed to bridge grassroots aspirational job seekers and vocational workers with certified career pathways, verified opportunities, and human mentorship.

---

## 🚀 Live Demo & Mobile App Downloads

Reviewers and evaluators can immediately access and test the platform using the links below:

| Platform | Access Link | Description |
| :--- | :--- | :--- |
| 🌐 **Live Web Operations Portal** | [**👉 Open Web Admin Portal (Netlify)**](https://thrianaiadmin.netlify.app/) | Operations and program administration dashboard deployed live on Netlify with preloaded data and live speech capabilities. |
| 📱 **Android Mobile Application (APK)** | [**⬇️ Download Android Release APK (48.3 MB)**](https://github.com/ssukivarsan-prog/Thiran-AI/raw/main/release/app-release.apk) | Production release APK. Direct download and install on any Android 8.0+ device to test live voice input, onboarding, pathways, and mentorship. |
| 📂 **APK File in Repository** | [`release/app-release.apk`](release/app-release.apk) | Direct access to the release binary directly stored in this repository. |

---

## 🎯 Key Capabilities & Highlights

1. **Multilingual Voice-First Intelligence**:
   - Integrated live microphone speech recognition supporting **6 languages** (Tamil, English, Hindi, Telugu, Kannada, Malayalam).
   - High-accuracy voice transcription with automated fallback for low-connectivity rural settings.
   - Interactive voice onboarding and conversational profile discovery.

2. **Explainable Career Pathways & "Become Eligible" Guidance**:
   - Breaks aspirational careers down into clear, stepwise milestones (prerequisite skills, certifications, practical experience).
   - Dynamic match percentage scores with transparent explanation of eligibility gaps.

3. **Interactive "What-If" Career Simulator**:
   - Beneficiaries can simulate acquiring specific skills or certifications to immediately preview salary projections and newly unlocked job roles.

4. **Human Mentorship & 1-on-1 Guidance**:
   - Direct connection to verified local practitioners and domain mentors with structured booking and session logs.

5. **Omnichannel Operations & IVR Call Simulator**:
   - Integrated admin dashboard featuring omnichannel support (WhatsApp, Voice IVR telephony, and Web chat).
   - Web-based microphone voice recognition for simulated IVR call testing.

6. **Pre-Seeded & Resilient Demo Mode**:
   - Web and mobile platforms operate seamlessly both online with the backend API or in autonomous offline/demo fallback mode with realistic synthetic beneficiaries, accredited courses, opportunities, and mentors.

---

## 👥 Demo Test Personas & Login Credentials

Use the following pre-seeded test accounts to explore the mobile app and web portal:

| Role | Name / Persona | Phone Number | Demo Passcode | Primary Language |
| :--- | :--- | :--- | :--- | :--- |
| **Beneficiary (Solar)** | Arun Kumar | `+919840112301` | `123456` | Tamil (`ta`) |
| **Beneficiary (Tailoring)** | Meenakshi Sundaram | `+919840112302` | `123456` | Tamil (`ta`) |
| **Beneficiary (Agri-Drone)** | Suresh Mani | `+919840112303` | `123456` | Tamil (`ta`) |
| **Beneficiary (EV Battery)** | Praveen Chander | `+919840112305` | `123456` | Hindi (`hi`) |
| **Mentor (Solar Rooftop)** | Murugan Sundaram | `+919800000010` | `123456` | Tamil / English |
| **Operations Lead** | Program Director | `+919000000001` | Direct switch in Web UI | English (`en`) |
| **Field Support Worker** | Shalini Devi | `+919000000002` | Direct switch in Web UI | Tamil / English |

---

## 🏗️ Repository Architecture

```
Thiran-AI/
├── release/                        # Pre-built production binaries
│   └── app-release.apk             # Android Release APK (48.3 MB)
├── mobile_flutter/                 # Beneficiary Mobile Application (Android/iOS)
│   ├── lib/core/                   # Speech recognition, audio services, theme, localization
│   ├── lib/features/               # Voice onboarding, pathway stepper, simulator, mentor connect
│   └── test/                       # Unit & widget tests
├── web_flutter/                    # Operations & Administration Web Dashboard
│   ├── lib/core/                   # Web mock data, Web voice recognition, API client
│   ├── lib/views/                  # Beneficiary directory, courses, jobs, omnichannel comms
│   ├── web/                        # Web manifest, index.html, Netlify _redirects
│   └── test/                       # Web integration & smoke tests
├── backend/                        # Node.js / TypeScript REST API Gateway
│   ├── src/config/                 # Environment config & AI gateway settings
│   ├── src/database/               # Synthetic seed generator & in-memory data store
│   ├── src/modules/                # Auth, AI Gateway, WhatsApp & IVR webhooks
│   └── test/                       # Monorepo API test suite
├── shared_models/                  # Cross-platform JSON data contracts & schemas
├── docs/                           # Architecture specifications & user flow diagrams
├── scripts/                        # Automated startup & test runners (batch scripts)
└── package.json                    # Workspace orchestration
```

---

## 💻 Local Development Setup

### Prerequisites
- **Flutter SDK**: 3.41+ (Dart 3.11+)
- **Node.js**: v20+ or v24+
- **Google Chrome / Microsoft Edge** (for web development)

### 1. Run Complete Monorepo Test Suite
Validate all three workspace layers (backend, web, mobile) with a single command:
```cmd
scripts\test_all.bat
```

### 2. Run the Backend API Service (Port 4000)
```cmd
cd backend
npm install
npm run dev
```
- **Health Check**: `http://localhost:4000/health`
- **Database Readiness**: `http://localhost:4000/ready`

### 3. Run the Web Operations Portal (Port 3000)
```cmd
cd web_flutter
flutter pub get
flutter run -d chrome --web-port 3000
```
Or execute:
```cmd
scripts\start_web.bat
```

### 4. Run the Mobile Application (Android / iOS / Emulator)
```cmd
cd mobile_flutter
flutter pub get
flutter run
```
Or execute:
```cmd
scripts\start_mobile.bat
```

---

## 📱 How to Install the Release APK

1. On your Android phone, tap the [**Download Android APK**](https://github.com/ssukivarsan-prog/Thiran-AI/raw/main/release/app-release.apk) button or transfer `release/app-release.apk` to your phone.
2. Open the downloaded file.
3. If prompted by Android, enable **"Install from unknown sources"** for your browser or file manager.
4. Tap **Install** and launch **Thiran AI**.
5. Log in with any demo persona (e.g., `+919840112301`, OTP `123456`) or use the voice onboarding with your microphone!

---

## 🌐 Telephony & Omnichannel Webhook Specs

| Service | Route | Description |
| :--- | :--- | :--- |
| **WhatsApp Inbound** | `POST /api/webhooks/whatsapp` | Inbound WhatsApp text/audio message processing |
| **WhatsApp Verification** | `GET /api/webhooks/whatsapp` | Meta Graph API webhook subscription handshake |
| **IVR Call Start** | `POST /api/webhooks/ivr/call-start` | Telephony call session initialization & voice greeting |
| **IVR Voice / DTMF** | `POST /api/webhooks/ivr/input` | Handles spoken input recognition and keypad DTMF tones |
| **IVR Call Status** | `POST /api/webhooks/ivr/call-status` | Call completion and telemetry logging |

---

## 🔒 Security & Privacy

- Client applications do not expose backend API keys or LLM provider credentials.
- All speech recognition uses secure platform audio APIs with explicit user permission prompts.
- All API interactions use signed JWT authentication and role-based access control.

---

## 📄 License
This project is open-source under the [MIT License](LICENSE).
