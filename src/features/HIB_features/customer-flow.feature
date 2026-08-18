@smoke
@regression
Feature: Product purchase flow

  # Ported from the Insinkerator_EU guest/logged-in purchase journeys
  # (src/features/Insinkerator_EU_features/logged-in-purchase-journey.feature)
  # and adjusted for HIB's single-page basket + finalise-order checkout.
  #
  # IMPORTANT: never create real orders for the HIB project (see README).
  # Unlike the Insinkerator_EU journeys this is ported from, this scenario
  # deliberately stops right before clicking finalise-order.json's
  # "PLACE ORDER" button (data-testid="proceed-to-payment"), which submits
  # a real payment - it only confirms that button is reached and enabled.

  Scenario: User can proceed through checkout up to (but not including) placing the order
    Given I am on the "home" page
    And I dismiss the newsletter popup if present

    When I click on the "Portal" icon
    Then I should be redirected to the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "home" page

    When I fill in the "Search products" input field with "Solas"
    And I wait for the search results to update
    And I click on the "first search result" element
    Then I should be redirected to the "solas" page
    And I click on the "first variant" button
    And I click on the "Add to basket" button

    When I click on the "Place Order" button
    Then I should be redirected to the "place-order" page
    And the "basket item" should be displayed

    When I click on the "PLACE ORDER" button
    Then I should be redirected to the "finalise-order" page

    When I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    Then the "PO Number" should be displayed

    When I fill in the "Phone" input field with "07377777777"
    And I fill in the "PO Number" input field with "1"
    And I click on the "Continue" button
    And I click on the "Billing Address" element
    And I click on the "Continue" button
    Then the "PLACE ORDER" should be displayed
    And the "PLACE ORDER" should be enabled
