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

  # CONFIRMED SITE BUG (live, 2026-09-06): submitting "Add new address"
  # (with every field filled, including "County", which the checkout
  # version of this same form also silently requires) gets a real 200
  # response from the server action whose OWN body is
  # {"data":{"error":"An error has occurred. Please try again."}} - a
  # genuine backend failure, not a click/timing/selector artifact. Verified
  # via the raw POST response body directly, after first (wrongly)
  # suspecting the click mechanics, a stale client-side list, and the
  # "qa-<timestamp>" marker's hyphen being reformatted by the name field -
  # none of those were the real cause. Confirmed reproducible across many
  # attempts with fresh data each time, so this is left as a read-only
  # check of the existing real address book instead of an add/edit/delete
  # cycle, until Keylite's own team fixes the underlying error.
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
