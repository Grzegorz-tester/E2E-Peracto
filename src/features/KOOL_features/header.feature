@regression
Feature: Header

  # From KOOL-2026-08-17.json, "Storefront > Header" (cases 410-418, 432).
  # Category/account link navigation itself is already covered by
  # navigation-menu.feature - this covers the remaining header-specific
  # triggers: the logo, the utility bar's Contact Us/tel links, and signing
  # in/out via the utility bar.

  @smoke
  Scenario: The header logo links back to the homepage
    Given I am on the "air-conditioning-plp" page
    When I click on the "header logo" element
    Then I should be redirected to the "home" page

  Scenario: The utility bar's Contact Us link is a mailto that opens in a new tab
    Given I am on the "home" page
    Then the "Contact Us link" should have attribute "href" with value "mailto:sales@kooltech.co.uk"
    And the "Contact Us link" should have attribute "target" with value "_blank"

  Scenario: The utility bar's telephone link is a tel: link
    Given I am on the "home" page
    Then the "tel link" should have attribute "href" with value "tel:03450344179"

  @smoke
  Scenario: A guest can reach Sign In and Register from the utility bar
    Given I am on the "home" page
    When I click on the "Sign In" element
    Then the current URL should contain "/login"

    Given I am on the "home" page
    When I click on the "Register utility link" element
    Then the current URL should contain "/register"

  @smoke
  Scenario: A logged-in user can sign out via the utility bar
    Given I am navigating the page as a "logged in" user
    And I am on the "home" page
    Then the "logged in welcome message" should contain the text "You're signed in."

    When I click on the "Sign Out" element
    Then the "Sign In" should be displayed
