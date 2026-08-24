@MIPA_regression
Feature: Product Detail Page (PDP)

  # New coverage (previously none existed) - confirmed live against a
  # fixed, known product (Mipa 2K HS F37 Filler, SKU 229510000) so price/
  # UOM assertions stay deterministic across runs.

  Scenario: PDP loads with accurate information and images
    Given I am on the "test-product" page
    Then the "product title" should be displayed
    And the "product title" should contain the text "Mipa 2K HS F37 Filler"
    And the "product SKU" should contain the text "229510000"
    And the "product image" should be displayed


  Scenario Outline: PDP - Add product to basket using different UOMs
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    When I click on the "<uom>" element
    And I click on the "Add to basket" button
    Then the "added to basket modal" should be displayed
    Examples:
      | uom      |
      | EACH UOM |
      | BOX OF 6 UOM |


  Scenario: PDP - Increase quantity and validate basket totals
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I click on the "Clear Basket" button if present
    When I am on the "test-product" page
    And I click on the "EACH UOM" element
    When I click on the "Quantity increment" element
    And I click on the "Quantity increment" element
    Then the "Quantity input" should equal the value "3"
    When I click on the "Add to basket" button
    And I click on the "Checkout" element
    Then I should be redirected to the "basket" page
    And the "order total price" should contain the text "36.69"


  Scenario: PDP - Create a wishlist and add a product to it
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    When I click on the "Add to List" button
    Then the "added to list modal" should be displayed


  Scenario: PDP - Guest user cannot see prices and can submit an enquiry
    Given I am navigating the page as a "guest" user
    And I am on the "test-product" page
    Then the "guest sign in prompt" should be displayed
    And the "Add to Enquiry" should be displayed
