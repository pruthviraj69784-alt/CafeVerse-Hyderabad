## BrewHub Quick Start Guide

Get started with BrewHub in 5 minutes! ☕

### 1️⃣ Prerequisites

- Flutter 3.11.3+ installed
- Firebase account (free tier)
- Android/iOS device or emulator

### 2️⃣ Firebase Setup (2 minutes)

```bash
# Visit Firebase Console: https://console.firebase.google.com

# Step 1: Create project "brewhub-cafe-app"
# Step 2: Enable Email/Password authentication
# Step 3: Create Firestore database (test mode)
# Step 4: Download google-services.json
# Step 5: Place it in android/app/
```

### 3️⃣ Update Configuration (1 minute)

Edit `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'brewhub-cafe-app',
  storageBucket: 'brewhub-cafe-app.appspot.com',
);
```

### 4️⃣ Install & Run (1 minute)

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 5️⃣ Create Test Account (1 minute)

**Via Firebase Console:**
1. Go to Authentication → Users
2. Create user: `customer@example.com` / `password123`
3. Go to Firestore → users collection
4. Add document with UID from step 2:

```json
{
  "uid": "copy-from-firebase",
  "name": "Test Customer",
  "email": "customer@example.com",
  "role": "customer",
  "phone": "9876543210",
  "address": "123 Main St",
  "createdAt": "2024-01-01T10:00:00Z"
}
```

---

## 🎯 Quick Test

### Customer Test
1. Open app → "Continue as Customer"
2. Login: `customer@example.com` / `password123`
3. Browse Menu → Add to Cart → Checkout → Place Order
4. Go to Orders tab to track

### Admin Test
1. Open app → "Continue as Admin"
2. Login: `admin@example.com` / `password123`
3. Visit Dashboard to add products
4. View incoming orders

---

## 📚 Documentation

- **Setup Guide**: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- **Features**: [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md)
- **Main README**: [README.md](README.md)

---

## 🚀 What's Included

### Screens (12)
- Splash, Login, Register, Home
- Menu, Product Details
- Cart, Checkout
- Order Tracking, Profile
- Admin Dashboard, Orders Management

### Features
- ✅ Email/Password Authentication
- ✅ Shopping Cart
- ✅ Order Management
- ✅ Real-time Order Tracking
- ✅ Admin Menu Management
- ✅ User Profiles
- ✅ Order History

### Tech Stack
- Flutter 3.11.3
- Firebase (Auth + Firestore)
- Provider (State Management)
- Material Design 3

---

## 🆘 Troubleshooting

**App crashes on startup?**
```bash
flutter clean
flutter pub get
flutter run
```

**Firebase connection fails?**
- Check internet connection
- Verify Firebase credentials in `firebase_options.dart`
- Ensure `google-services.json` is in `android/app/`

**Products not showing?**
- Add products via Admin panel
- Check Firestore database in Firebase Console

**Can't login?**
- Create user in Firebase Auth Console
- Add user document in Firestore

---

## 💡 Pro Tips

1. Use test mode for Firebase while developing
2. Create multiple test users with different roles
3. Use Firestore emulator for local testing
4. Enable analytics in Firebase for insights

---

## 📞 Need Help?

1. Check [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed setup
2. Review [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md) for features
3. Check error messages in console
4. Verify Firebase configuration

---

**Happy Brewing! ☕**

Next: Read [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed Firebase configuration.
