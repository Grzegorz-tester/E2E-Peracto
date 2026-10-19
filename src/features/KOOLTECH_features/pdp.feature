@smoke
@regression
Feature: Product Detail Page (PDP)

  # From KOOL-2026-08-17.json regression suite, "Smoke Tests > Product Detail
  # Page (PDP)" (cases 529-531).
  #
  # Both basket scenarios below wait for the page to settle right after
  # adding to basket - confirmed live, navigating to "basket" with no wait
  # is a real race that empties the basket 3/3 times.
  #
  # NOTE: pricing and "Add to basket" on this trade site are gated per
  # product, AND confirmed live to be intermittent even for the same
  # product/session combination (e.g. the JAV-1071 hose set showed a price
  # as a guest once, then didn't on two later attempts minutes apart -
  # looks like a real staging-side pricing/stock service flakiness, not a
  # selector issue). Logged-in access to the cable product below was
  # reliable across every attempt, so these run as the "logged in" user
  # rather than as a guest.

  Scenario: PDP loads with accurate information and images
    Given I am navigating the page as a "logged in" user
    And I am on the "cable-pdp" page
    And I click on the "Accept cookies" button if present
    Then the "page title" should be displayed
    And the "page title" should contain the text "SY"
    And the "product price" should be displayed

  Scenario: PDP - Add product to basket
    Given I am navigating the page as a "logged in" user
    And I am on the "cable-pdp" page
    And I click on the "Accept cookies" button if present
    When I slowly click on the "Add to basket" button
    And I wait for the page to settle
    And I am on the "basket" page
    Then the "basket header title" should be displayed
    And the "no items message" should not be displayed

  # KOOL-531's manual wording says "increase quantity on the PDP", but this
  # PDP has no quantity stepper - only an implicit qty-1 "Add to basket".
  # Quantity is adjustable on the basket page instead, matching the
  # sibling HIB project's basket.feature pattern.
  #
  # "cable-pdp" is sold in 100m drums with a minimum order quantity of 100
  # (confirmed live on the product's own packaging image and by the basket
  # snapping an entered "3" back to "100") - so the quantity entered here
  # must be a multiple of 100, not an arbitrary small number.
  Scenario: PDP - Increase quantity and validate totals
    Given I am navigating the page as a "logged in" user
    And I am on the "cable-pdp" page
    And I click on the "Accept cookies" button if present
    When I slowly click on the "Add to basket" button
    And I wait for the page to settle
    And I am on the "basket" page
    When I fill in the "Quantity selector" input field with "200"
    And I click on the "Update" button
    Then the "Quantity selector" should equal the value "200"
    And the "product's total price" should be displayed
