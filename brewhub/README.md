# BrewHub Café App

A complete Flutter application for managing a café ordering system with customer and admin features.

## Features

### Customer Features
- **User Authentication**: Register and login with email/password
- **Browse Menu**: View all available products by category
- **Product Details**: See detailed information about each product
- **Shopping Cart**: Add, remove, and manage items in cart
- **Checkout**: Place orders with special instructions
- **Order Tracking**: Real-time order status updates
- **Profile Management**: Update personal information and view order history

### Admin Features
- **Admin Dashboard**: Overview of orders and products
- **Menu Management**: Add, edit, and delete menu items
- **Order Management**: View and update order statuses
- **Real-time Updates**: Instant notifications of new orders

## Firebase Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a new project"
3. Enter "brewhub-cafe-app" as project name
4. Accept the terms and create the project

### Step 2: Enable Authentication
1. In Firebase Console, go to Authentication
2. Click "Get started"
3. Enable "Email/Password" authentication method

### Step 3: Create Firestore Database
1. Go to Firestore Database in Firebase Console
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select your preferred region

### Step 4: Update Firebase Configuration

1. Go to Project Settings in Firebase Console
2. Scroll down and find your app configuration
3. Copy your Firebase credentials
4. Update `lib/firebase_options.dart` with your configuration

## Installation

### Prerequisites
- Flutter SDK: v3.11.3 or higher
- Firebase project created

### Steps

1. **Navigate to project**
   ```bash
   cd brewhub
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update Firebase configuration**
   - Edit `lib/firebase_options.dart` with your Firebase credentials

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── admin/ - Admin dashboard and management screens
├── constants/ - App theme and styling
├── models/ - Data models for users, products, orders
├── screens/ - UI screens for customer
├── services/ - Firebase and business logic
├── utils/ - Utility functions
├── widgets/ - Reusable UI components
├── main.dart - App entry point
└── firebase_options.dart - Firebase configuration
```

## Usage

### Customer Workflow
1. Register/Login as customer
2. Browse menu by category
3. Add items to cart
4. Checkout and place order
5. Track order in real-time

### Admin Workflow
1. Login as admin
2. Manage menu (add/edit/delete products)
3. View and process orders
4. Update order statuses

## Dependencies

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
firebase_storage: ^12.3.3
provider: ^6.1.2
google_fonts: ^6.2.1
image_picker: ^1.1.2
fluttertoast: ^8.2.8
intl: ^0.19.0
```

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please create an issue in the repository.

---

**BrewHub** - Your coffee shop companion ☕
