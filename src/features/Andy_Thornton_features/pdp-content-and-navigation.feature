@regression
Feature: PDP content and navigation

  # Built 2026-09-30 from a live inspection of staging. PDP.feature checks
  # the elements are there; this opens them and follows the links.
  #
  # The accordion renders twice (a desktop and a hidden mobile copy), so the
  # mappings here are scoped to :visible.

  Background:
    Given I am on the "pdp" page
    And I click on the "Allow all cookies" button if present
    And I wait for the page to settle


  Scenario: Only one accordion section is open at a time
    Then the "accordion triggers" accordion should allow only one section open at a time


  Scenario: The Description section shows the product description
    Then the "open accordion content" should contain the text "The Vienna Side Chair"


  Scenario: The Specifications section shows the product dimensions
    When I click on the "Specifications tab" element
    Then the "open accordion content" should contain the text "Height:"
    And the "open accordion content" should contain the text "Stackable"


  Scenario: The Downloads section lists documents that resolve
    When I click on the "Downloads tab" element
    Then the "downloads links" should be displayed
    And all "downloads links" links should resolve without an error


  Scenario: A "Frequently bought together" product opens its own PDP
    When I click on the "first frequently bought together product" element
    Then I should eventually be redirected to the "product" page
    And the "product name" should be displayed
    And the "product price" should contain the text "£"


  Scenario: A viewed product appears under "Recently viewed" on the next PDP
    When I navigate directly to the path "/products/oskar-dining-chair-atan0647"
    Then the "recently viewed" should contain the text "Vienna Stackable Side Chair"


  Scenario: The quantity chosen on the PDP is carried into the basket
    When I click on the "quantity plus" button
    Then the "quantity input" should equal the value "2"
    When I click on the "Add to basket" button
    And I wait for the page to settle
    And I am on the "basket" page
    Then the "basket item name" should contain the text "Vienna Stackable Side Chair"
    And the "quantity input" should equal the value "2"
