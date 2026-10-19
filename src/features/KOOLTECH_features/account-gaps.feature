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
    And I click on the "Accept cookies" button if present
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

    # The address book only shows 4 cards per section until "View more" is
    # clicked - confirmed live on release-2-19-0 (2026-09-28): with other
    # test addresses on the account, the new card lands past the first 4 and
    # its Delete link is hidden.
    When I click on the "View more delivery addresses" element if present
    And I click on the "TestAuto delete link" element
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
    And I click on the "Accept cookies" button if present
    # Searches for whichever order is listed first rather than a fixed
    # number: the list is filtered to a rolling date range, so a hardcoded
    # order (000522) aged out and started failing on 2026-09-28 on both
    # staging and release-2-19-0.
    When I remember the text of "first order number" as "order to search"
    And I fill in the "order number search input" input field with the remembered "order to search"
    Then the "orders table" should contain the remembered "order to search"

    When I fill in the "order number search input" input field with "999999999"
    Then the "orders table" should contain the text "Sorry, no results found for your search."

  @smoke
  Scenario: The account email address cannot be edited
    Given I am navigating the page as a "quotes user 2" user
    And I am on the "account-profile" page
    And I click on the "Accept cookies" button if present
    Then the "account email field" should not be enabled

  Scenario: Changing password is rejected when the new password and its confirmation don't match
    Given I am navigating the page as a "quotes user 2" user
    And I am on the "account-profile" page
    And I click on the "Accept cookies" button if present
    When I click on the "Change Password link" element
    And I fill in the "existing password field" input field with "wrong-on-purpose"
    And I fill in the "new password field" input field with "NewPassword123!"
    And I fill in the "repeat new password field" input field with "DifferentPassword123!"
    And I click on the "Save Changes button" element
    Then the "password mismatch error" should be displayed
