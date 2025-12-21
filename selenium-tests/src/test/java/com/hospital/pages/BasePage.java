package com.hospital.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;

/**
 * Base page class with common methods for all pages.
 */
public class BasePage {

    protected WebDriver driver;
    protected WebDriverWait wait;

    public BasePage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, Duration.ofSeconds(15));
    }

    /**
     * Wait for an element to be visible and return it
     */
    protected WebElement waitForElement(By locator) {
        return wait.until(ExpectedConditions.visibilityOfElementLocated(locator));
    }

    /**
     * Wait for an element to be clickable and return it
     */
    protected WebElement waitForClickable(By locator) {
        return wait.until(ExpectedConditions.elementToBeClickable(locator));
    }

    /**
     * Check if an element is present on the page
     */
    public boolean isElementPresent(By locator) {
        try {
            driver.findElement(locator);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Get the page title
     */
    public String getPageTitle() {
        return driver.getTitle();
    }

    /**
     * Get the current URL
     */
    public String getCurrentUrl() {
        return driver.getCurrentUrl();
    }
}
