# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Razorpay
-keepclassmembers class com.razorpay.** { *; }
-keep class com.razorpay.** { *; }
-optimizations !method/inlining/*
-keepattributes *Annotation*
-keepattributes Signature

# Google Sign-In
-keep class com.google.android.gms.** { *; }

# OkHttp (used by Dio on Android)
-dontwarn okhttp3.**
-dontwarn okio.**
