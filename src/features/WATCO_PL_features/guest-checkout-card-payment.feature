@regression
@places-real-order
Feature: Guest checkout - card payment (PL)

  # Coverage gap found 2026-10-24: no Watco scenario placed a GUEST order,
  # and only PL completed an Adyen card payment (every other market's real
  # orders go through logged-in Pay on Account). This is the main consumer
  # revenue path, so it is covered end to end on every market.
  #
  # Per-market rather than in WATCO_SHARED_features because the delivery
  # address (country name, postcode format) is market-specific test data
  # and shared Gherkin carries no locale text. Keep the steps identical to
  # the other markets' copies; only the address block differs.
  #
  # Places a REAL order on staging with the Adyen test card (staging runs
  # Adyen in test mode, no 3-D Secure challenge). Customer name is
  # "Velstar Test" so the order is identifiable as test data.
  #
  # PL only offers card: its "Pay by card" radio is pre-checked and hidden
  # (confirmed live 2026-10-24), so it is asserted rather than clicked.

  Scenario: A guest can pay by card and reaches the order confirmation page
    Given I require staging for this scenario
    And I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I am on the "basket" page
    And I click on the "Checkout now" button
    And I click on the "guest checkout toggle" element
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "guest email submit" button
    Then I should be redirected to the "checkout-delivery" page

    When I fill in the "First name" input field with "Velstar"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Telephone" input field with "500000000"
    And I click on the "Enter address manually" link, retrying until the "Address line 1" appears
    And I fill in the "Address line 1" input field with "Testowa 1"
    And I fill in the "City" input field with "Warszawa"
    And I fill in the "Postcode" input field with "00-001"
    And I select the "Polska" option from the "Country" dropdown
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "first shipping option" should be displayed

    When I check the "first shipping option"
    And I click on the "accordion continue" element, removing the "cookie preference centre overlay" overlay if it interferes
    Then the "Pay by card" radio button should be checked
    And I remember the text of "order summary total" as "total before payment"

    When I check the "Adyen terms", retrying until it is checked
    And I fill in the Adyen test card details
    And I click on the "Adyen pay button" button
    Then I should be redirected to the "checkout-thanks" page
    And the "order total" text should equal the remembered "total before payment"
