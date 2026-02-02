# 📊 Smart Attendance Tracker

A privacy-focused, offline-first Flutter application for tracking and managing class attendance.

## ✨ Features

- **Firebase Authentication** - Secure login/signup with email and password
- **Local Data Storage** - Attendance data stored locally using Hive for offline access
- **Subject Management** - Create, edit, and delete subjects with custom icons
- **Attendance Tracking** - Mark classes as attended or missed
- **Visual Analytics** - Beautiful charts and progress bars showing attendance statistics
- **Smart Notifications** - Daily reminders (Mon-Fri) and weekly goal alerts (Saturday)
- **Goal Setting** - Set weekly and overall attendance goals per subject

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart) with Material Design 3
- **State Management**: Provider
- **Local Storage**: Hive
- **Authentication**: Firebase Auth
- **Charts**: FL Chart
- **Notifications**: Flutter Local Notifications

## 📱 Screens

1. **Splash Screen** - App launch with animation
2. **Login Screen** - User authentication
3. **Signup Screen** - New user registration
4. **Home Dashboard** - Subject list with overall stats
5. **Add/Edit Subject** - Subject management
6. **Subject Detail** - Detailed attendance view with charts
7. **Profile Screen** - User info and settings

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / Xcode
- Firebase account

### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android app:
   - Package name: `com.example.attendance`
   - Download `google-services.json`
   - Place it in `android/app/`
4. Add iOS app:
   - Bundle ID: `com.example.attendance`
   - Download `GoogleService-Info.plist`
   - Place it in `ios/Runner/`
5. Enable Authentication:
   - Go to Authentication > Sign-in method
   - Enable Email/Password

### Update Firebase Options

Edit `lib/firebase_options.dart` and replace placeholder values with your actual Firebase configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: 'YOUR_PROJECT_NUMBER',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);
```

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd attendance

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── subject.dart
│   ├── attendance_record.dart
│   └── models.dart
├── services/                 # Business logic services
│   ├── local_storage_service.dart
│   ├── auth_service.dart
│   ├── notification_service.dart
│   └── services.dart
├── providers/                # State management
│   ├── auth_provider.dart
│   ├── attendance_provider.dart
│   └── providers.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── add_edit_subject_screen.dart
│   ├── subject_detail_screen.dart
│   ├── profile_screen.dart
│   └── screens.dart
├── widgets/                  # Reusable widgets
│   ├── common_widgets.dart
│   └── widgets.dart
└── utils/                    # Utilities and constants
    ├── theme.dart
    └── utils.dart
```

## 🔔 Notifications

The app schedules the following notifications:

- **Daily Reminders** (Monday-Friday at 8:00 AM):
  > "Don't forget to attend your classes today!"

- **Weekly Review** (Saturday at 9:00 AM):
  > "Check if you met your attendance goals this week!"

## 🎨 Customization

### Theme Colors

Edit `lib/utils/theme.dart` to customize colors:

```dart
static const Color primaryColor = Color(0xFF6C63FF);
static const Color successColor = Color(0xFF00B894);
static const Color warningColor = Color(0xFFFDAA5F);
static const Color errorColor = Color(0xFFE17055);
```

### Subject Icons

Add or modify icons in `SubjectIcons.icons` list in `lib/utils/theme.dart`.

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
