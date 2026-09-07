@regression
Feature: PDP blinds configurator (Use Product Size)

  # Keylite's blackout-blinds PDP (and presumably every other blind
  # product) reuses the EXACT SAME product-configurator component as the
  # window PDP's "Build & Buy" wizard (product-configurator.feature) -
  # confirmed live 2026-09-06 via identical data-testid prefixes
  # (product-configurator__group-0-option-N, __next-step, __add-to-basket,
  # __product-price). The differences are: 6 steps here (Size -> Colour ->
  # Operation -> Surround -> Window Material -> Review) instead of 4, the
  # wizard-open trigger is labelled "Use Product Size" not "Build & Buy",
  # and Step 1 has NO option cards at all - it's a genuine data lookup, not
  # a selection.
  #
  # CONFIRMED SITE BEHAVIOUR (not a bug, a real product constraint):
  # blackout blinds are made to fit an EXISTING Keylite window, so Step 1
  # requires that window's own real serial number (or a "product size"
  # code, via the adjacent "Use product size" tab - not covered here) to
  # look up its dimensions before any blind options can be chosen - there
  # is no generic "just pick a size" path. A real serial number has to
  # come from a genuine installed window (Peracto Admin's Size Finder tab,
  # /size-finder, holds real serial-number/window-code/dimension records
  # pulled from real installs - "1100160000014" -> window code "04A",
  # 780mm x 780mm, confirmed live 2026-09-06). If this serial ever stops
  # resolving (real data can change), pull a fresh one from Size Finder
  # rather than guessing a new one.
  #
  # CONFIRMED SITE QUIRKS (same class of issue as the window PDP):
  # - Step 1's content area shows a loading spinner for several seconds
  #   before the real serial-code input renders - a plain click-then-fill
  #   without waiting for the input to actually exist times out.
  # - Every clickable element in this wizard (the "Use Product Size"
  #   trigger, group-0-option-N cards, Next, Add to basket) needs the
  #   JS-dispatch click variant - a real (even forced) mouse click
  #   silently does nothing, same sticky-gallery-overlap class of issue as
  #   the window PDP.
  # - Advancing past Step 1 straight after filling the serial number can
  #   silently no-op once (an "acted before client state was ready" race,
  #   same class already documented elsewhere in this repo) - the new
  #   "... via JavaScript, retrying until the X is displayed" step
  #   (click.ts) re-clicks Next only until "configurator options" actually
  #   appears, rather than blindly clicking twice (risky here specifically
  #   because Next is the SAME persistent element on every step, so a
  #   blind second click would double-advance on a run where the first
  #   click already worked). Steps 2-5 didn't show this same flakiness in
  #   testing, so they use a single click.
  # - The running summary sidebar ("configurator summary total",
  #   product-configurator__product-price) is present on every step EXCEPT
  #   the final Review step, where it's replaced by
  #   product-configurator__product-review--product-name/-price (same
  #   testids the window PDP's Review step uses, already mapped as
  #   "configurator review product name"/"... price") - checking the
  #   wrong one on Review reports "no element matched" even though the
  #   page is genuinely fine.

  Scenario: Configuring a blind for a real window and adding it to basket
    Given I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/blackout-blinds"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "Use Product Size" element via JavaScript
    Then the "size serial number" should be displayed

    When I dismiss the newsletter popup if present
    And I fill in the "size serial number" input field with "1100160000014"
    And I click on the "1st" "configurator next step" element via JavaScript, retrying until the "configurator options" is displayed

    # Step 2: Colour
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript

    # Step 3: Operation
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript

    # Step 4: Surround
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript

    # Step 5: Window Material
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator options" element via JavaScript
    And I click on the "1st" "configurator next step" element via JavaScript

    # Step 6: Review
    Then the "configurator review product name" should be displayed
    And the "configurator review product price" should be displayed
    When I dismiss the newsletter popup if present
    And I click on the "1st" "configurator add to basket" element via JavaScript
    And I wait for the page to settle
    And I am on the "basket" page
    Then the "basket item" should be displayed
    And the "basket item name" should contain the text "Blackout Blinds"

  # CONFIRMED live 2026-09-06: a serial number that doesn't match any real
  # window silently keeps the wizard on Step 1 - no visible error message,
  # but genuinely no progress either (Next never advances). This is a
  # deliberate, minimal check of that gate, not a claim about what error
  # copy (if any) the site should show - none was found.
  Scenario: An unrecognised serial number does not unlock the next step
    Given I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/blackout-blinds"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "Use Product Size" element via JavaScript
    Then the "size serial number" should be displayed

    When I dismiss the newsletter popup if present
    And I fill in the "size serial number" input field with "0000000000000"
    And I click on the "1st" "configurator next step" element via JavaScript
    And I wait for the page to settle
    Then the "size serial number" should be displayed

  Scenario: Requesting a free swatch sample opens the enquiry form
    Given I am navigating the page as a "guest" user
    And I navigate directly to the path "/products/blackout-blinds"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "Request a FREE swatch sample" element via JavaScript
    Then the "swatch request form" should be displayed
