@regression
Feature: PDP window configurator (Build & Buy)

  # Keylite's bespoke "Build & Buy" journey - a 4-step wizard (Size ->
  # Opening Operation -> Kerb Type -> Review), distinct from the simpler
  # always-visible quick-select widget covered in basket.feature. Whichever
  # step is active, its options render under the SAME selector prefix
  # (product-configurator__group-0-option-N - only one step's group is ever
  # in the DOM at once), so a single generic "pick the first option, go
  # next" loop works for every step without needing step-specific mappings.
  #
  # CONFIRMED live 2026-09-06 (full scenario passing end to end): the
  # wizard's own steps, live running summary and Review screen all render
  # and update correctly, and "Review" -> Add to Basket genuinely lands the
  # configured window in the basket.
  #
  # CONFIRMED SITE QUIRK: every option/next-step/add-to-basket click here
  # uses the "... via JavaScript" (raw DOM click) variant, not a normal
  # mouse click - the configurator's option cards and its Next/Add to
  # Basket buttons sit beneath the sticky product-gallery panel at this
  # suite's viewport size, so a real (even forced) mouse click at those
  # coordinates lands on the gallery's chevron-left arrow instead, silently
  # doing nothing. Unlike the animating-overlay overlap documented elsewhere
  # in this codebase, this is a static layout overlap that waiting/scrolling
  # doesn't resolve - see the new "... element via JavaScript" step in
  # click.ts. The Mailchimp newsletter popup also re-appears/blocks clicks
  # mid-wizard, not just on first page load, so it's dismissed before every
  # step rather than once.

  Scenario: Completing the Build & Buy wizard adds the configured window to the basket
    Given I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "Build & Buy" button
    Then the "product-configurator" should be displayed

    # Step 1: Size
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript

    # Step 2: Opening Operation
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript

    # Step 3: Kerb Type
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript

    # Step 4: Review
    Then the "configurator review product name" should be displayed
    And the "configurator review product price" should be displayed
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator add to basket" element via JavaScript
    And I wait for the basket update to complete
    And I am on the "basket" page
    Then the "basket item" should be displayed

  # CONFIRMED live 2026-09-23: "configurator options" used to match FOUR
  # elements per option (the option <button> plus its name/price/
  # description spans all share the group-0-option- prefix), so "2nd"
  # silently hit option 1's own name span - every scenario above only ever
  # chose the first, £0.00 option. Now scoped to the <button> in pdp.json.
  # The running total only moves when Next is pressed, not on the option
  # click itself (£835.20 -> +£104.40 for 600x900 -> +£488.40 for Manual =
  # £1,428.00 at the time of writing - compared via remembered values, not
  # hardcoded, so a price change doesn't break it).
  Scenario: Choosing priced options raises the total, and the basket charges the Review price
    Given I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "Build & Buy" button
    Then the "product-configurator" should be displayed
    When I remember the text of "configurator summary total" as "base total"
    And I dismiss the newsletter popup if present
    And I click on the "2nd" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript
    Then the "configurator summary total" text should not equal the remembered "base total"
    When I remember the text of "configurator summary total" as "size total"
    And I dismiss the newsletter popup if present
    And I click on the "2nd" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript
    Then the "configurator summary total" text should not equal the remembered "size total"
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript
    Then the "configurator review product name" should be displayed
    When I remember the text of "configurator review product price" as "review price"
    And I dismiss the newsletter popup if present
    And I click on the "1st" "configurator add to basket" element via JavaScript
    And I wait for the basket update to complete
    And I am on the "basket" page
    And I wait for the page to settle
    Then the "basket item price" should contain the remembered "review price"
    And the "basket item" should contain the text "600X900"
    And the "basket item" should contain the text "Manual"
