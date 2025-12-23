# HospiFin: Project Logic & Functions

## 1. Core Purpose (The "Meaning")
The main goal of this application is **Financial Anticipation**. It isn't just about recording what happened in the past (like a standard admin panel); it uses that past data to **predict future costs** so hospital administrators can plan ahead.

## 2. The Logic Flow (How it works)

The application follows a logical flow from raw data to intelligent insight:

### A. Data Collection (The Foundation)
Everything starts with the basic entities you manage in the Mobile and Web apps:
*   **Patients**: Who is being treated.
*   **Stays (Hospitalisations)**: How long they stay and the daily cost.
*   **Acts (Actes médicaux)**: Specific procedures (surgery, scans) that cost money.
*   **Consumables**: Medicine and supplies used.
*   **Staff**: Fixed costs (salaries) that must always be paid.

### B. Financial Aggregation (The Calculation)
The backend (Java Spring Boot) constantly monitors this data.
*   It sums up **Variable Costs** (Stays + Acts + Consumables).
*   It adds **Fixed Costs** (Staff Salaries).
*   **Result**: This gives you the *Real Daily Cost* shown on the "Tableau de bord" (Dashboard).

### C. Smart Prediction (The "Anticipation")
This is the advanced part of the app (`ForecastServiceV2`).
1.  **History Analysis**: It looks at all your past data.
2.  **Trend Detection**: It draws a "best fit line" (Linear Regression) to see if costs are generally going up or down.
3.  **Seasonality**: It is smart enough to know that some days (like Mondays) might be busier than Sundays. It calculates a "Seasonality Index" for every day of the week.
4.  **Forecast**: It combines the Trend + Seasonality to draw the **Dotted Line** on your "Prévisions" charts, telling you what to expect next week.

### D. AI Integration (The Assistant)
The Chat Assistant isn't just a generic chatbot. It works using **RAG (Retrieval-Augmented Generation)**:
1.  **You ask**: "Will we go over budget next week?"
2.  **The System**: Calculates the fresh predictions *first*.
3.  **Injection**: It pastes those numbers into a hidden note for the AI.
4.  **The AI answers**: It reads the note and answers you like a financial expert, using the real numbers from your database.

## 3. Key Functions Breakdown

| Function | Logic / Meaning |
| :--- | :--- |
| **Tableau de bord** (Dashboard) | **Immediate Health Check**. Shows aggregated totals (Occupancy rate, Total Revenue) to give a snapshot of right now. |
| **Prévisions** (Forecasts) | **Future Planning**. Compares "Real Data" (Solid line) vs "Predicted Data" (Dotted line). If the solid line goes above the dotted line, you are overspending! |
| **Patient Management** | **Operational Data**. Full CRUD (Create, Read, Update, Delete) to keep patient records accurate. |
| **Consommables & Médicaments** | **Inventory & Cost Tracking**. Tracking stock levels prevents shortages, and tracking usage feeds into the total cost per patient. |
| **AI Assistant** | **Strategic Analysis**. Allows you to "talk" to your data without running complex reports manually. |
