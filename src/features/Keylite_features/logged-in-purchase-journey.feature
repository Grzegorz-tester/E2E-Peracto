@regression
Feature: Logged-in purchase journey

  # CONFIRMED live 2026-09-06: differs from guest-purchase-journey.feature
  # at the sign-in step, not the address step as first thought - a
  # logged-in checkout still lands on "/checkout/sign-in" (same route as
  # guest), but its content is just a "you are currently logged in as
  # <email>" confirmation with a single "Continue" button, no guest/
  # existing-customer choice. From there it reaches "/checkout/delivery"
  # showing this account's real saved addresses (checkout-select-address)
  # to pick from, rather than the guest address-entry form.
  #
  # CONFIRMED SITE BUG, live, reproduced across many separate runs and
  # click strategies (plain, forced, JS-dispatched, with an "if present"
  # fallback): clicking "checkout-select-address__continue-button" NEVER
  # advances past "/checkout/delivery" for a logged-in customer, even
  # though the button reports as genuinely enabled and one address (this
  # account's own default) is already pre-selected before any click at all
  # - confirmed via direct inspection outside this framework too, not just
  # a flaky selector/timing issue on this suite's side. This account
  # already has several real saved addresses (same ones seen in
  # my-account.feature's address book). The equivalent GUEST journey
  # (guest-purchase-journey.feature) completes this same step and the rest
  # of checkout through to Review & Pay without issue, which is what makes
  # this look like a genuine logged-in-specific regression on Keylite's
  # side, not a problem with this test - worth reporting to Keylite's own
  # team rather than working around further here.
  #
  # Same "not yet completed: payment" gap as guest-purchase-journey.feature
  # applies here too - see that file's comment for detail.

  Scenario: A logged-in user can add a window to basket and reach Review & Pay with the right order details
    Given I am navigating the page as a "logged in" user
    And I navigate directly to the path "/products/ray-lux-flat-glass-with-kerb"
    And I dismiss the newsletter popup if present
    When I click on the "1st" "variant lozenge options" element
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I wait for the page to settle

    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Checkout" element
    Then I should be redirected to the "checkout-sign-in" page

    When I click on the "Signed-in continue" button
    Then I should be redirected to the "checkout-delivery" page

    When I click on the "1st" "saved address" element via JavaScript
    And I wait for the page to settle
    And I click on the "1st" "saved address continue" element via JavaScript
    And I wait for the page to settle
    And I click on the "saved address continue" button if present
    Then I should be redirected to the "checkout-billing" page

    When I wait for the page to settle
    And I click on the "1st" "same as delivery checkbox" element via JavaScript
    And I wait for the page to settle
    And I click on the "1st" "Billing continue" element via JavaScript
    Then I should be redirected to the "checkout-review" page
    And the "review content" should be displayed
    And the "review product name" should contain the text "ray.lux"
    And the "review product price" should be displayed
