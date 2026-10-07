@regression
Feature: Checkout validation

  # New coverage (2026-10-05), confirmed live. None of these scenarios
  # places an order - the order-placing journeys are customer-flow.feature
  # (guest, delivery) and logged-in-purchase-journey.feature (Click &
  # Collect). Runs as a guest so each scenario starts with a fresh basket.

  Background:
    Given I am navigating the page as a "guest" user
    And I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds


  # SUSPECTED SITE ISSUE (2026-10-05): during exploration the "GO TO
  # CHECKOUT" button in the added-to-basket panel did nothing - the page
  # stayed on the PDP - while the basket page's own checkout button works.
  # This scenario retries the click, so if it still fails the button is
  # genuinely broken rather than racing hydration.
  Scenario: Added-to-basket panel's checkout button opens the checkout
    When I click on the "Go to checkout from drawer" element, retrying until redirected to the "checkout-sign-in" page


  Scenario: Guest checkout rejects an invalid email address
    Given I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    When I click on the "Guest checkout option" element, retrying until the "guest email" is displayed
    And I fill in the "guest email" input field with "not_an_email@"
    And I click on the "Continue as guest" button
    Then the "guest email" input should be rejected as invalid
    And I should be redirected to the "checkout-sign-in" page


  Scenario: Existing customer can sign in from the checkout
    Given I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    When I click on the "Existing customer option" element, retrying until the "checkout login email" is displayed
    And I fill in the "checkout login email" input field with the "logged in" user's email
    And I fill in the "checkout login password" input field with the "logged in" user's password
    And I click on the "checkout login submit" button
    # Signing in here completes the step and moves straight on to delivery
    # (confirmed live 2026-10-07), so the sign-in panel itself is gone.
    Then I should eventually be redirected to the "checkout-delivery" page
    And the "checkout signed in banner" should be displayed


  Scenario: An address outside the delivery area offers no delivery option
    Given I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    And I click on the "Guest checkout option" element, retrying until the "guest email" is displayed
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "Continue as guest" button
    And I should eventually be redirected to the "checkout-delivery" page
    And I wait for the page to settle
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I pick the first Loqate address for the postcode "LS17 9LF" in the "address search" field
    And I click on the "Use this address" button
    Then the "outside delivery area message" should be displayed
    And the "Dove Delivery option" should not be displayed
    And the "Delivery Continue" should not be enabled


  Scenario: Delivery step needs a contact mobile number before continuing
    Given I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    And I click on the "Guest checkout option" element, retrying until the "guest email" is displayed
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "Continue as guest" button
    And I should eventually be redirected to the "checkout-delivery" page
    And I wait for the page to settle
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I pick the first Loqate address for the postcode "NE46 4DQ" in the "address search" field
    And I click on the "Use this address" button
    And I click on the "Dove Delivery option" element
    Then the "estimated arrival" should be displayed
    And the "Delivery Continue" should not be enabled
    And the "delivery continue hint" should contain the text "Please enter a contact number to continue."
    When I fill in the "contact mobile" input field with "07700900000"
    Then the "Delivery Continue" should be enabled


  Scenario: Back to Basket leaves the checkout
    Given I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    When I click on the "Back to Basket" element, retrying until redirected to the "basket" page
    Then the "basket line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
