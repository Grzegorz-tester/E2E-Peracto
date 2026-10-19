@regression
Feature: Projects and articles

  # Built 2026-09-30 from a live inspection of staging.

  Scenario Outline: The "<path>" listing shows article cards, and one opens its article
    Given I navigate directly to the path "<path>"
    And I click on the "Allow all cookies" button if present
    Then the "article cards" should be displayed
    When I click on the "first article card" element
    Then I should eventually be redirected to the "article" page
    And the "page not found" should not be displayed
    And the "page title" should be displayed

    Examples:
      | path                             |
      | /articles/projects               |
      | /articles/news-from-the-workshop |
