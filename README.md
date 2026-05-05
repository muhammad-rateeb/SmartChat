# SmartChat 🚀

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) 
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Gemini AI](https://img.shields.io/badge/Gemini_AI-4F86F7?style=for-the-badge&logo=google&logoColor=white)

**SmartChat** is a cross-platform chat application built with Flutter, heavily focused on integrating real-time messaging with artificial intelligence.

## ✨ Features

- **User Authentication:** Secure Sign Up, Log In, and Google Sign-in integrated directly with Firebase Authentication.
- **Real-Time Chat:** Live chat features powered by Firebase Cloud Firestore.
- **AI Assistant:** Direct integration with Google Gemini AI. Chat with an intelligent assistant to answer questions, brainstorm, or just chat!
- **Sleek UI/UX:** A modern, beautiful, and responsive interface matching the best design patterns in mobile apps.
- **Cross-Platform:** Runs flawlessly on Android, iOS, and the Web.
- **State Management:** Fully optimized data flows using Riverpod.

## 🛠️ Tech Stack

- **Framework:** Flutter / Dart
- **Backend:** Firebase (Auth, Firestore)
- **AI API:** Google Generative AI (Gemini v1.beta)
- **State Management:** Riverpod

## 🚀 Getting Started

### Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Add Firebase to your Flutter app (`firebase_core`, `firebase_auth`, `cloud_firestore`)

### Setup Instructions
1. **Clone the repository:**
   ```bash
   git clone https://github.com/muhammad-rateeb/SmartChat.git
   cd SmartChat
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Connect to Firebase:**
   Ensure `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) are located in their respective folders.

4. **Run the App:**
   ```bash
   flutter run
   ```
