package com.hospital.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.List;

/**
 * Page object for the Settings page.
 */
public class SettingsPage extends BasePage {

    // Page elements
    private final By pageTitle = By.xpath("//h4[contains(text(), 'Paramètres')]");

    // Profile form fields
    private final By nameInput = By.cssSelector("input[name='name']");
    private final By roleInput = By.cssSelector("input[name='role']");
    private final By emailInput = By.cssSelector("input[name='email']");
    private final By phoneInput = By.cssSelector("input[name='phone']");
    private final By serviceInput = By.cssSelector("input[name='service']");

    // Buttons
    private final By saveButton = By.xpath("//button[contains(text(), 'Enregistrer les modifications')]");
    private final By cancelButton = By.xpath("//button[contains(text(), 'Annuler')]");

    // Snackbar
    private final By successSnackbar = By.xpath("//*[contains(text(), 'Profil mis à jour avec succès')]");

    // Header user name display (for verification after save)
    private final By headerUserName = By.xpath("//*[@id='root']/div/header/div/div[3]/div[1]/h6");

    public SettingsPage(WebDriver driver) {
        super(driver);
    }

    /**
     * Wait for the settings page to load
     */
    public void waitForPageLoad() {
        wait.until(ExpectedConditions.visibilityOfElementLocated(pageTitle));
        // Wait a bit for profile data to load
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            // Ignore
        }
    }

    /**
     * Check if the page title is displayed
     */
    public boolean isPageTitleDisplayed() {
        return isElementPresent(pageTitle);
    }

    /**
     * Get the current name value from input field
     */
    public String getNameValue() {
        return waitForElement(nameInput).getAttribute("value");
    }

    /**
     * Get the user name displayed in the header
     */
    public String getHeaderUserName() {
        try {
            WebElement headerName = waitForElement(headerUserName);
            return headerName.getText();
        } catch (Exception e) {
            return "";
        }
    }

    /**
     * Set the name field value
     */
    public void setName(String name) {
        WebElement input = waitForElement(nameInput);
        input.clear();
        input.sendKeys(name);
    }

    /**
     * Set the role field value
     */
    public void setRole(String role) {
        WebElement input = waitForElement(roleInput);
        input.clear();
        input.sendKeys(role);
    }

    /**
     * Set the email field value
     */
    public void setEmail(String email) {
        WebElement input = waitForElement(emailInput);
        input.clear();
        input.sendKeys(email);
    }

    /**
     * Click the save button
     */
    public void clickSaveButton() {
        waitForClickable(saveButton).click();
    }

    /**
     * Check if success message appeared
     */
    public boolean isSuccessMessageDisplayed() {
        try {
            wait.until(ExpectedConditions.visibilityOfElementLocated(successSnackbar));
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Update the profile name and save, then wait for page reload
     */
    /**
     * Wait for page reload after save
     */
    public void waitForPageReload() {
        try {
            // Wait specifically for the header name to contain "TestSelenium" or generally
            // update
            // Since we know what we set it to (passed in updateProfileName, but here we are
            // generic)
            // We'll just increase the sleep to be safe, but ideally we should wait for a
            // condition.

            // The frontend waits 1000ms before reloading.
            // We wait 1500ms to ensure reload has started.
            Thread.sleep(1500);

            // Now wait for the page title to come back (reload finished)
            wait.until(ExpectedConditions.stalenessOf(driver.findElement(pageTitle)));
            wait.until(ExpectedConditions.visibilityOfElementLocated(pageTitle));

            // And give the generic "fetchUser" useEffect a moment to populate the header
            Thread.sleep(1000);
        } catch (Exception e) {
            // Fallback if staleness fails (e.g. reload was too fast)
            try {
                Thread.sleep(3000);
            } catch (InterruptedException ignored) {
            }
        }
    }

    /**
     * Update the profile name and save, then wait for verification
     */
    public void updateProfileName(String newName) {
        setName(newName);
        clickSaveButton();
        // Custom wait for this specific action's result in the header
        try {
            // Frontend delay (1s) + Reload time
            Thread.sleep(1500);
            // Wait for header to reflect the new name
            wait.until(ExpectedConditions.textToBePresentInElementLocated(headerUserName, newName));
        } catch (Exception e) {
            System.out.println("Warning: Header didn't update within timeout: " + e.getMessage());
        }
    }
}
