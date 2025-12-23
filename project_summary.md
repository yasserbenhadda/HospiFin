# HospiFin Project: Comprehensive Technical Report

## 1. Executive Summary
**Project Name:** HospiFin (Hospital Care Financial Anticipation Dashboard)
**Type:** Full-Stack Web & Mobile Application
**Objective:** Provide hospital administrators with real-time financial tracking, patient management, and AI-driven cost forecasting.

The system uses a **Spring Boot** backend with an **H2** in-memory database for rapid development, a **React/MUI** frontend for the web dashboard, and a **Flutter** application for mobile access. Key differentiator is the **Local LLM Integration** (via LangChain4j) that uses RAG (Retrieval-Augmented Generation) to answer financial questions using real calculated data.

---

## 2. Technical Architecture & Stack

### 2.1 Backend System (Server)
*   **Framework:** Spring Boot 3.2.0
*   **Language:** Java 17
*   **Build System:** Maven
*   **Database:** H2 In-Memory (URL: `jdbc:h2:mem:hospital_db`)
    *   *Configured in `src/main/resources/application.properties`.*
    *   *Data assumes non-persistence (lost on restart) unless `DataSeeder` runs.*
*   **AI Engine:** LangChain4j interacting with local LM Studio.
    *   Model: `meta-llama-3.1-8b-instruct`
    *   URL: `http://127.0.0.1:1234/v1`

### 2.2 Frontend Client (Web)
*   **Framework:** React 19
*   **Bundler:** Vite
*   **UI System:** Material UI (MUI) v7
*   **Routing:** React Router v7
*   **State/Data:** Axios (HTTP), Local Component State
*   **Analysis:** ESlint

### 2.3 Mobile Client (App)
*   **Framework:** Flutter (Dart 3.x)
*   **Architecture:** Provider Pattern (State Management)
*   **Networking:** Dio
*   **Visuals:** fl_chart (for graphs), Google Fonts
*   **Platform:** Android / iOS (configured)

---

## 3. Detailed Data Model (Database Schema)
The application defines the following core entities in `com.hospital.dashboard.model`:

| Entity | Primary Key | Key Fields | Relationships |
| :--- | :--- | :--- | :--- |
| **Patient** | `id` (Long) | `firstName`, `lastName`, `ssn`, `birthDate` | OneToMany with Stays, MedicalActs, Consumables |
| **HospitalStay** | `id` (Long) | `startDate`, `endDate`, `dailyRate`, `pathology` | ManyToOne to Patient |
| **MedicalAct** | `id` (Long) | `type` (name), `cost`, `date`, `practitionerId` | ManyToOne to Patient |
| **Personnel** | `id` (Long) | `firstName`, `lastName`, `role`, `salary`, `service` | None (Standalone reference) |
| **Consumable** | `id` (Long) | `name`, `unitPrice`, `quantity`, `date` | ManyToOne to Patient |
| **Medication** | `id` (Long) | `name`, `price`, `stockQuantity` | None (Inventory tracking) |

---

## 4. API Specification & Endpoints
The backend exposes a REST API via `com.hospital.dashboard.controller`. All endpoints are prefixed with `/api`.

### 4.1 Authentication
*   `POST /api/auth/login`: Accepts `{email, password}`.
    *   *Implementation:* Hardcoded mock check (password="password"). Returns a dummy UUID token.

### 4.2 Core Business Logic
*   **Dashboard**: `GET /api/dashboard/summary` (Aggregated KPIs: total patients, revenue, occupancy).
*   **Patients**: Full CRUD (`GET`, `POST`, `PUT`, `DELETE` to `/api/patients`).
*   **Personnel**: Full CRUD (`/api/personnel`).
*   **Medical Acts**: `/api/medical-acts`
*   **Stays**: `/api/stays`
*   **Consumables**: `/api/consumables`
*   **Forecasts**: `GET /api/forecasts?days={N}` (Returns prediction data objects).

### 4.3 AI & Intelligence (Special Feature)
*   `POST /api/custom-ai/ask`: RAG Endpoint.
    *   **Payload**: `{"question": "..."}`
    *   **Logic**:
        1.  Checks if Model is "trained" (Mock flag).
        2.  Calls `ForecastServiceV2` to get financial stats (Last 30 days cost, Predicted 7 days cost, trend slope).
        3.  Injects stats into System Prompt ("You are an expert... here is real data: ...").
        4.  Sends to Local LLM via `OpenAiService`.
        5.  Returns `{ "answer": "..." }`.

---

## 5. Algorithmic Logic: Financial Forecasting
**Implemented Class:** `com.hospital.dashboard.service.ForecastServiceV2`
This service predicts future hospital costs based on historical data.

**Algorithm Steps:**
1.  **Data Extraction**: Fetches all `MedicalAct`, `Consumable`, and `HospitalStay` records.
2.  **Aggregation**: Groups costs by date (Daily mode) or month (Monthly mode).
3.  **Seasonality Calculation**:
    *   Calculates a "Seasonality Index" for each Day of Week (Mon-Sun).
    *   *Formula:* `Index = (Average Cost for Day X) / (Global Average Daily Cost)`
4.  **Trend Analysis (Linear Regression)**:
    *   Uses `Apache Commons Math3` (`SimpleRegression`).
    *   Fits a line (`y = ax + b`) to the historical cost data.
5.  **Prediction Generation**:
    *   Base Prediction = `Regression(FutureDate)`
    *   Final Prediction = `Base Prediction * SeasonalityIndex(FutureDate.DayOfWeek)`
6.  **Personnel Load**: Adds fixed daily personnel costs (base load) to both historical and predicted values.

---

## 6. Client-Side Implementation Details

### 6.1 Web Routing (React)
Defined in `App.jsx`, mapping URL paths to `pages/` components:
*   `/` -> `Dashboard.jsx` (KPI Cards)
*   `/patients` -> `Patients.jsx` (DataGrid)
*   `/forecasts` -> `Forecasts.jsx` (Recharts LineChart with "Real" vs "Predicted" series)
*   `/chat` -> `ChatAssistant.jsx` (Chat interface)
*   ...and other CRUD pages.

### 6.2 Mobile Structure (Flutter)
Located in `mobile/lib/presentation/screens`:
*   `access`: `LoginScreen`, `SplashScreen`
*   `core`: `MainContainer` (holds the Bottom Navigation Bar), `MenuScreen`
*   `features`:
    *   `DashboardScreen`: Grid of KPI widgets.
    *   `PrevisionsScreen`: Mobile version of forecasts using `fl_chart`.
    *   `ChatScreen`: Mobile chat bubble interface.
    *   `PatientsScreen`: ListView of patients with detail drill-down.

---

## 7. Quality Assurance (Q.A.)
*   **Selenium Tests** (`selenium-tests` folder):
    *   Suite: `HospitalDashboardTests.java`
    *   Coverage: 10 Scenarios (Dashboard load, Patient Add/Edit/Delete, Chatbot timeout check, Page Navigation).
*   **Performance**:
    *   File: `performance_test.jmx` (Apache JMeter test plan).
    *   Target: Load testing the `/api/dashboard` and `/api/patients` endpoints.

## 8. Inactive / Legacy Components
*   **MySQL Support**: Dependencies exist, but deactivated in favor of H2.
*   **ForecastService (V1)**: Code likely removed or refactored into V2; V2 is the active Spring Bean.
*   **Remote OpenAI**: `openai.api.key` is a placeholder. System relies entirely on local inference.
