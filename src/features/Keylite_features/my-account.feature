@regression
Feature: Operations in the user's account

  # CONFIRMED live 2026-09-06: unlike MIPA, Keylite's own email field is
  # NOT disabled - it's a genuinely editable field here, so this checks
  # what's actually true (enabled, pre-filled) rather than assuming MIPA's
  # non-editable-email pattern applies everywhere. "Save Changes" itself is
  # DISABLED until a field is genuinely edited (same dirty-state gating as
  # the PDP's Add to Basket button elsewhere in this suite), so this only
  # checks it renders, not that it's enabled with nothing changed yet.
  Scenario: Profile fields are present and pre-filled
    Given I am navigating the page as a "logged in" user
    When I am on the "account-profile" page
    And I dismiss the newsletter popup if present
    Then the "Email" should be enabled
    And the "Email" should not equal the value ""

    And the "First name" should be enabled
    And the "First name" should not equal the value ""

    And the "Last name" should be enabled
    And the "Save Changes" should be displayed

  # CONFIRMED SITE BUG (live, 2026-09-06, RE-CONFIRMED 2026-09-23):
  # submitting "Add new address" gets a 200 from the server action whose
  # own body is {"data":{"error":"An error has occurred. Please try
  # again."}}. Re-checked after the checkout "site bug" in this suite turned
  # out to be a test gap: this one is real. The captured request payload is
  # well-formed (every field filled, values read back unchanged right
  # before Save, country "GBR") and it fails with or without a basket, so
  # it's the backend rejecting a valid address - left as a read-only check
  # until Keylite's team fixes it.
  # SEPARATE, SMALLER BUG seen in the same payload: the form mangles the
  # postcode before sending it ("SW1A 2AA" was sent as "SW 1 A 2 AA",
  # "LE18 2HX" as "LE 18 2 HX") - worth reporting alongside the above.
  Scenario: The address book shows this account's saved addresses
    Given I am navigating the page as a "logged in" user
    When I am on the "account-address-book" page
    And I dismiss the newsletter popup if present
    Then the "address entry" should be displayed
    And the "address line 1" should be displayed
    And the "address postcode" should be displayed

  # CONFIRMED live 2026-09-06: this test account has real past orders (a
  # flat, read-only table - no per-row detail page to drill into).
  Scenario: The orders table is present
    Given I am navigating the page as a "logged in" user
    When I am on the "account-orders" page
    And I dismiss the newsletter popup if present
    Then the "orders table" should be displayed

  # CONFIRMED live 2026-09-23: "Save Changes" stays disabled until a field
  # is actually edited (dirty-state gating), and the form renders two
  # visible copies of it - hence "nth=0" in account-profile.json. A unique
  # number per run (not a fixed one) so a failed run that never reached the
  # restore step can't leave the saved value equal to the next run's
  # "new" value, which would keep Save disabled on every run after.
  Scenario: Changing the profile contact number persists after a reload, and can be restored
    Given I am navigating the page as a "logged in" user
    When I am on the "account-profile" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    And I remember the value of the "Contact number" input field as "original contact number"
    And I fill in the "Contact number" input field with a unique UK mobile number, remembering it as "new contact number"
    Then the "Save Changes" should be enabled
    When I click on the "Save Changes" button
    Then the "profile alert" should contain the text "User successfully updated"
    When I reload the page
    And I wait for the page to settle
    Then the "Contact number" input field should have the remembered "new contact number"
    When I fill in the "Contact number" input field with the remembered "original contact number"
    And I click on the "Save Changes" button
    Then the "profile alert" should contain the text "User successfully updated"

  # Order rows have no link - the <tr> itself is clickable and opens
  # /account/orders/<id>. Needs at least one past order on this account
  # (logged-in-purchase-journey.feature places one every run).
  @requires-order-history
  Scenario: Opening an order from the order history shows that order's details
    Given I am navigating the page as a "logged in" user
    When I am on the "account-orders" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    And I remember the text of "first order reference" as "order number"
    And I click on the "1st" "first order row" element via JavaScript
    Then I should be redirected to the "account-order-detail" page
    And the "order reference" should contain the remembered "order number"
    And the "order product name" should be displayed

  Scenario: Signing out ends the session
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    And I click on the "Sign Out" button
    And I wait for the page to settle
    And I navigate directly to the path "/account"
    Then I should eventually be redirected to the "login" page
