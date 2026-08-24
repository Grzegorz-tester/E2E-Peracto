@MIPA_regression
Feature: Quick Order - CSV Upload

  # New coverage (previously none existed). The Quick Order CSV uploader
  # lives directly on the basket page - confirmed live, sample file format
  # is "sku,quantity,unitOfMeasure" (see src/features/fixtures/).
  #
  # Note: "CSV upload compresses quantities to closest available UOM"
  # (the other Quick Order smoke test) needs the "Compress Quick Buy
  # Basket UOM" admin setting confirmed on for this account first - not
  # verified here since it requires Peracto admin access, out of scope
  # for this pass.

  Scenario: Upload a CSV with a valid and an invalid SKU
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I clear the basket
    When I upload the "mipa-quick-order-valid-and-invalid-skus.csv" file to the "CSV file input" input
    Then the "CSV upload error banner" should contain the text "INVALID-SKU-999999"
    And the "basket item" should be displayed
    And the "order total price" should contain the text "24.46"


  Scenario: Upload a CSV with multiple valid SKUs loads them all into the basket
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I clear the basket
    When I upload the "mipa-quick-order-multiple-valid-skus.csv" file to the "CSV file input" input
    Then the "basket contents" should contain the text "229510000"
    And the "basket contents" should contain the text "246910000"
    And the "basket contents" should contain the text "246810003"


  # Distinct from the "invalid SKU" case above - this is a structurally
  # broken row (a required field missing outright), which the site
  # rejects with a different message before it even tries to look up
  # a SKU - confirmed live.
  Scenario: Upload a CSV with a missing required field triggers an error
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I clear the basket
    When I upload the "mipa-quick-order-missing-fields.csv" file to the "CSV file input" input
    Then the "CSV structural error banner" should be displayed
    And the "no items message" should be displayed


  Scenario: Clearing the basket empties it
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    And I click on the "EACH UOM" element
    And I click on the "Add to basket" button
    And I click on the "Checkout" element
    Then I should be redirected to the "basket" page
    When I click on the "Clear Basket" button
    Then the "no items message" should be displayed


  # Reuses the same Payment on Account checkout flow already proven in
  # customer-flow.feature, just starting from a CSV-populated basket
  # instead of a PDP add-to-basket - confirms Quick Order items are real,
  # orderable basket lines, not a display-only preview.
  Scenario: An order can be placed from a basket populated via CSV upload
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I clear the basket
    When I upload the "mipa-quick-order-valid-and-invalid-skus.csv" file to the "CSV file input" input
    And I click on the "Checkout" button
    Then I should be redirected to the "checkout" page
    When I click on the "Delivery method" element
    And I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    And I click on the "Courier delivery option" element
    And I click on the "Continue" button
    And I click on the "Billing Address" element
    And I click on the "Continue" button
    When I fill in the "PO Number" input field with "Velstar Test"
    And I click on the "Terms and conditions checkbox" element
    And I click on the "PLACE ORDER" button
    Then I should be redirected to the "thank-you" page
    And the "basket header title" should contain the text "Thank you for your order"
