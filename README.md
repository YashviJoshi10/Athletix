# Don't forget to start our repository

# Athletix

Athletix is a Flutter-based mobile application designed to streamline collaboration between athletes, coaches, doctors, and sports organizations. It offers a centralized platform to manage tournaments, track performance and injuries, maintain schedules, and facilitate communication while respecting user roles.

## 🚀 Features

### 🔐 Authentication & Role-based Access
- **Firebase Authentication**: Secure login for all users.
- **Role-based Access (RBA)**:
  - Four user roles: **Athletes**, **Doctors**, **Coaches**, and **Organizations**.
  - Each role has a distinct dashboard with specific permissions.
  - Role checked via Firestore `role` field, redirecting users to their respective dashboards post-login.
- **Signup & Login**:
  - Separate signup and login flows for Athletes, Doctors, and Coaches.
  - Login-only access for Organizations.

### 📋 Profiles
- **Athletes**: Includes personal details and their sport.
- **Doctors**: Includes personal details and specialization.
- **Coaches**: Includes their sport.
- **Organizations**: Associated with a specific sport.

### 🗓️ Timetable & Notifications
- Users can create and save activity timetables in Firestore.
- Push notifications sent via **Firebase Cloud Messaging (FCM)** at the start of each activity.

### 📈 Injury & Performance Logs
- **Athletes** can log:
  - **Injury logs**: Details for doctors and monitoring.
  - **Performance logs**: Track progress over time.
- Logs stored securely in **Firestore** and accessible to doctors and coaches for review.

### 🗺️ Tournaments with Google Maps
- **Organizations** can create tournaments with:
  - Name, level (District, State, National, International), date, time, and location (via **Google Maps SDK**).
  - Data stored in Firestore under the `tournaments` collection.
- **Athletes** can:
  - View upcoming tournaments filtered by their sport.
  - See tournaments as markers on an interactive map.
  - Tap markers to view tournament details (level, date, time, address) in a modal.

## 📚 Tech Stack
- **Flutter**: Cross-platform UI framework for iOS and Android.
- **Firebase**:
  - **Authentication**: User login and signup.
  - **Firestore**: Database for profiles, timetables, logs, and tournaments.
  - **Cloud Messaging**: Push notifications for activity reminders.
- **Google Maps SDK**: Interactive maps and location picking for tournaments.

## 📜 License
- This project is licensed under the MIT License. See the LICENSE file for details.