# Naqeshi Flutter App — Setup Guide

## Prerequisites
1. Install Flutter SDK (≥ 3.19): https://docs.flutter.dev/get-started/install/windows
2. Install Android Studio (for Android emulator + SDK)
3. Install Xcode (macOS only, for iOS)

## Step 1 — Scaffold the platform directories

Run this once inside the `naqsheiapp/` directory. It generates `android/`, `ios/`,
`test/`, and the boilerplate Dart files (which you'll discard since `lib/` is already written):

```bash
cd D:/Projects/naqsheiapp
flutter create . --org com.naqeshi --project-name naqeshi_app
```

This will **not** overwrite `pubspec.yaml` or `lib/` because they already exist.
If it prompts to overwrite, choose **No** for those files.

## Step 2 — Replace AndroidManifest.xml

Replace `android/app/src/main/AndroidManifest.xml` with the one at
`android/app/src/main/AndroidManifest.xml` in this repo (see below — already written).

## Step 3 — Update android/app/build.gradle

Find the `defaultConfig` block and set:
```gradle
minSdk = 21
targetSdk = 34
```

Also ensure the `compileSdk` is at least 34.

## Step 4 — iOS Info.plist additions

Add the following keys inside `ios/Runner/Info.plist` (before the closing `</dict>`):
See the pre-written `ios/Runner/Info.plist.additions` file in this repo.

## Step 5 — Google Sign-In setup

### Android
1. Go to https://console.cloud.google.com → APIs & Services → Credentials
2. Create an OAuth 2.0 Client ID for Android:
   - Package name: `com.naqeshi.app`
   - SHA-1: run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
3. Download `google-services.json` → place at `android/app/google-services.json`
4. In `android/build.gradle` add to `dependencies`:
   ```gradle
   classpath 'com.google.gms:google-services:4.4.0'
   ```
5. At the bottom of `android/app/build.gradle` add:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### iOS
1. Create an OAuth 2.0 Client ID for iOS in the same Google Console project:
   - Bundle ID: `com.naqeshi.app`
2. Download `GoogleService-Info.plist` → drag into Xcode under `Runner/`
3. In `ios/Runner/Info.plist`, add a `CFBundleURLTypes` entry with your reversed client ID
   (e.g. `com.googleusercontent.apps.YOUR_CLIENT_ID`)

## Step 6 — Environment / secrets

The backend reads `MOBILE_JWT_SECRET` from the server's `.env`.
Make sure it's set on Vercel:
```
MOBILE_JWT_SECRET=<generate with: openssl rand -base64 48>
```

The Flutter app only needs the Razorpay **key ID** (not the secret).
It's returned by the `/api/mobile/checkout` endpoint at runtime — no hardcoding needed.

## Step 7 — Install Flutter packages

```bash
flutter pub get
```

## Step 8 — Run

```bash
# Android emulator
flutter run

# Release APK
flutter build apk --release

# Release AAB (for Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```
