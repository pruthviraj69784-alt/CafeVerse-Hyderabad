# brewhub_admin

A Flutter admin application for the BrewHub system.

## Project Purpose

This repository contains the admin version of BrewHub. It is intended for administrators to manage app data, review analytics, and control backend settings.

## Getting Started

### Prerequisites

- Flutter SDK installed
- Dart SDK installed
- Android Studio or Xcode for platform support
- A configured Firebase project if the app uses Firebase services

### Install dependencies

```bash
cd admin
flutter pub get
```

### Run the app

For Android:

```bash
flutter run -d android
```

For iOS:

```bash
flutter run -d ios
```

For web:

```bash
flutter run -d chrome
```

### Common commands

```bash
flutter analyze
flutter test
flutter build apk
flutter build ios
```

## Project Structure

- `lib/` - application source code
- `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/` - platform-specific files
- `test/` - widget and unit tests
- `build/` - generated build artifacts
- `firebase_options.dart` - Firebase configuration file

## Notes

- Keep `google-services.json` and `GoogleService-Info.plist` updated in the Android and iOS app folders.
- Use the `analysis_options.yaml` file to keep linting and style rules consistent.

## Additional Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
