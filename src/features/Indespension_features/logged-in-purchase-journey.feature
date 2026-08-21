@smoke
@regression
Feature: Logged-in purchase journey

  # Full rewrite - the previous version clicked a "Portal" icon that was
  # never mapped to anything (an HIB "trade portal" concept with no
  # equivalent here), expected a post-login redirect to "home" instead of
  # the real /account, and completed checkout via a PO-Number/Account-
  # Number single-page flow that doesn't exist on this site... except it
  # turned out that flow DOES genuinely exist, just not for every account.
  # Confirmed live (2026-08-21): the "logged in" test account is set up as
  # a trade/credit customer, and Indespension's checkout - for THIS
  # account - reaches a "Pay on Account" step requiring a mandatory PO
  # Number, with no card gateway involved at all. So the old PO-Number
  # flow wasn't pure HIB contamination; this project genuinely has it for
  # credit-terms customers (see checkout.ts's Adyen step comment - "Pay on
  # Account" is an established cross-project concept, not an HIB one-off).
  # Guest/non-credit customers instead reach a real card payment step
  # (GlobalPayments hosted fields - see checkout.feature), which is
  # currently blocked by a staging gateway config gap, unlike this one.
  #
  # WARNING: completes a REAL order on staging every time it runs (Pay on
  # Account, no money actually moves - it's an invoice-style payment, not
  # a live card charge). Fine per this repo's staging rules (Indespension
  # is not HIB) but don't repeat needlessly across retries/configs.

  Scenario: Logged-in trade customer can search, add to basket, and complete an order via Pay on Account
    Given I am on the "home" page
    When I click on the "Sign In button" link
    Then I should be redirected to the "login" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page
    # This is a real account with a server-side basket that persists across
    # runs (unlike a guest's always-fresh session) - clearing it first is
    # what makes the "checkout item count" assertion below reliable.
    When I am on the "basket" page
    And I clear the basket
    And I click on the "header logo" element
    Then I should be redirected to the "home" page
    When I fill in the "Search bar" input field with "Blueline"
    And I click on the "1st" "search result" element
    Then I should be redirected to the "blueline-trailer-pdp" page
    # Confirmed live (2026-08-21) on this same PDP: the click can silently
    # no-op if the button's handler isn't hydrated yet - retrying against
    # the real success signal rather than a fixed sleep (see checkout.feature
    # for the same finding written up in full).
    And I click on the "Add to basket" button, retrying until the "added to basket confirmation" appears
    When I click on the "Go to Checkout" button
    Then I should be redirected to the "checkout" page
    And the "checkout item count" should contain the text "1"
    And the "order total price" should be displayed

    # Sign-in step: already logged in, just confirm and move on.
    When I click on the "sign-in continue" button
    Then I should be redirected to the "checkout-delivery" page
    # Delivery step has two sub-stages: pick a saved address, then phone +
    # delivery option. The account's default saved address is used as-is.
    When I click on the "Address continue" button
    And I fill in the "Phone number" input field with "07377777777"
    And I click on the "Delivery method continue" button
    Then I should be redirected to the "checkout-billing" page

    # Unlike guest checkout (a "same as delivery" checkbox over a manual
    # address form), an account customer's Billing step shows the same
    # saved-address picker as Delivery - the default address is already
    # selected, so this is just another "Address continue".
    When I click on the "Address continue" button
    Then I should be redirected to the "checkout-review" page
    And the "review content" should be displayed

    When I fill in the "PO Number" input field with "VELSTAR TEST"
    And I check the "delivery fee acknowledgement"
    And I click on the "Place order" button
    Then I should be redirected to the "checkout-thank-you" page
    And the "order reference" should be displayed
