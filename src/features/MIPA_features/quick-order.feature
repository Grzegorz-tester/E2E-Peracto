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
    And I click on the "Clear Basket" button if present
    When I upload the "mipa-quick-order-valid-and-invalid-skus.csv" file to the "CSV file input" input
    Then the "CSV upload error banner" should contain the text "INVALID-SKU-999999"
    And the "basket item" should be displayed
    And the "order total price" should contain the text "24.46"
