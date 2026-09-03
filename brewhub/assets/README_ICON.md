Place a coffee-themed PNG at `assets/icon.png` (recommended 1024×1024 PNG, transparent background).

Then in the `brewhub` project root run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

This will generate Android and iOS app icons from the provided image.

If you prefer to replace icons manually, copy your PNG into the iOS AppIcon.appiconset and Android mipmap folders, matching sizes in iOS `Contents.json` and Android `mipmap-*/ic_launcher.png` files.