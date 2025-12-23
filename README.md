# HospiFin (Hospital Financial Anticipation Dashboard)

## Overview
HospiFin is a comprehensive full-stack application designed to provide hospital administrators with real-time financial tracking, patient management, and AI-driven cost forecasting. The system integrates a robust backend, a modern web dashboard, and a mobile application to ensure seamless access to critical data.

## Features
-   **Dashboard**: Real-time aggregation of hospital KPIs (Occupancy Rate, Total Revenue, etc.).
-   **Patient Management**: Full CRUD capabilities for managing patient records, stays, and medical acts.
-   **Financial Forecasting**: Advanced algorithms to predict future costs based on historical trends and seasonality.
-   **AI Assistant**: Integrated chat assistant using reliable RAG (Retrieval-Augmented Generation) to answer financial queries with context-aware data.
-   **Mobile Access**: dedicated Flutter app for monitoring hospital stats on the go.

## Technology Stack

### Backend
-   **Framework**: Spring Boot 3.2.0
-   **Language**: Java 17
-   **Database**: H2 In-Memory Database
-   **Build Tool**: Maven

### Frontend (Web)
-   **Framework**: React 19
-   **Bundler**: Vite
-   **UI Library**: Material UI (MUI) v7
-   **Routing**: React Router v7

### Mobile
-   **Framework**: Flutter
-   **Language**: Dart 3.x
-   **State Management**: Provider Pattern

## Getting Started

### Prerequisites
-   Java 17 Development Kit (JDK)
-   Node.js (v18+) and npm
-   Flutter SDK
-   Maven

### Installation & Setup

#### 1. Backend
Navigate to the root directory and run:
```bash
mvn clean install
mvn spring-boot:run
```
The backend server will start on `http://localhost:8080`.

#### 2. Frontend
Navigate to the `frontend` directory:
```bash
cd frontend
npm install
npm run dev
```
The web application will be accessible at `http://localhost:5173`.

#### 3. Mobile App
Navigate to the `mobile` directory:
```bash
cd mobile
flutter pub get
flutter run
```

## Architecture
The application follows a modular architecture:
-   **Core Logic**: Java Spring Boot handles business logic, data persistence, and the specialized forecasting engine.
-   **Data Storage**: H2 database serves as a fast, in-memory store for development and testing.
-   **Client Layers**: React and Flutter clients consume RESTful APIs to present data to the user.

## License
[MIT License](LICENSE)
