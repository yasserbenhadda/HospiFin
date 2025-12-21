package com.hospital.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.List;

/**
 * Page object for the Personnel page.
 */
public class PersonnelPage extends BasePage {

    // Page elements
    private final By pageTitle = By.xpath("//h4[contains(text(), 'Gestion du personnel')]");
    private final By personnelCount = By.xpath("//*[contains(text(), 'membres du personnel')]");

    // Buttons
    private final By newMemberButton = By.xpath("//button[contains(text(), 'Nouveau membre')]");

    // Dialog
    private final By dialog = By.cssSelector(".MuiDialog-root");
    private final By saveButton = By.xpath("//button[contains(text(), 'Enregistrer')]");
    private final By cancelButton = By.xpath("//button[contains(text(), 'Annuler')]");

    // Table
    private final By tableRows = By.cssSelector("tbody tr");

    public PersonnelPage(WebDriver driver) {
        super(driver);
    }

    /**
     * Wait for the personnel page to load
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
     * Click on the New Member button
     */
    public void clickNewMemberButton() {
        waitForClickable(newMemberButton).click();
    }

    /**
     * Check if the dialog is open
     */
    public boolean isDialogOpen() {
        return isElementPresent(dialog);
    }

    /**
     * Fill the personnel form with data
     * Fields: Nom, Rôle, Service, Coût/Jour, Email, Téléphone
     */
    public void fillPersonnelForm(String name, String role, String service, String costPerDay, String email,
            String phone) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(dialog));

        List<WebElement> inputs = driver.findElements(By.cssSelector(".MuiDialog-root input"));

        if (inputs.size() >= 6) {
            inputs.get(0).clear();
            inputs.get(0).sendKeys(name);

            inputs.get(1).clear();
            inputs.get(1).sendKeys(role);

            inputs.get(2).clear();
            inputs.get(2).sendKeys(service);

            inputs.get(3).clear();
            inputs.get(3).sendKeys(costPerDay);

            inputs.get(4).clear();
            inputs.get(4).sendKeys(email);

            inputs.get(5).clear();
            inputs.get(5).sendKeys(phone);
        }
    }

    /**
     * Click the save button in the dialog
     */
    public void clickSaveButton() {
        waitForClickable(saveButton).click();
    }

    /**
     * Get the number of personnel rows
     */
    public int getPersonnelRowCount() {
        List<WebElement> rows = driver.findElements(tableRows);
        return rows.size();
    }
}
