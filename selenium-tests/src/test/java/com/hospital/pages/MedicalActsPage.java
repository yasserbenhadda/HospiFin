package com.hospital.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.List;

/**
 * Page object for the Medical Acts page.
 */
public class MedicalActsPage extends BasePage {

    // Page elements
    private final By pageTitle = By.xpath("//h4[contains(text(), 'Actes médicaux')]");
    private final By actsCount = By.xpath("//*[contains(text(), 'actes enregistrés')]");

    // Buttons
    private final By newActButton = By.xpath("//button[contains(text(), 'Nouvel acte')]");

    // Dialog
    private final By dialog = By.cssSelector(".MuiDialog-root");
    private final By saveButton = By.xpath("//button[contains(text(), 'Enregistrer')]");
    private final By cancelButton = By.xpath("//button[contains(text(), 'Annuler')]");

    // Table
    private final By tableRows = By.cssSelector("tbody tr");

    public MedicalActsPage(WebDriver driver) {
        super(driver);
    }

    /**
     * Wait for the medical acts page to load
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
     * Click on the New Act button
     */
    public void clickNewActButton() {
        waitForClickable(newActButton).click();
    }

    /**
     * Check if the dialog is open
     */
    public boolean isDialogOpen() {
        return isElementPresent(dialog);
    }

    /**
     * Fill the medical act form with data
     * Fields: Type, Date, Patient (dropdown), Praticien, Coût
     * The Patient field is a dropdown, so we need to handle it differently
     */
    public void fillMedicalActForm(String type, String date, String practitioner, String cost) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(dialog));

        // Wait a bit for dialog to fully load
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
        }

        // Fill Type (first text input)
        List<WebElement> textInputs = driver
                .findElements(By.xpath("//div[contains(@class, 'MuiDialog-root')]//input[@type='text']"));
        if (!textInputs.isEmpty()) {
            textInputs.get(0).clear();
            textInputs.get(0).sendKeys(type);
        }

        // Fill Date (date input)
        List<WebElement> dateInputs = driver
                .findElements(By.xpath("//div[contains(@class, 'MuiDialog-root')]//input[@type='date']"));
        if (!dateInputs.isEmpty()) {
            dateInputs.get(0).clear();
            dateInputs.get(0).sendKeys(date);
        }

        // Handle Patient dropdown - click to open and select first option
        try {
            WebElement patientDropdown = driver.findElement(
                    By.xpath("//div[contains(@class, 'MuiDialog-root')]//div[contains(@class, 'MuiSelect-select')]"));
            patientDropdown.click();
            Thread.sleep(300);

            // Select the first patient from the dropdown list
            List<WebElement> menuItems = driver.findElements(By.cssSelector(".MuiMenu-list li"));
            if (!menuItems.isEmpty()) {
                menuItems.get(0).click();
                Thread.sleep(300);
            }
        } catch (Exception e) {
            System.out.println("Could not select patient from dropdown: " + e.getMessage());
        }

        // Fill Practitioner (should be after the patient dropdown)
        List<WebElement> allTextInputs = driver
                .findElements(By.xpath("//div[contains(@class, 'MuiDialog-root')]//input[@type='text']"));
        if (allTextInputs.size() >= 2) {
            allTextInputs.get(1).clear();
            allTextInputs.get(1).sendKeys(practitioner);
        }

        // Fill Cost (number input)
        List<WebElement> numberInputs = driver
                .findElements(By.xpath("//div[contains(@class, 'MuiDialog-root')]//input[@type='number']"));
        if (!numberInputs.isEmpty()) {
            numberInputs.get(0).clear();
            numberInputs.get(0).sendKeys(cost);
        }
    }

    /**
     * Click the save button in the dialog
     */
    public void clickSaveButton() {
        waitForClickable(saveButton).click();
    }

    /**
     * Get the number of medical act rows
     */
    public int getActRowCount() {
        List<WebElement> rows = driver.findElements(tableRows);
        return rows.size();
    }
}
