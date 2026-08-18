@regression
Feature: Guest checkout - VAT number field

  # Migrated from P3Playwright watco/tests/basket-checkout/uk/guest-checkout-vat-field.test.ts
  # WAT-335 - VAT registration number field, guest checkout (UK).
  #
  # NOT YET AUTOMATED here either (documented, not stubbed, matching the
  # source):
  # - Order placed successfully / confirmation-page VAT display: completing
  #   payment needs a real Adyen card/3DS flow in a cross-origin iframe, and
  #   Pay on Account is unusable for a guest's first low-value order (site
  #   enforces a £500 minimum - see the last step below).
  # - Confirmation email content: no email-reading infrastructure exists in
  #   this repo.
  #
  # CONFIRMED SITE BEHAVIOUR (source repo): the "Enter address manually"
  # link's click handler is occasionally not bound yet the instant the
  # step renders, so the first click can do nothing - the source retries
  # with a second click ONLY if the manual fields didn't appear within 5s
  # (this link toggles the fields open/closed, so an unconditional second
  # click would risk closing them again). No generic "retry only if a
  # DIFFERENT element didn't appear" step exists in this framework yet -
  # left as a single click for now; add that retry as a bespoke step if
  # this proves flaky live, rather than guessing at an unconditional
  # workaround that could make it worse.

  Scenario: VAT field is visible with the correct label and placeholder, Apply starts disabled, and both payment methods are offered
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to basket" button
    And I click on the "basket header link" element
    And I click on the "Checkout now" button
    And I click on the "guest checkout toggle" element
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "guest email submit" button
    Then I should be redirected to the "checkout-delivery" page

    When I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "Test"
    And I fill in the "Telephone" input field with "07700900000"
    And I click on the "Enter address manually" link
    And I fill in the "Address line 1" input field with "1 Test Street"
    And I fill in the "City" input field with "London"
    And I fill in the "Postcode" input field with "SW1A 1AA"
    And I select the "United Kingdom" option from the "Country" dropdown
    And I click on the "accordion continue" element
    Then the "first shipping option" should be displayed

    When I check the "first shipping option"
    And I click on the "accordion continue" element
    Then the "VAT number" should be displayed

    Then the "VAT number" should have attribute "placeholder" with value "GB123456789"
    And the "VAT number label" should be displayed
    And the "VAT apply" should not be enabled
    And the "VAT number comment" should not be displayed

    When I remember the text of "VAT summary amount" as "vat before"
    And I remember the text of "order summary total" as "total before"
    And I fill in the "VAT number" input field with "GB123456789"
    And I click on the "VAT apply" button
    Then the "VAT number" should not have class "is-invalid"
    And the "VAT number" should equal the value "GB123456789"
    And the "VAT summary amount" text should equal the remembered "vat before"
    And the "order summary total" text should equal the remembered "total before"

    Then the "Pay by card" should be displayed
    And the "Pay on Account" should be displayed

    When I check the "Pay on Account"
    Then the "payment on account minimum order notice" should be displayed
