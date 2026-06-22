# BrewHub Admin — Mobile-friendly Quick Guide

Short, scannable instructions for developers testing the admin app on mobile devices.

## What this is
- Admin Flutter app for BrewHub.
- Use to manage data, view analytics, and control backend settings.

## Quick requirements
- Flutter SDK (stable channel)
- Dart SDK
- Android SDK / Xcode (for device builds)
- Firebase project (if using Firebase services)

## Quick start
1. Open a terminal and go to the admin folder:

```bash
cd admin
flutter pub get
```

2. Run on an Android device/emulator:

```bash
flutter run -d android
```

3. Run on an iOS device/simulator:

```bash
flutter run -d ios
```

4. Run on Chrome (web):

```bash
flutter run -d chrome
```

## Useful commands
- Analyze: `flutter analyze`
- Run tests: `flutter test`
- Build APK: `flutter build apk`
- Build iOS: `flutter build ios`

## Mobile testing tips
- Use `--device-id` to target specific devices.
- Run with `--release` for performance testing: `flutter run --release`.
- Use `flutter attach` to connect to already-running apps for hot reload.

## Project layout (short)
- `lib/` — app code
- `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` — platform files
- `test/` — unit & widget tests
- `firebase_options.dart` — generated Firebase config

## Firebase / secrets
- Keep `google-services.json` and `GoogleService-Info.plist` in platform folders.
- Do NOT commit service account keys or other secrets.

## Troubleshooting
- If dependencies fail: remove `pubspec.lock` and run `flutter pub get`.
- If platform build fails: run `flutter doctor -v` and follow suggestions.

## Contact
If you need help adapting features for mobile screens or testing flows, ask here or open an issue.
