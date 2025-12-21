package com.hospital.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.List;

/**
 * Page object for the Chat Assistant page.
 */
public class ChatAssistantPage extends BasePage {

    // Page elements
    private final By pageHeader = By.xpath("//*[contains(text(), 'Assistant IA HospiFin')]");

    // Chat input
    private final By chatInput = By.cssSelector("textarea[placeholder*='question'], input[placeholder*='question']");

    // Messages - XPath for response messages
    private final By messages = By.cssSelector(".MuiPaper-root .MuiStack-root > .MuiStack-root");
    private final By loadingIndicator = By.cssSelector(".MuiCircularProgress-root");

    // Response message XPath (provided by user) - the third message in the chat
    // (after welcome + user message)
    private final By responseMessage = By.xpath("//*[@id='root']/div/main/div/div[2]/div/div[3]/div[2]/div/p");

    public ChatAssistantPage(WebDriver driver) {
        super(driver);
    }

    /**
     * Wait for the chat page to load
     */
    public void waitForPageLoad() {
        wait.until(ExpectedConditions.visibilityOfElementLocated(pageHeader));
    }

    /**
     * Check if the page header is displayed
     */
    public boolean isPageHeaderDisplayed() {
        return isElementPresent(pageHeader);
    }

    /**
     * Type a message in the chat input
     */
    public void typeMessage(String message) {
        WebElement input = waitForElement(chatInput);
        input.clear();
        input.sendKeys(message);
    }

    /**
     * Click the send button - uses the dark button next to the input
     */
    public void clickSendButton() {
        try {
            // Find the send button (it's the IconButton with dark background)
            WebElement sendBtn = driver
                    .findElement(By.xpath("//button[contains(@class, 'MuiIconButton-root') and .//svg]"));
            sendBtn.click();
        } catch (Exception e) {
            // Fallback: try clicking any button with SVG icon in chat area
            try {
                List<WebElement> buttons = driver
                        .findElements(By.xpath("//button[.//svg[contains(@class, 'MuiSvgIcon-root')]]"));
                for (WebElement btn : buttons) {
                    if (btn.isDisplayed() && btn.isEnabled()) {
                        btn.click();
                        return;
                    }
                }
            } catch (Exception ex) {
                // Last fallback: press Enter
                WebElement input = driver.findElement(chatInput);
                input.sendKeys(org.openqa.selenium.Keys.ENTER);
            }
        }
    }

    /**
     * Send a message (type and press Enter to send)
     */
    public void sendMessage(String message) {
        WebElement input = waitForElement(chatInput);
        input.clear();
        input.sendKeys(message);
        // Use Enter key to send - most reliable method
        input.sendKeys(org.openqa.selenium.Keys.ENTER);
    }

    /**
     * Wait for response by checking for the response message element
     * Uses the specific XPath:
     * //*[@id='root']/div/main/div/div[2]/div/div[3]/div[2]/div/p
     */
    public void waitForResponse() {
        WebDriverWait longWait = new WebDriverWait(driver, Duration.ofSeconds(60));

        try {
            longWait.until(ExpectedConditions.visibilityOfElementLocated(responseMessage));
            System.out.println("Response detected!");
        } catch (Exception e) {
            System.out.println("Timeout waiting for response: " + e.getMessage());
        }
    }

    /**
     * Wait for response with custom maximum timeout (in seconds)
     * Waits until the response message element appears at the specific XPath
     */
    public void waitForResponseWithTimeout(int maxSeconds) {
        WebDriverWait customWait = new WebDriverWait(driver, Duration.ofSeconds(maxSeconds));

        // Count messages before sending
        int initialMessageCount = getMessageCount();
        System.out.println("Initial message count: " + initialMessageCount);

        try {
            // Wait for the response element to appear
            customWait.until(ExpectedConditions.visibilityOfElementLocated(responseMessage));
            System.out.println("✓ Response message detected at XPath!");
            return;
        } catch (Exception e) {
            System.out.println("Response element not found at specific XPath, checking message count...");
        }

        // Fallback: check if message count increased
        int finalMessageCount = getMessageCount();
        if (finalMessageCount > initialMessageCount) {
            System.out.println(
                    "✓ Response detected via message count: " + initialMessageCount + " -> " + finalMessageCount);
        } else {
            System.out.println("No response detected within timeout");
        }
    }

    /**
     * Check if loading indicator is visible
     */
    public boolean isLoading() {
        return isElementPresent(loadingIndicator);
    }

    /**
     * Get the count of messages in the chat
     */
    public int getMessageCount() {
        List<WebElement> msgs = driver.findElements(messages);
        return msgs.size();
    }

    /**
     * Check if response message is visible
     */
    public boolean isResponseVisible() {
        return isElementPresent(responseMessage);
    }

    /**
     * Get the response text
     */
    public String getResponseText() {
        try {
            WebElement response = waitForElement(responseMessage);
            return response.getText();
        } catch (Exception e) {
            return "";
        }
    }
}
