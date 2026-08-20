@regression
Feature: Header VAT toggle

  # The header's Inc VAT / Ex VAT switch changes displayed prices sitewide
  # and persists across navigation. Runs as the "logged in" user on the
  # "cable-pdp" page - PDP pricing on this trade site is gated per product
  # and confirmed flaky as a guest even for the same product (see
  # pdp.feature's own note), but reliable for this specific page/user
  # combination.

  Background:
    Given I am navigating the page as a "logged in" user
    And I am on the "cable-pdp" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: Toggling Inc VAT / Ex VAT changes the displayed price, and toggling back restores it
    Then the "VAT toggle" should be displayed
    And the "Inc VAT button" should be displayed
    And the "Ex VAT button" should be displayed

    When I remember the text of "product price" as "price with VAT included"
    And I click on the "Ex VAT button" button
    Then the "product price" text should not equal the remembered "price with VAT included"

    When I click on the "Inc VAT button" button
    Then the "product price" text should equal the remembered "price with VAT included"

  Scenario: The VAT preference persists when navigating to another page
    When I click on the "Ex VAT button" button
    And I am on the "air-conditioning-plp" page
    Then the "VAT toggle" radio button should be checked
