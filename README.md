# 🔍 FaceSeek

> A Flutter app that detects faces in photos and performs a reverse image search to find where those images appear on the web.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-in--progress-orange)
![Build In Public](https://img.shields.io/badge/build--in--public-100--day--streak-purple)

---

## ⚠️ Ethical Use & Legal Disclaimer

**Please read before using or contributing.**

This project is built **strictly for educational and personal use**. By using this software, you agree to the following:

- ✅ You may use this app to search for **your own face/images**
- ✅ You may use this app for **research, academic, or journalistic purposes** with proper consent
- ✅ You may search for **publicly available images** that you own the rights to
- ❌ You may **NOT** use this app to identify, track, or surveil individuals without their **explicit consent**
- ❌ You may **NOT** use this app to harass, stalk, doxx, or harm any person
- ❌ You may **NOT** use this app in any way that violates applicable laws including but not limited to GDPR (EU), CCPA (California), PDPA, or any local privacy legislation in your jurisdiction

> This tool does **not** store, collect, or transmit any biometric data. All face detection is performed **on-device** using Google ML Kit. Reverse image search is powered by third-party APIs and is subject to their respective terms of service.

The developer(s) of this project **bear no responsibility** for misuse of this software. Any use that violates the above terms is solely the responsibility of the end user.

---

## 🧠 How It Works

1. User uploads or captures a photo
2. On-device ML Kit detects and crops the face region
3. The cropped face image is sent to a reverse image search API
4. Results (URLs, thumbnails, source domains) are displayed in-app

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile Framework | Flutter 3.x |
| Face Detection | Google ML Kit (on-device) |
| Reverse Image Search | SerpAPI |
| State Management | Riverpod |
| Storage | Hive (local only) |

---

## 📅 Roadmap (100-Day Build in Public)

- [x] Day 1 — Project setup, basic UI scaffold
- [ ] Day 2 — Camera integration
- [ ] Day 3 — Gallery picker
- [ ] Day 4-7 — ML Kit face detection
- [ ] Day 8-12 — Face crop & preview
- [ ] Day 13-20 — SerpAPI integration
- [ ] Day 21-30 — Results display & history
- [ ] Day 31-50 — Polish & edge cases
- [ ] Day 51-75 — UI/UX improvements
- [ ] Day 76-100 — Beta, launch, stores


## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- A [SerpAPI](https://serpapi.com) key (free tier available)

### Installation

```bash
git clone https://github.com/Parzival235/faceseek.git
cd faceseek
flutter pub get
```

### Configuration

Create a `.env` file in the root:

```env
SERP_API_KEY=your_api_key_here
```

> ⚠️ Never commit your `.env` file. It is already added to `.gitignore`.

### Run

```bash
flutter run
```

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) and make sure your changes comply with the ethical use policy above.

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

## 👤 Author

Built in public, one day at a time.

