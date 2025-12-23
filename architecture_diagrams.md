# HospiFin Architecture Diagrams

This document contains the UML diagrams for the HospiFin project, illustrating the system's actors, structure, and key workflows.

## 1. Use Case Diagram
This diagram illustrates the interactions between users (Medical Staff, Administrators) and the system features.

```mermaid
usecaseDiagram
    actor "User" as User

    package "HospiFin System" {
        usecase "View Financial Dashboard" as UC1
        usecase "Manage Patients" as UC2
        usecase "Manage Medical Acts" as UC3
        usecase "Manage Inventory (Consumables/Meds)" as UC4
        usecase "Ask AI Financial Assistant" as UC5
        usecase "View Forecasts" as UC6
        usecase "Manage Personnel" as UC7
        usecase "Configure Settings" as UC8
    }

    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8

    UC1 ..> UC6 : includes
    UC5 ..> UC6 : uses data from
```

---

## 2. Class Diagram
This diagram details the database schema and object relationships based on the JPA entities.

```mermaid
classDiagram
    class Patient {
        +Long id
        +String firstName
        +String lastName
        +String ssn
        +LocalDate birthDate
    }

    class HospitalStay {
        +Long id
        +LocalDate startDate
        +LocalDate endDate
        +BigDecimal dailyRate
        +String pathology
    }

    class MedicalAct {
        +Long id
        +String type
        +BigDecimal cost
        +LocalDate date
        +String practitionerId
    }

    class Consumable {
        +Long id
        +String name
        +BigDecimal unitPrice
        +int quantity
        +LocalDate date
    }

    class Personnel {
        +Long id
        +String firstName
        +String lastName
        +String role
        +BigDecimal salary
        +String service
    }

    class ForecastServiceV2 {
        +getGlobalForecast(int days)
        -predictMedicalActsCosts()
        -predictConsumablesCosts()
        -predictStaysCosts()
    }

    Patient "1" *-- "0..*" HospitalStay : has
    Patient "1" *-- "0..*" MedicalAct : receives
    Patient "1" *-- "0..*" Consumable : uses
```

---

## 3. Sequence Diagrams

### 3.1 AI RAG Workflow (Ask Financial Question)
This sequence shows how the system retrieves real financial data (RAG) to ground the AI's response.

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant AIController as CustomAIController
    participant ForecastService as ForecastServiceV2
    participant AIService as OpenAiService
    participant LLM as Local_LLM_Server

    User->>Frontend: Asks "What is the cost trend?"
    Frontend->>AIController: POST /api/custom-ai/ask {question}
    
    rect rgb(240, 248, 255)
        note right of AIController: Retrieval Phase (RAG)
        AIController->>ForecastService: getGlobalForecast(7 days)
        ForecastService-->>AIController: Returns {currentTotal, predictedTotal, slope, seasonality}
    end

    AIController->>AIController: buildFinancialContext(forecastData)
    
    rect rgb(255, 240, 245)
        note right of AIController: Generation Phase
        AIController->>AIService: getChatResponse(question, context)
        AIService->>LLM: POST /chat/completions (System Prompt + Context + Question)
        LLM-->>AIService: Returns generated answer
    end

    AIService-->>AIController: Returns answer string
    AIController-->>Frontend: Returns {answer}
    Frontend-->>User: Displays AI Response
```

### 3.2 Patient Admission Flow
The standard workflow for adding a patient and their initial stay.

```mermaid
sequenceDiagram
    participant User
    participant Frontend
    participant PatientCtrl as PatientController
    participant StayCtrl as StayController
    participant DB as H2_Database

    User->>Frontend: Clicks "New Patient"
    Frontend->>Frontend: Opens Form Dialog
    User->>Frontend: Fills Details & Clicks Save
    Frontend->>PatientCtrl: POST /api/patients
    PatientCtrl->>DB: save(Patient)
    DB-->>PatientCtrl: Returns Patient (with ID)
    PatientCtrl-->>Frontend: Returns Success

    User->>Frontend: Clicks "Add Stay" (for new patient)
    Frontend->>StayCtrl: POST /api/stays
    StayCtrl->>DB: save(HospitalStay)
    DB-->>StayCtrl: Returns Stay
    StayCtrl-->>Frontend: Updates Dashboard View
```
