@regression
Feature: Logged-in purchase journey

  # New coverage (2026-10-05). The shared test account (account number
  # 103128, "Fred") is a trade account, but checkout still pays by card via
  # Opayo - there is no pay-on-account option. Its saved address is in Leeds
  # (LS10 1AA), outside JT Dove's delivery area, so the logged-in journey
  # uses Click & Collect: PDP CLICK & COLLECT -> branch picker ("SELECT THIS
  # BRANCH", listed by stock) -> basket -> /checkout/sign-in (already signed
  # in, CONTINUE) -> /checkout/click-and-collect -> /checkout/billing (saved
  # address) -> Review & Pay -> Opayo -> thank-you.
  #
  # WARNING: places a REAL Click & Collect order on staging every run.
  @places-real-order
  Scenario: Logged-in customer can buy a product for Click & Collect
    Given I require staging for this scenario
    And I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I wait for the page to settle
    And I clear the basket
    When I am on the "test-product" page
    And I wait for the page to settle
    And I click on the "CLICK & COLLECT" button
    And the "Select this branch" should be displayed within "30" seconds
    And I click on the "Select this branch" element
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    Then the "collect at branch heading" should be displayed
    When I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    And the "logged in as" should contain the "logged in" user's email
    And I click on the "Signed in Continue" button
    Then I should eventually be redirected to the "checkout-click-and-collect" page
    And I wait for the page to settle
    And the "click and collect branch" should contain the text "JT Dove"
    And I fill in the "contact mobile" input field with "07700900000"
    When I click on the "Click and collect Continue" button
    Then I should eventually be redirected to the "checkout-billing" page
    And I wait for the page to settle
    When I click on the "Saved address Continue" button
    Then I should eventually be redirected to the "checkout-review" page
    And I wait for the page to settle
    And the "review collection branch" should be displayed
    And the "review product name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    When I click on the "PROCEED TO PAYMENT" button
    And I pay with the "default" Opayo test card
    Then I should eventually be redirected to the "thank-you" page
    And the "order reference" should be displayed
    And the "order line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
