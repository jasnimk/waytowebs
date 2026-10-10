import 'package:flutter/foundation.dart';

class AppConfig {
  // App Info
  static const String appName = 'Way to Webs';
  static const String appVersion = '1.0.0';

  // Environment
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;

  // API Base URL (if using custom API - otherwise Supabase handles this)
  static const String apiBaseUrl = 'https://api.example.com'; // Change as needed

  // Supabase Configuration
  static const String supabaseUrl = 'https://magbrndpqvtmcubxxwhq.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hZ2JybmRwcXZ0bWN1Ynh4d2hxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE1MTI0MDEsImV4cCI6MjEwNzA4ODQwMX0.bLF35JaJtweXOQ5_pYOIcR-ICR2nn2ZdejwNMbErXVo';

  // Payment Gateway
  static const String razorpayKey = 'YOUR_RAZORPAY_KEY';

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);

  // Cache
  static const Duration cacheExpiry = Duration(hours: 24);

  // OTP
  static const int otpLength = 6;
  static const Duration otpTimeout = Duration(seconds: 60);
  static const int otpResendDelay = 30; // seconds

  // Image
  static const int maxImageSizeInMB = 5;
  static const int imageQuality = 80;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
}
