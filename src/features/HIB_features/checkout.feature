@regression
Feature: Checkout validation (no order placed)

  # NEVER place an HIB order, on any environment (staging, release or
  # production) - none of these scenarios gets as far as the final PLACE
  # ORDER ([data-testid='proceed-to-payment']). customer-flow.feature covers
  # the happy path up to (but not including) that click; this covers the
  # validation along the way.
  #
  # Confirmed live on feature-hib-170 (2026-09-29): the Delivery step's
  # Phone and PO Number are both required, and the site enforces it by
  # keeping CONTINUE disabled until both are filled, rather than by showing
  # an error message - so that's what's asserted here.

  Background:
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "place-order" page
    And I fill in the "Search products" input field with "Vanquish"
    And I wait for the search results to update
    And I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "basket item" should be displayed
    When I click on the "PLACE ORDER" button
    Then I should eventually be redirected to the "finalise-order" page
    When I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    Then the "PO Number" should be displayed


  Scenario: CONTINUE stays disabled while both Phone and PO Number are empty
    When I fill in the "Phone" input field with ""
    And I fill in the "PO Number" input field with ""
    Then the "Continue" should not be enabled


  Scenario: CONTINUE stays disabled with a Phone number but no PO Number
    When I fill in the "Phone" input field with "07377777777"
    And I fill in the "PO Number" input field with ""
    Then the "Continue" should not be enabled


  Scenario: CONTINUE stays disabled with a PO Number but no Phone number
    When I fill in the "Phone" input field with ""
    And I fill in the "PO Number" input field with "VELSTAR TEST"
    Then the "Continue" should not be enabled


  Scenario: CONTINUE is enabled once both Phone and PO Number are filled
    When I fill in the "Phone" input field with "07377777777"
    And I fill in the "PO Number" input field with "VELSTAR TEST"
    Then the "Continue" should be enabled
