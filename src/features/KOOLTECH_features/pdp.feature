@smoke
@regression
Feature: Product Detail Page (PDP)

  # From KOOL-2026-08-17.json regression suite, "Smoke Tests > Product Detail
  # Page (PDP)" (cases 529-531).
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

  # 2026-11-22: "PDP - Add product to basket" and "PDP - Increase quantity and
  # validate totals" removed, covered by basket.feature (Background add-to-basket
  # from cable-pdp, @smoke quantity-200 Update recalculates the total).
