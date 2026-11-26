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
    # Smoke case 17: availability is shown, and the main image really loaded
    # (a broken image optimiser after the Next.js 16 upgrade, AT-201, would
    # still leave a visible empty box).
    And the "stock message" should be displayed
    And the "product image" image should have loaded

  Scenario: Verify adding a product to the basket
    Given I am on the "pdp" page
    And I click on the "Allow all cookies" button if present
    # 2026-11-24: an early click before hydration silently did nothing (empty
    # basket), so let the PDP settle first. Not a retry: it could double-add.
    And I wait for the page to settle
    When I click on the "Add to basket" button
    # Waits for the add to commit (the "added to basket" panel) before leaving the PDP.
    Then the "added to basket heading" should be displayed
    And I wait for the page to settle
    And I am on the "basket" page
    Then the "basket item name" should contain the text "Vienna Stackable Side Chair"
    # Smoke case 18: the right SKU at a real price.
    And the "basket item sku" should contain the text "ATFUOF1104"
    And the "basket item price" should contain the text "£"
    When I remember the price in "basket item price" as "unit price"
    Then the price in "basket item total" should equal the remembered "unit price" times 1
