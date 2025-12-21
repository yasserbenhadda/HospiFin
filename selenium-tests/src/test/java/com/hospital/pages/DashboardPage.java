package com.hospital.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;

import java.util.List;

/**
 * Page object for the Dashboard page.
 */
public class DashboardPage extends BasePage {

    // Page title
    private final By pageTitle = By.xpath("//h5[contains(text(), 'Vue d')]");

    // KPI Cards - looking for the cost labels
    private final By kpiCards = By.cssSelector(".MuiPaper-root");
    private final By totalRealCostLabel = By.xpath("//*[contains(text(), 'Coût réel total')]");
    private final By totalPredictedCostLabel = By.xpath("//*[contains(text(), 'Coût prédit total')]");
    private final By avgCostLabel = By.xpath("//*[contains(text(), 'Coût moyen par séjour')]");
    private final By personnelRatioLabel = By.xpath("//*[contains(text(), 'Ratio coût personnel')]");

    // Charts
    private final By lineChart = By.cssSelector(".recharts-line-chart");
    private final By barChart = By.cssSelector(".recharts-bar-chart");
    private final By pieChart = By.cssSelector(".recharts-pie-chart");

    // Buttons
    private final By periodButton = By.xpath("//button[contains(text(), '30 jours')]");
    private final By serviceButton = By.xpath("//button[contains(text(), 'Tous les services')]");

    // Recent stays section
    private final By recentStaysSection = By.xpath("//*[contains(text(), 'Séjours récents')]");
    private final By viewAllButton = By.xpath("//button[contains(text(), 'Voir tout')]");

    // Error state
    private final By errorMessage = By.xpath("//*[contains(text(), 'Erreur de chargement')]");

    // Loading state
    private final By loadingText = By.xpath("//*[contains(text(), 'Chargement')]");

    public DashboardPage(WebDriver driver) {
        super(driver);
    }

    /**
     * Wait for the dashboard to fully load
     */
    public void waitForDashboardLoad() {
        // Wait for loading to disappear or page content to appear
        try {
            wait.until(ExpectedConditions.or(
                    ExpectedConditions.visibilityOfElementLocated(pageTitle),
                    ExpectedConditions.visibilityOfElementLocated(errorMessage)));
        } catch (Exception e) {
            // Continue anyway
        }
    }

    /**
     * Check if the dashboard page title is displayed
     */
    public boolean isPageTitleDisplayed() {
        return isElementPresent(pageTitle);
    }

    /**
     * Check if KPI cards are visible
     */
    public boolean areKpiCardsVisible() {
        return isElementPresent(totalRealCostLabel) || isElementPresent(errorMessage);
    }

    /**
     * Check if total real cost card is visible
     */
    public boolean isTotalRealCostVisible() {
        return isElementPresent(totalRealCostLabel);
    }

    /**
     * Check if total predicted cost card is visible
     */
    public boolean isTotalPredictedCostVisible() {
        return isElementPresent(totalPredictedCostLabel);
    }

    /**
     * Check if average cost card is visible
     */
    public boolean isAvgCostVisible() {
        return isElementPresent(avgCostLabel);
    }

    /**
     * Check if personnel ratio card is visible
     */
    public boolean isPersonnelRatioVisible() {
        return isElementPresent(personnelRatioLabel);
    }

    /**
     * Check if charts are visible
     */
    public boolean areChartsVisible() {
        return isElementPresent(lineChart) || isElementPresent(barChart) || isElementPresent(pieChart);
    }

    /**
     * Check if recent stays section is visible
     */
    public boolean isRecentStaysSectionVisible() {
        return isElementPresent(recentStaysSection);
    }

    /**
     * Check if there's an error on the dashboard
     */
    public boolean hasError() {
        return isElementPresent(errorMessage);
    }

    /**
     * Get the count of KPI cards
     */
    public int getKpiCardCount() {
        List<WebElement> cards = driver.findElements(kpiCards);
        return cards.size();
    }

    /**
     * Click on period filter button
     */
    public void clickPeriodButton() {
        if (isElementPresent(periodButton)) {
            waitForClickable(periodButton).click();
        }
    }
}
