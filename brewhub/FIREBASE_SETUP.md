## BrewHub Firebase Setup Guide

This guide will help you set up Firebase for the BrewHub Café App.

### Prerequisites
- Firebase account (free tier available)
- Flutter project (already created)
- Basic knowledge of Firebase Console

---

## Step 1: Create Firebase Project

1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"** or **"Add project"**
3. Enter project name: `brewhub-cafe-app`
4. Accept the terms and click **"Create project"**
5. Wait for project creation (usually 1-2 minutes)

---

## Step 2: Register Your App

### Android App

1. In Firebase Console, click **"Add app"**
2. Select **"Android"**
3. Register app with package name: `com.example.brewhub`
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

### iOS App (Optional)

1. Click **"Add app"**
2. Select **"iOS"**
3. Register with bundle ID: `com.example.brewhub`
4. Download `GoogleService-Info.plist`
5. Add to Xcode project (if building for iOS)

---

## Step 3: Enable Authentication

1. In Firebase Console, go to **"Authentication"**
2. Click **"Get started"**
3. Click **"Email/Password"**
4. Toggle **"Enable"** button
5. Click **"Save"**

---

## Step 4: Create Firestore Database

1. In Firebase Console, go to **"Firestore Database"**
2. Click **"Create database"**
3. Select **"Start in test mode"** (for development)
   - ⚠️ **Note**: Test mode allows read/write for everyone. Use security rules for production.
4. Click **"Next"**
5. Select your preferred region (e.g., Asia Southeast 1)
6. Click **"Enable"**
7. Wait for database creation

---

## Step 5: Create Firestore Collections

After Firestore is created, create the following collections:

### Collection 1: Users

1. Click **"Create collection"**
2. Name: `users`
3. Click **"Next"**
4. Create a test document with ID: `test-user-id`

**Document Structure:**
```json
{
  "uid": "test-user-id",
  "name": "Test User",
  "email": "test@example.com",
  "role": "customer",
  "phone": "9876543210",
  "address": "123 Main St",
  "createdAt": "timestamp"
}
```

### Collection 2: Products

1. Click **"Create collection"** in root
2. Name: `products`
3. Click **"Next"**
4. Create a test document with ID: `coffee-1`

**Document Structure:**
```json
{
  "name": "Cappuccino",
  "price": 120,
  "category": "Coffee",
  "description": "Delicious cappuccino with perfect foam",
  "imageUrl": "https://example.com/cappuccino.jpg",
  "rating": 4.5,
  "reviewCount": 25,
  "available": true,
  "createdAt": "timestamp"
}
```

### Collection 3: Orders

1. Click **"Create collection"** in root
2. Name: `orders`
3. Click **"Next"**
4. Create a test document with ID: `order-1`

**Document Structure:**
```json
{
  "userId": "test-user-id",
  "items": [
    {
      "productId": "coffee-1",
      "productName": "Cappuccino",
      "price": 120,
      "quantity": 2
    }
  ],
  "total": 240,
  "status": "Pending",
  "createdAt": "timestamp",
  "deliveredAt": null,
  "specialNotes": "Extra hot, no sugar"
}
```

---

## Step 6: Get Firebase Configuration

1. Go to **Project Settings** (⚙️ icon)
2. In **"Your apps"** section, find Android app
3. Copy the following values:

```
API Key: [Your API Key]
App ID: 1:[Project Number]:android:[App ID]
Messaging Sender ID: [Your Sender ID]
Project ID: brewhub-cafe-app
Storage Bucket: brewhub-cafe-app.appspot.com
```

---

## Step 7: Update Firebase Options

Update `lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_HERE',
  appId: '1:YOUR_PROJECT_NUMBER:android:YOUR_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'brewhub-cafe-app',
  storageBucket: 'brewhub-cafe-app.appspot.com',
);
```

Replace placeholders with your actual Firebase credentials.

---

## Step 8: Update Flutter Dependencies

Run these commands:

```bash
flutter pub get
flutter pub upgrade
```

---

## Step 9: Create Test Accounts

### Create Customer Account

1. In Firebase Console, go to **Authentication**
2. Click **"Users"** tab
3. Click **"Create user"**
4. Enter:
   - Email: `customer@example.com`
   - Password: `password123`
5. Click **"Create"**

### Create Admin Account

1. Repeat above steps
2. Enter:
   - Email: `admin@example.com`
   - Password: `password123`
3. Click **"Create"**

### Add User Data to Firestore

For each user, create a document in the `users` collection:

**For Customer:**
- Document ID: [Copy UID from Firebase Auth]
```json
{
  "uid": "customer-uid",
  "name": "Test Customer",
  "email": "customer@example.com",
  "role": "customer",
  "phone": "9876543210",
  "address": "123 Main St, City",
  "createdAt": "2024-01-01T10:00:00Z"
}
```

**For Admin:**
- Document ID: [Copy UID from Firebase Auth]
```json
{
  "uid": "admin-uid",
  "name": "Admin User",
  "email": "admin@example.com",
  "role": "admin",
  "phone": "9876543211",
  "address": "456 Admin St, City",
  "createdAt": "2024-01-01T10:00:00Z"
}
```

---

## Step 10: Add Sample Products

In Firestore, create documents in the `products` collection:

### Coffee Collection
```json
{
  "name": "Cappuccino",
  "price": 120,
  "category": "Coffee",
  "description": "Espresso with steamed milk and foam",
  "imageUrl": "",
  "rating": 4.5,
  "reviewCount": 50,
  "available": true,
  "createdAt": "2024-01-01T10:00:00Z"
}
```

```json
{
  "name": "Americano",
  "price": 100,
  "category": "Coffee",
  "description": "Espresso diluted with hot water",
  "imageUrl": "",
  "rating": 4.2,
  "reviewCount": 35,
  "available": true,
  "createdAt": "2024-01-01T10:00:00Z"
}
```

```json
{
  "name": "Latte",
  "price": 130,
  "category": "Coffee",
  "description": "Espresso with lots of steamed milk",
  "imageUrl": "",
  "rating": 4.7,
  "reviewCount": 65,
  "available": true,
  "createdAt": "2024-01-01T10:00:00Z"
}
```

### Desserts Collection
```json
{
  "name": "Brownie",
  "price": 80,
  "category": "Desserts",
  "description": "Delicious chocolate brownie",
  "imageUrl": "",
  "rating": 4.6,
  "reviewCount": 45,
  "available": true,
  "createdAt": "2024-01-01T10:00:00Z"
}
```

```json
{
  "name": "Cheesecake",
  "price": 120,
  "category": "Desserts",
  "description": "Creamy New York style cheesecake",
  "imageUrl": "",
  "rating": 4.8,
  "reviewCount": 72,
  "available": true,
  "createdAt": "2024-01-01T10:00:00Z"
}
```

---

## Step 11: Run the App

```bash
flutter run
```

---

## Firestore Security Rules (For Production)

Replace test mode rules with these security rules:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId || request.auth.uid != null;
    }
    
    // Products collection - anyone can read
    match /products/{document=**} {
      allow read: if true;
      allow write: if request.auth.token.role == 'admin';
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read, write: if request.auth.uid == resource.data.userId || request.auth.token.role == 'admin';
      allow create: if request.auth.uid != null;
    }
  }
}
```

---

## Troubleshooting

### App Won't Connect to Firebase
- ✓ Verify `google-services.json` is in `android/app/`
- ✓ Check Firebase credentials in `firebase_options.dart`
- ✓ Run `flutter clean` and `flutter pub get`
- ✓ Restart app

### Authentication Fails
- ✓ Verify email/password in Firebase Console
- ✓ Check user role in Firestore `users` collection
- ✓ Ensure test mode is enabled or rules allow access

### Can't Create/Update Orders
- ✓ Check `orders` collection exists in Firestore
- ✓ Verify document structure matches model
- ✓ Check Firestore permissions (test mode should allow all)

### Products Not Showing
- ✓ Add sample products to Firestore
- ✓ Check `products` collection exists
- ✓ Verify product field names match `ProductModel`

---

## Next Steps

1. ✓ Customize `firebase_options.dart` with your credentials
2. ✓ Add more products via admin panel
3. ✓ Test customer and admin workflows
4. ✓ Deploy to production when ready

---

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Setup](https://firebase.flutter.dev/)
- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

**Happy Building! ☕**
