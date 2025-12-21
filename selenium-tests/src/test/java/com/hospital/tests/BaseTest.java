package com.hospital.tests;

import io.github.bonigarcia.wdm.WebDriverManager;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;

import java.time.Duration;

/**
 * Base test class for all Selenium tests.
 * Handles WebDriver setup and teardown.
 */
public class BaseTest {

    protected WebDriver driver;
    protected WebDriverWait wait;

    // Base URL for the frontend application
    protected static final String BASE_URL = "http://localhost:5173";

    @BeforeMethod
    public void setUp() {
        // Use WebDriverManager to automatically download and configure ChromeDriver
        WebDriverManager.chromedriver().setup();

        // Configure Chrome options
        ChromeOptions options = new ChromeOptions();
        options.addArguments("--start-maximized");
        options.addArguments("--disable-notifications");
        options.addArguments("--disable-popup-blocking");
        options.addArguments("--remote-allow-origins=*");

        // Initialize the driver
        driver = new ChromeDriver(options);

        // Set implicit wait
        driver.manage().timeouts().implicitlyWait(Duration.ofSeconds(10));

        // Initialize explicit wait
        wait = new WebDriverWait(driver, Duration.ofSeconds(15));
    }

    @AfterMethod
    public void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }

    /**
     * Navigate to a specific page by path
     * 
     * @param path The relative path (e.g., "/patients")
     */
    protected void navigateTo(String path) {
        driver.get(BASE_URL + path);
    }

    /**
     * Navigate to the home page (Dashboard)
     */
    protected void navigateToHome() {
        driver.get(BASE_URL);
    }
}
