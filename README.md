# 🏅 Athletix - Athlete Management System

## 📌 Introduction
**Athletix** is an innovative, scalable, and user-friendly **Athlete Management System** designed to revolutionize athlete management in the Indian sporting industry. The app provides a centralized platform for athletes, coaches, organizations, and doctors to streamline performance tracking, injury management, career planning, and communication.

## 🚀 Features

### 🔐 Authentication & Role-Based Access
- Secure **Login & Signup** using Firebase Authentication.
- **Role-based access** for different users:
    - **Athletes** – Manage performance, injuries, and career growth.
    - **Coaches** – Track athletes’ progress and set goals.
    - **Organizations** – Oversee multiple athletes and provide support.
    - **Doctors** – Assist athletes with injury management and rehabilitation.

### 🏥 Injury Management
- Store and track information about injuries.
- **Notify assigned doctors** through real-time notifications.
- Get **AI-based recommendations** for injury recovery using **Gemini API**.

### 🎯 Goal Setting
- Beautiful **UI with animations** for goal-setting and tracking.
- Save and manage goals using **Firebase Firestore**.

### 🏥 Doctor-Athlete Connection
- Athletes can **choose doctors** and connect with them.
- Doctors can monitor and provide injury recovery guidance.

### 💬 Messaging System
- Real-time **chat functionality** using Firebase Firestore.
- Athletes, coaches, and doctors can communicate seamlessly.

### 🔒 Secure API Access
- **Backend server** to securely store and access **Gemini API** key.
- Prevents unauthorized API usage and enhances security.

## 🛠️ Tech Stack

| Technology     | Purpose                                            |
|----------------|----------------------------------------------------|
| **Flutter**    | Frontend development (Android Studio, Project IDX) |
| **Firebase**   | Authentication, Firestore database, Storage        |
| **Gemini API** | AI-powered recommendations                         |
| **Node.js**    | Backend server for API security                    |
| **JavaScript** | Backend scripting and logic                        |
| **Vercel**     | Hosting the Backend Server                         |

## 🚀 Getting Started

### Prerequisites
- Install **Flutter & Dart SDK**
- Set up **Android Studio** or **Project IDX**(If Project IDX, then add .idx folder in the root directory)
- Configure **Firebase** in the project

### Installation
1. **Clone the repository**
   ```sh
   git clone https://github.com/your-repo/athletix.git
2. **Change Directory**
   ```sh
   cd athletix
3. **Install dependencies**
   ```sh
   flutter pub get
4. **Run the app**
   ```sh
   flutter run

## 🔧 Firebase Setup

This project uses Firebase services. To set up Firebase for development:

1. **Go to [Firebase Console](https://console.firebase.google.com/)** and create a project.
2. Select **Android App** in Firebase Project.
3. **Download** the `google-services.json` file.
4. Place it inside the `android/app/` directory.
5. Ensure the file is listed in `.gitignore` to prevent exposing credentials.

### 📌 Future Enhancements

1. Performance tracking dashboards
2. Financial management tools for athletes
3. AI-based career planning and analytics
4. Mobile & web compatibility

### 📜 License: This project is licensed under the MIT License.

## 🤝 Contributors

👤 **Amitouja Bose Tagore (Team Lead)**
- GitHub: [@Amitouja](https://github.com/Amitouja)
- LinkedIn: [Amitouja Bose Tagore](https://www.linkedin.com/in/amitouja/)

👤 **Syed Rizwan**
- GitHub: [@rizwansyed995](https://github.com/rizwansyed995)
- LinkedIn: [Syed Rizwan](https://www.linkedin.com/in/syed-rizwan-2264b5289/)

👤 **Vijay Guttula**
- GitHub: [@VJLIVE](https://github.com/VJLIVE)
- LinkedIn: [Vijay Guttula](https://www.linkedin.com/in/vijay-guttula/)  
