@smoke
@regression
Feature: Product purchase flow

  # Ported from the Insinkerator_EU guest/logged-in purchase journeys
  # (src/features/Insinkerator_EU_features/logged-in-purchase-journey.feature)
  # and adjusted for HIB's single-page basket + finalise-order checkout.
  #
  # IMPORTANT: never create real orders for the HIB project (see README).
  # Unlike the Insinkerator_EU journeys this is ported from, this scenario
  # deliberately stops right before clicking finalise-order.json's
  # "PLACE ORDER" button (data-testid="proceed-to-payment"), which submits
  # a real payment - it only confirms that button is reached and enabled.

  Scenario: User can proceed through checkout up to (but not including) placing the order
    Given I am on the "home" page
    And I dismiss the newsletter popup if present

    When I click on the "Portal" icon
    Then I should be redirected to the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    # 2026-09-28: on feature-hib-170 the Portal link sends you to
    # /login?to=/account, so signing in from it now lands on My Account
    # rather than the homepage (confirmed live) - go back home to search.
    # 2026-09-29: retry the Sign In click rather than clicking once.
    # Confirmed live: the login form's onSubmit calls react-google-recaptcha-v3's
    # executeRecaptcha(), which is still undefined for a moment after the
    # client-side Portal -> /login navigation, so an immediate click throws
    # "TypeError: h is not a function" and silently stays on /login (7/8
    # attempts failed with no delay; 6/6 passed with ~0.5s settle). The
    # compound login step never hit this because it does a full page load
    # plus the newsletter-popup wait first.
    And I click on the "Sign In" button, retrying until redirected to the "account" page
    Then I should eventually be redirected to the "account" page
    When I am on the "home" page

    When I fill in the "Search products" input field with "Solas"
    And I wait for the search results to update
    And I click on the "first search result" element
    Then I should eventually be redirected to the "solas" page
    # The redirect check passes on the client-side URL change, before the
    # PDP (~6s to load on feature-hib-170) has rendered - confirmed live
    # 2026-09-28: clicking the variant + Add to basket 0.3s later left the
    # basket at (0). Direct loads work either way; this is the search-result
    # navigation path only.
    And I wait for the page to settle
    And I click on the "first variant" button
    # Add to basket stays disabled until this session's basket exists -
    # confirmed live 2026-09-28: two POST /baskets fire after the PDP renders
    # and a click before then is a silent no-op (basket stays at 0).
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button

    When I click on the "Place Order" button
    Then I should be redirected to the "place-order" page
    And the "basket item" should be displayed

    When I click on the "PLACE ORDER" button
    Then I should be redirected to the "finalise-order" page

    When I click on the "Continue" button
    And I click on the "Delivery Address" element
    And I click on the "Continue" button
    Then the "PO Number" should be displayed

    When I fill in the "Phone" input field with "07377777777"
    And I fill in the "PO Number" input field with "1"
    And I click on the "Continue" button
    And I click on the "Billing Address" element
    And I click on the "Continue" button
    Then the "PLACE ORDER" should be displayed
    And the "PLACE ORDER" should be enabled
