import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class CurrencyUtils {
  static String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  static String formatCurrencyShort(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}

class ValidationUtils {
  static String? validateEmail(String? email) {
    if (email?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email!)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password?.isEmpty ?? true) {
      return 'Password is required';
    }
    if (password!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? name) {
    if (name?.isEmpty ?? true) {
      return 'Name is required';
    }
    if (name!.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? phone) {
    if (phone?.isEmpty ?? true) {
      return 'Phone number is required';
    }
    if (phone!.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}

class AppConstants {
  static const String appName = 'BrewHub';
  static const String appVersion = '1.0.0';

  // Order statuses
  static const List<String> orderStatuses = [
    'Pending',
    'Preparing',
    'Ready',
    'Delivered',
  ];

  // Default values
  static const double defaultTax = 0.0;
  static const double deliveryFee = 0.0;

  // Category placeholder images
  static const Map<String, String> categoryIcons = {
    'Coffee': '☕',
    'Tea': '🍵',
    'Desserts': '🍰',
    'Snacks': '🥐',
  };
}
