package com.hospital.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.List;

/**
 * Page object for the Patients page.
 */
public class PatientsPage extends BasePage {

    // Page elements
    private final By pageTitle = By.xpath("//h4[contains(text(), 'Gestion des patients')]");
    private final By patientCount = By.xpath("//*[contains(text(), 'patients enregistrés')]");

    // Buttons
    private final By newPatientButton = By.xpath("//button[contains(text(), 'Nouveau patient')]");
    private final By filterButton = By.xpath("//button[contains(text(), 'Filtrer')]");
    private final By exportButton = By.xpath("//button[contains(text(), 'Exporter')]");

    // Search
    private final By searchInput = By.cssSelector("input[placeholder*='Rechercher']");

    // Table
    private final By patientsTable = By.cssSelector("table");
    private final By tableRows = By.cssSelector("tbody tr");

    // Dialog
    private final By dialog = By.cssSelector(".MuiDialog-root");
    private final By dialogTitle = By.cssSelector(".MuiDialogTitle-root");
    private final By firstNameInput = By.xpath("//label[contains(text(), 'Prénom')]/following-sibling::div//input");
    private final By lastNameInput = By.xpath("//label[contains(text(), 'Nom')]/following-sibling::div//input");
    private final By birthDateInput = By.cssSelector("input[type='date']");
    private final By ssnInput = By.xpath("//label[contains(text(), 'Sécurité Sociale')]/following-sibling::div//input");
    private final By saveButton = By.xpath("//button[contains(text(), 'Enregistrer')]");
    private final By cancelButton = By.xpath("//button[contains(text(), 'Annuler')]");

    // Edit/Delete buttons
    private final By editButtons = By.cssSelector("[data-testid='EditIcon']");
    private final By deleteButtons = By.cssSelector("[data-testid='DeleteOutlineIcon']");

    public PatientsPage(WebDriver driver) {
        super(driver);
    }

    /**
     * Wait for the patients page to load
     */
    public void waitForPageLoad() {
        wait.until(ExpectedConditions.visibilityOfElementLocated(pageTitle));
    }

    /**
     * Check if the page title is displayed
     */
    public boolean isPageTitleDisplayed() {
        return isElementPresent(pageTitle);
    }

    /**
     * Check if patients table is visible
     */
    public boolean isTableVisible() {
        return isElementPresent(patientsTable);
    }

    /**
     * Get the number of patients in the table
     */
    public int getPatientRowCount() {
        List<WebElement> rows = driver.findElements(tableRows);
        return rows.size();
    }

    /**
     * Click on the New Patient button
     */
    public void clickNewPatientButton() {
        waitForClickable(newPatientButton).click();
    }

    /**
     * Check if the dialog is open
     */
    public boolean isDialogOpen() {
        return isElementPresent(dialog);
    }

    /**
     * Fill the patient form with data
     */
    public void fillPatientForm(String firstName, String lastName, String birthDate, String ssn) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(dialog));

        // Find inputs within the dialog
        List<WebElement> inputs = driver.findElements(By.cssSelector(".MuiDialog-root input"));

        if (inputs.size() >= 4) {
            inputs.get(0).clear();
            inputs.get(0).sendKeys(firstName);

            inputs.get(1).clear();
            inputs.get(1).sendKeys(lastName);

            inputs.get(2).clear();
            inputs.get(2).sendKeys(birthDate);

            inputs.get(3).clear();
            inputs.get(3).sendKeys(ssn);
        }
    }

    /**
     * Click the save button in the dialog
     */
    public void clickSaveButton() {
        waitForClickable(saveButton).click();
    }

    /**
     * Click the cancel button in the dialog
     */
    public void clickCancelButton() {
        waitForClickable(cancelButton).click();
    }

    /**
     * Enter a search term
     */
    public void searchPatient(String searchTerm) {
        WebElement search = waitForElement(searchInput);
        search.clear();
        search.sendKeys(searchTerm);
    }

    /**
     * Clear the search field
     */
    public void clearSearch() {
        WebElement search = waitForElement(searchInput);
        search.clear();
    }

    /**
     * Check if the new patient button is visible
     */
    public boolean isNewPatientButtonVisible() {
        return isElementPresent(newPatientButton);
    }

    /**
     * Check if search input is visible
     */
    public boolean isSearchInputVisible() {
        return isElementPresent(searchInput);
    }
}
