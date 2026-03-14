<div align="center">
  <img src="assets/images/logo2.png" alt="FuelSplit Logo" width="150"/>
  <h1>FuelSplit</h1>
  <p>A smart and elegant Flutter application to track trips, manage passengers, and split fuel costs calculation easily and transparently.</p>
</div>

---

## 🚀 Features

* **Trip Tracking:** Easily log trips with start and end locations (via Google Maps), distance calculation, and trip dates.
* **Passenger Management:** Add passengers quickly by importing them directly from your device contacts.
* **Fair Cost Splitting:** Automatically calculate and distribute fuel expenses, tolls, and other costs among passengers.
* **Interactive Dashboard:** Gain insights into your trips and expenses through beautiful, animated charts and statistics.
* **Smart Reminders:** Send one-click payment messages/debts to passengers via WhatsApp or SMS.
* **Data Export:** Generate and share CSV reports of your trip logs seamlessly.
* **Authentication:** Secure sign-in with Email & Password or Google Sign-In via Firebase Auth.
* **Polished UI/UX:** Enjoy smooth micro-animations, empty state graphics, and beautiful dark & light themes.

## 🛠️ Tech Stack & Dependencies

* **Framework:** Flutter (>= 3.8.1)
* **State Management:** Riverpod (`flutter_riverpod`)
* **Routing:** GoRouter (`go_router`)
* **Backend:** Firebase (Authentication, Firestore, Google Sign-in)
* **Local Storage:** Drift & SQLite (`drift`, `sqlite3_flutter_libs`)
* **Location & Maps:** Google Maps Flutter, Geolocator, Geocoding
* **UI Utilities:** FL Chart, Flutter Animate, Google Fonts, Cupertino Icons
* **Device APIs:** Flutter Contacts, Permission Handler, URL Launcher, Share Plus

## 📁 Project Structure

This project follows a feature-centric (feature-driven) folder structure, ensuring high modularity and maintainability:

```text
lib/
├── core/
│   ├── router/          # GoRouter configurations and routes
│   ├── theme/           # App themes, colors (Light/Dark mode)
│   └── utils/           # Shared helpers (URL launcher, Firebase utils, Contact helpers)
└── features/
    ├── auth/            # Authentication (Sign In, Register, Google Sign-In)
    ├── dashboard/       # Charts, expense statistics, user dashboard
    ├── home/            # Main navigation shell, bottom app bar
    ├── passengers/      # Passenger management, contact import
    ├── payments/        # Debt collection, payment statuses
    └── trips/           # Trip logs, map integrations, detail screens
```

## ⚙️ Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
* Supported IDEs (VS Code, Android Studio, IntelliJ IDEA) with Flutter extensions.
* A configured Firebase project.

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd fuel_split
   ```

2. **Install Flutter Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Since this project uses Firebase Authentication and Firestore, you'll need to set up Firebase via the Firebase CLI or manually by placing the configuration files:
   - **Android:** Place your `google-services.json` in `android/app/`.
   - **iOS:** Place your `GoogleService-Info.plist` in `ios/Runner/`.

   *(Optional: If you use `flutterfire_cli`, run `flutterfire configure` at the project root)*

4. **Code Generation:**
   This app uses `drift` and `freezed` which rely on code generation. Generate the necessary files safely by running:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the Application:**
   Start your emulator or plug in your physical device, then run:
   ```bash
   flutter run
   ```

## 📸 Screenshots (Placeholders)

> *(You can add real screenshots of your application here to showcase its design and features!)*

* `Dashboard screen showing expense distribution charts.`
* `Trip detail screen with smoothly animated transitions.`
* `Passenger import UI connecting seamlessly with device contacts.`

## 🛡️ License

This project is licensed under the MIT License - see the LICENSE file for details.
