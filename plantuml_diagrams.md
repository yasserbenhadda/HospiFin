# HospiFin PlantUML Diagrams

This document contains the PlantUML code for the HospiFin project diagrams. You can render these using any PlantUML editor or the official [PlantUML Server](http://www.plantuml.com/plantuml/).

## 1. Use Case Diagram

```plantuml
@startuml
left to right direction
actor "User" as User

package "HospiFin System" {
    usecase "View Financial Dashboard" as UC1
    usecase "Manage Patients" as UC2
    usecase "Manage Medical Acts" as UC3
    usecase "Manage Inventory\n(Consumables/Meds)" as UC4
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

UC1 ..> UC6 : <<include>>
UC5 ..> UC6 : <<uses>>
@enduml
```

---

## 2. Class Diagram

```plantuml
@startuml
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

Patient "1" *-- "0..*" HospitalStay : has >
Patient "1" *-- "0..*" MedicalAct : receives >
Patient "1" *-- "0..*" Consumable : uses >
@enduml
```

---

## 3. Sequence Diagrams

### 3.1 AI RAG Workflow (Ask Financial Question)

```plantuml
@startuml
participant User
participant Frontend
participant "CustomAIController" as AIController
participant "ForecastServiceV2" as ForecastService
participant "OpenAiService" as AIService
participant "Local LLM Server" as LLM

User -> Frontend: Asks "What is the cost trend?"
activate Frontend
Frontend -> AIController: POST /api/custom-ai/ask {question}
activate AIController

group Retrieval Phase (RAG)
    AIController -> ForecastService: getGlobalForecast(7 days)
    activate ForecastService
    ForecastService --> AIController: Returns {currentTotal, predictedTotal, slope, seasonality}
    deactivate ForecastService
end

AIController -> AIController: buildFinancialContext(forecastData)

group Generation Phase
    AIController -> AIService: getChatResponse(question, context)
    activate AIService
    AIService -> LLM: POST /chat/completions\n(System Prompt + Context + Question)
    activate LLM
    LLM --> AIService: Returns generated answer
    deactivate LLM
    AIService --> AIController: Returns answer string
    deactivate AIService
end

AIController --> Frontend: Returns {answer}
deactivate AIController
Frontend --> User: Displays AI Response
deactivate Frontend
@enduml
```

### 3.2 Patient Admission Flow

```plantuml
@startuml
actor User
participant Frontend
participant "PatientController" as PatientCtrl
participant "StayController" as StayController
database "H2 Database" as DB

User -> Frontend: Clicks "New Patient"
activate Frontend
Frontend -> Frontend: Opens Form Dialog
User -> Frontend: Fills Details & Clicks Save
Frontend -> PatientCtrl: POST /api/patients
activate PatientCtrl
PatientCtrl -> DB: save(Patient)
activate DB
DB --> PatientCtrl: Returns Patient (with ID)
deactivate DB
PatientCtrl --> Frontend: Returns Success
deactivate PatientCtrl

User -> Frontend: Clicks "Add Stay" (for new patient)
Frontend -> StayCtrl: POST /api/stays
activate StayCtrl
StayCtrl -> DB: save(HospitalStay)
activate DB
DB --> StayCtrl: Returns Stay
deactivate DB
StayCtrl --> Frontend: Updates Dashboard View
deactivate StayCtrl
deactivate Frontend
@enduml
```
