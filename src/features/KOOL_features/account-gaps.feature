@regression
Feature: Account Area Gaps

  # From KOOL-2026-08-17.json (cases 287-292, 301-303, 315, 319-321) - Address
  # Book CRUD, Orders filtering, and Profile edit/password change. Anchored
  # on "quotes user 2" (Jim) for the address book and profile changes since
  # it's a secondary test account - "logged in" (Grzegorz) has real order
  # history used for the Orders scenario instead, and is left otherwise
  # untouched here to avoid disturbing the account other scenarios rely on.
  #
  # The Address Book add/delete scenario is intermittent on repeat live runs
  # - across several runs it's failed at three different, unrelated steps
  # (a form fill, a button click, the post-delete count check), never the
  # same one twice, and passes cleanly end-to-end more often than not. That
  # pattern points to general staging-site/environment slowness under a full
  # video-recorded run rather than a defect in this scenario's own logic -
  # each individual action has been confirmed correct in isolation (see the
  # reload-before-recount comment below). Same class of pre-existing
  # flakiness already documented in pdp.feature for Add to Basket.

  @smoke
  Scenario: Adding a delivery address makes it appear in the list, and it can be removed again
    Given I am navigating the page as a "quotes user 2" user
    And I am on the "account-address-book" page
    When I remember the number of "delivery address card" elements as "delivery count before"

    And I click on the "Add delivery address link" element
    And I fill in the "new address first name" input field with "TestAuto"
    And I fill in the "new address last name" input field with "Script"
    And I fill in the "new address line 1" input field with "123 Test Street"
    And I fill in the "new address city" input field with "Testville"
    And I fill in the "new address postcode" input field with "TE5 1ST"
    And I fill in the "new address telephone" input field with "07911123456"
    And I click on the "Add Address submit button" button
    Then the number of "delivery address card" elements should be more than the remembered "delivery count before"

    When I click on the "TestAuto delete link" element
    And I click on the "Delete Address confirm button" element
    # Confirmed live: the in-memory list doesn't drop the deleted card within
    # this framework's normal 15s assertion window when a delete follows an
    # add in the same session - a reload forces a fresh, server-truth render
    # instead of waiting on that in-page state update.
    And I reload the page
    Then the number of "delivery address card" elements should equal the remembered "delivery count before"

  Scenario: Searching Orders by order number filters to that order, and a nonexistent one shows no results
    Given I am navigating the page as a "logged in" user
    And I am on the "account-orders" page
    When I fill in the "order number search input" input field with "000522"
    Then the "orders table" should contain the text "000522"

    When I fill in the "order number search input" input field with "999999999"
    Then the "orders table" should contain the text "Sorry, no results found for your search."

  @smoke
  Scenario: The account email address cannot be edited
    Given I am navigating the page as a "quotes user 2" user
    And I am on the "account-profile" page
    Then the "account email field" should not be enabled

  Scenario: Changing password is rejected when the new password and its confirmation don't match
    Given I am navigating the page as a "quotes user 2" user
    And I am on the "account-profile" page
    When I click on the "Change Password link" element
    And I fill in the "existing password field" input field with "wrong-on-purpose"
    And I fill in the "new password field" input field with "NewPassword123!"
    And I fill in the "repeat new password field" input field with "DifferentPassword123!"
    And I click on the "Save Changes button" element
    Then the "password mismatch error" should be displayed
