@regression
Feature: Verify PDP functionality

  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): a
  # Cookiebot cookie-consent banner covers the lower half of the viewport
  # on a fresh browsing context that's never given consent before, and
  # intercepts clicks/reads on anything under it (e.g. "Add to basket") -
  # confirmed via a false-empty basket afterwards. Dismissed with the
  # generic "if present" escape hatch so this is a no-op wherever the
  # banner doesn't appear (e.g. staging, or a context that already has a
  # stored consent cookie).
  #
  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14): even
  # with the banner dismissed, navigating straight to "basket" right after
  # clicking "Add to basket" can still land on a genuinely empty basket -
  # the same race already confirmed on MIPA's basket (see "I wait for the
  # page to settle", navigation.ts): a fast automated navigation can beat
  # the add-to-basket request's own completion. "I wait for the page to
  # settle" (networkidle + 1s buffer) before navigating away fixes it.

  Scenario: Verify PDP elements
    Given I am on the "pdp" page
    And I click on the "Allow all cookies" button if present
    Then the "product image" should be displayed
    And the "product name" should be displayed
    And the "product SKU" should be displayed
    And the "product price" should be displayed
    And the "quantity picker" should be displayed
    And the "Add to basket" should be displayed
    And the "Description tab" should be displayed
    And the "Specifications tab" should be displayed
    And the "Downloads tab" should be displayed

  Scenario: Verify adding a product to the basket
    Given I am on the "pdp" page
    And I click on the "Allow all cookies" button if present
    When I click on the "Add to basket" button
    And I wait for the page to settle
    And I am on the "basket" page
    Then the "basket item name" should contain the text "Vienna Stackable Side Chair"
