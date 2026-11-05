# Experiment 8: Employee Search (Firestore)

Search employees in Firestore by different fields.

## Features
- Search by Name, Employee ID or Department (segmented selector)
- Results shown with employee ID chips
- Reads from the `employees` collection

## Tech stack
Flutter, firebase_core, cloud_firestore

## Firebase setup (required before first run)
This experiment uses **Cloud Firestore**. `lib/firebase_options.dart` is generated for your own Firebase project and is intentionally not committed.

1. Create a project in the [Firebase console](https://console.firebase.google.com) and enable **Firestore Database** (test mode).
2. Install the CLI once: `dart pub global activate flutterfire_cli`
3. From this folder run `flutterfire configure`, pick your project and the Android platform. This creates `lib/firebase_options.dart`.

## Run
1. Open this folder in VS Code (**File > Open Folder**).
2. In a terminal run `flutter pub get`.
3. Pick a device (Android phone, emulator or Chrome) from the bottom-right corner.
4. Press **F5** or run `flutter run`.

[← Back to all experiments](../README.md)
