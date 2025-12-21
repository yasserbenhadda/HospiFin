# Hospital Dashboard Selenium Tests

Automated UI tests for the HospiFin Hospital Financial Dashboard using Selenium WebDriver, TestNG, and Java.

## Prerequisites

1. **Java 11+** installed
2. **Maven** installed
3. **Chrome browser** installed
4. **ChromeDriver** at: `C:\Users\sabou\Downloads\chromedriver-win64\chromedriver.exe`
5. **Frontend running** at `http://localhost:5173` (run `npm run dev` in frontend folder)
6. **Backend running** at `http://localhost:8080`

## Project Structure

```
selenium-tests/
├── pom.xml
├── README.md
└── src/test/
    ├── java/com/hospital/
    │   ├── pages/
    │   │   ├── BasePage.java
    │   │   ├── DashboardPage.java
    │   │   ├── LayoutPage.java
    │   │   └── PatientsPage.java
    │   └── tests/
    │       ├── BaseTest.java
    │       └── HospitalDashboardTests.java
    └── resources/
        └── testng.xml
```

## Test Scenarios (10 Total)

| # | Test Name | Description |
|---|-----------|-------------|
| 1 | Dashboard Load | Verifies dashboard loads with KPI cards |
| 2 | Navigate to Patients | Tests navigation to Patients page |
| 3 | Add New Patient | Opens form, fills data, saves patient |
| 4 | Search Patient | Tests search/filter functionality |
| 5 | Navigate to Personnel | Tests navigation to Personnel page |
| 6 | Navigate to Stays | Tests navigation to Stays page |
| 7 | Navigate to Forecasts | Tests navigation to Forecasts page |
| 8 | Navigate to Settings | Tests navigation to Settings page |
| 9 | Sidebar Navigation | Verifies all menu items present |
| 10 | Navigate to Chat | Tests navigation to Chat Assistant |

## Running Tests

```bash
# Navigate to the test project
cd selenium-tests

# Run all tests
mvn test

# Run with detailed output
mvn test -Dtest=HospitalDashboardTests

# Clean and run
mvn clean test
```

## Important Notes

- Make sure ChromeDriver version matches your Chrome browser version
- Frontend must be running before executing tests
- Tests are executed in priority order (1-10)
