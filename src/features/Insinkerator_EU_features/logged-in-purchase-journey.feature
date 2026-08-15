@regression
Feature: Logged-in purchase journey

  # Ported from P3Playwright's insinkerator_eu/tests/basket-checkout/
  # logged-in-purchase-journey.test.ts.
  #
  # WARNING: this scenario completes a REAL CyberSource test-mode payment
  # and creates a REAL, permanent order on staging every time it runs. The
  # source suite deliberately limits this to once per execution, not
  # repeated across retries/configs - do the same here.
  #
  # NOTE: the source test clicks whichever product is first in the "Shop"
  # category. That's catalog-order-dependent - live-verified here that the
  # current first item (/products/standard-460) is a configurable-bundle
  # PDP requiring configurator selections before "Add to basket" appears,
  # which this suite doesn't yet handle (see basket-interactions.feature).
  # Category navigation is still exercised for real below; the actual
  # purchase then proceeds with the same known-simple product used by
  # guest-purchase-journey.feature, to avoid depending on which specific
  # product the catalog happens to sort first.

  @smoke
  Scenario: User can proceed from PDP through to a completed order
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present
    And I am on the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

    When I am on the "home" page
    And I click on the "Menu" button
    And I choose the "Shop" category from the menu
    Then the "product card" should be displayed

    When I am on the "sink-flange-pdp" page
    And I click on the "Add to basket" button
    And the "added to basket confirmation" should be displayed
    And I click on the "Continue shopping" button
    And the "basket count" should contain the text "1"

    When I am on the "basket" page
    And I click on the "Secure Checkout" button
    And I click on the "sign-in confirmation continue" button if present
    And I click on the "1st" "saved address" element
    And I click on the "Address continue" button
    And I fill in the "Phone number" input field with "07911123456"
    And I click on the "1st" "delivery method option" element
    And I click on the "Delivery method continue" button
    Then I should be redirected to the "checkout-billing" page

    When I click on the "1st" "saved address" element
    And I click on the "Address continue" button
    Then I should be redirected to the "checkout-review" page
    And the "review content" should be displayed

    When I pay with the "default" CyberSource test card
    Then I should be redirected to the "checkout-thank-you" page
    And the "thank you header" should equal text "Thank you for your order"
    And the "order reference" should contain the text "Order No."
    And the "order confirmation email" should contain the "logged in" user's email
