# Flutter Lab Experiments

A collection of 10 Flutter experiments, progressing from basic UI layouts to local SQLite storage and Cloud Firestore apps.

## Experiments

| # | Experiment | What it does | Tech |
|---|------------|--------------|------|
| 1 | [Fruit Basket](exp1_fruit_basket/) | A basic Flutter UI: a fruit basket screen built from core Material widgets and layouts. | Flutter (Material 3) |
| 2 | [ShopEase Product Catalog](exp2_product_catalog/) | A shopping-style product catalog grouped by category. | Flutter (Material 3) |
| 3 | [Product Finder](exp3_product_finder/) | Search and filter a product list in real time. | Flutter (Material 3) |
| 4 | [Car Mileage Calculator](exp4_mileage_calculator/) | Calculates a car's fuel efficiency from distance and fuel used. | Flutter (Material 3) |
| 5 | [Personal Budget Calculator](exp5_budget_calculator/) | Track monthly income against expenses with a live budget status. | Flutter, provider |
| 6 | [Student Records (SQLite)](exp6_sqlite_students/) | Local CRUD app storing student records in an on-device SQLite database. | Flutter, sqflite, path |
| 7 | [Employee Directory (Firestore)](exp7_firestore_employees/) | Create and list employee records stored in Cloud Firestore. | Flutter, firebase_core, cloud_firestore |
| 8 | [Employee Search (Firestore)](exp8_firestore_search/) | Search employees in Firestore by different fields. | Flutter, firebase_core, cloud_firestore |
| 9 | [Update Employee Record (Firestore)](exp9_firestore_update/) | Fetch an employee by ID and update their details in Firestore. | Flutter, firebase_core, cloud_firestore |
| 10 | [Login & Registration (Firestore)](exp10_firestore_login/) | A register/login flow backed by Firestore with hashed passwords. | Flutter, firebase_core, cloud_firestore, crypto |

## Running an experiment
Each folder is a standalone Flutter project.

```bash
cd exp1_fruit_basket     # any experiment folder
flutter pub get
flutter run
```

Experiments **7 to 10** use Cloud Firestore and need a one-time `flutterfire configure` (see each experiment's README). Firebase config files are not committed.

## Requirements
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3+)
- VS Code or Android Studio with the Flutter extension
- An Android device, emulator or Chrome
