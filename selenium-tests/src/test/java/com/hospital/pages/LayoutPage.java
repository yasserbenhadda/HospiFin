package com.hospital.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;

import java.util.List;

/**
 * Page object for the sidebar navigation layout.
 * Contains methods to interact with the sidebar menu.
 */
public class LayoutPage extends BasePage {

    // Sidebar menu locators
    private final By sidebarMenu = By.cssSelector(".MuiDrawer-root .MuiList-root");
    private final By menuItems = By.cssSelector(".MuiDrawer-root .MuiListItemButton-root");
    private final By searchInput = By.cssSelector("input[aria-label='search']");
    private final By notificationBell = By.cssSelector("[data-testid='NotificationsNoneIcon']");
    private final By userAvatar = By.cssSelector(".MuiAvatar-root");
    private final By logoText = By.xpath("//h6[contains(text(), 'HospiFin')]");

    // Menu item selectors by text
    private final String menuItemByTextXpath = "//span[contains(@class, 'MuiListItemText-primary') and contains(text(), '%s')]";

    public LayoutPage(WebDriver driver) {
        super(driver);
    }

    /**
     * Click on a menu item by its text
     */
    public void clickMenuItem(String menuText) {
        By menuItem = By.xpath(String.format(menuItemByTextXpath, menuText));
        waitForClickable(menuItem).click();
    }

    /**
     * Navigate to Dashboard
     */
    public void navigateToDashboard() {
        clickMenuItem("Tableau de bord");
    }

    /**
     * Navigate to Patients page
     */
    public void navigateToPatients() {
        clickMenuItem("Patients");
    }

    /**
     * Navigate to Personnel page
     */
    public void navigateToPersonnel() {
        clickMenuItem("Personnel");
    }

    /**
     * Navigate to Stays (Séjours) page
     */
    public void navigateToStays() {
        clickMenuItem("Séjours");
    }

    /**
     * Navigate to Medical Acts page
     */
    public void navigateToMedicalActs() {
        clickMenuItem("Actes Médicaux");
    }

    /**
     * Navigate to Medications page
     */
    public void navigateToMedications() {
        clickMenuItem("Médicaments");
    }

    /**
     * Navigate to Consumables page
     */
    public void navigateToConsumables() {
        clickMenuItem("Consommables");
    }

    /**
     * Navigate to Forecasts page
     */
    public void navigateToForecasts() {
        clickMenuItem("Prévisions");
    }

    /**
     * Navigate to Settings page
     */
    public void navigateToSettings() {
        clickMenuItem("Paramètres");
    }

    /**
     * Navigate to Chat Assistant page
     */
    public void navigateToChatAssistant() {
        clickMenuItem("Assistant IA");
    }

    /**
     * Check if sidebar is visible
     */
    public boolean isSidebarVisible() {
        return isElementPresent(sidebarMenu);
    }

    /**
     * Get the count of menu items
     */
    public int getMenuItemCount() {
        List<WebElement> items = driver.findElements(menuItems);
        return items.size();
    }

    /**
     * Check if logo is visible
     */
    public boolean isLogoVisible() {
        return isElementPresent(logoText);
    }

    /**
     * Check if the currently selected menu item matches the expected text
     */
    public boolean isMenuItemSelected(String menuText) {
        By menuItem = By.xpath(
                String.format(menuItemByTextXpath, menuText) + "/ancestor::div[contains(@class, 'Mui-selected')]");
        return isElementPresent(menuItem);
    }
}
