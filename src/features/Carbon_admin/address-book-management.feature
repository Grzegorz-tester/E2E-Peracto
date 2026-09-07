@regression @mutates-admin-data
Feature: Adding, Editing And Deleting A Billing Or Delivery Address

  # Shared Peracto Admin boilerplate, but WRITES real data (adds, edits,
  # then deletes an address) - unlike this folder's read-only filtering
  # scenarios, this is NOT safe against a tenant with a production admin
  # (e.g. KOOL_ADMIN_PROD.env, which also points at this shared folder).
  # Two independent safeguards, neither relying on the other:
  # - Tagged @mutates-admin-data, which src/index.ts's productionExclusion
  #   automatically strips from every profile whenever a project's env
  #   sets UI_AUTOMATION_HOST=production.
  # - "I require a staging admin for this scenario" (admin-address-book.ts)
  #   independently re-checks the same env var at runtime and refuses to
  #   proceed, so a missing tag or misconfigured filter still can't mutate
  #   production data.
  #
  # Operates on the SAME account this scenario itself logs in as (the
  # "admin" user's own email, filtered on the Users list) rather than an
  # arbitrary other user, matching CLAUDE.md's "editing the test user's
  # own account is fine" rule already applied elsewhere in this suite -
  # CONFIRMED LIVE (2026-08-31): a Peracto Admin "Users" list mixes real
  # staff/admin accounts with different roles (UserAdmin/AdminUser/User),
  # and at least one such account (MIPA's own "Peracto Support" UserAdmin
  # seed user) is a protected system account the backend API genuinely
  # refuses to add an address to - picking "whichever user happens to be
  # first" would have hit that at random rather than a real, actionable
  # account.
  #
  # CONFIRMED (live, Carbon Admin staging, 2026-08-31):
  # - "Address Type" is a MULTI-select react-select (Billing and Delivery
  #   are independent checkable options, confirmed via an existing
  #   address on Carbon tagged with both at once) - the existing "...
  #   react-select" step's exact-text option match works for it
  #   unmodified, since each option is still picked individually.
  # - "Country" only ever offers one option ("United Kingdom") with no
  #   typing/search needed, unlike the Orphaned Pages menu's "Select
  #   Item" react-select in content-creation.feature - so the plain "...
  #   react-select" step is enough here too, no async-search variant
  #   needed.
  # - Each saved address renders as a read-only `<address>` block with its
  #   own Edit button as a following SIBLING (not a child) - "I click the
  #   'Edit' button for the address containing the remembered ..." step
  #   (admin-address-book.ts) finds the right one by that marker rather
  #   than assuming position, since a real account can already have many
  #   unrelated addresses (confirmed live: 26 on Carbon's own shared test
  #   account).
  # - Add/Edit both POST to the same /addresses endpoint from the UI's
  #   own perspective (an "edit" of a not-yet-saved address is really
  #   just resubmitting the create) - confirmed 201 Created on add, 200
  #   OK (a real PUT) on a subsequent edit of an already-saved one.
  #
  # CONFIRMED SITE BUG - MIPA_ADMIN only (live, 2026-08-31, reproduced
  # twice): MIPA's admin API rejects a BILLING address-create attempt
  # with a 403 "Access Denied", against BOTH the protected system user
  # above AND the ordinary admin login user this scenario actually
  # operates on - reproduced with a well-formed request body, so this is
  # a genuine backend permissions issue on MIPA specifically, not a
  # selector/config gap (the identical request against Carbon succeeds
  # with 201). Narrower than it first looked: a DELIVERY address-create
  # with the exact same account, fields and flow succeeds fine (201,
  # "Address saved successfully!") - so this is specifically a billing-
  # address permission gap on MIPA, not a blanket "can't create any
  # address" one. The Billing example row below will legitimately fail
  # on MIPA_ADMIN until that's fixed server-side; Delivery is expected to
  # keep passing there - flagged separately, not worked around here.
  #
  # CONFIRMED LIVE (2026-08-31): the 403 above does NOT stop the address
  # from appearing to save - Peracto Admin's UI updates the address list
  # OPTIMISTICALLY on the client before the API call resolves, so "the
  # remembered ... should appear" alone still passes even when the write
  # was rejected server-side, silently turning MIPA's real bug into a
  # false-positive pass. Each add/edit is followed by "When I reload the
  # page" before re-checking, forcing a fetch of what the server actually
  # persisted rather than trusting the optimistic render - this is what
  # makes the scenario genuinely fail on MIPA instead of passing hollow.

  Background:
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Users" element
    And I click precisely on the "All Users" element
    And I fill in the "Email filter" input field with the "admin" user's email
    And I click precisely on the "Apply" element
    And I click precisely on the "first item link" element

  Scenario Outline: Adding, editing and then deleting a <address type> address

    When I click precisely on the "Add New Address" element
    And I select the "<address type>" option from the "Address Type" react-select
    And I select the "Mr" option from the "Address Title" react-select
    And I fill in the "Address First Name" input field with "Velstar"
    And I fill in the "Address Last Name" input field with a unique value, remembering it as "address marker"
    And I fill in the "Address Line 1" input field with "123 Test Street"
    And I fill in the "Address City" input field with "Leeds"
    And I fill in the "Address Postcode" input field with "LS1 1AA"
    And I select the "United Kingdom" option from the "Address Country" react-select
    And I click precisely on the "Save Address" element
    Then the remembered "address marker" should appear in the "address entry" element

    When I reload the page
    Then the remembered "address marker" should appear in the "address entry" element

    When I click the "Edit" button for the address containing the remembered "address marker"
    And I fill in the "Address Last Name" input field with a unique value, remembering it as "updated address marker"
    And I click precisely on the "Save Address" element
    Then the remembered "updated address marker" should appear in the "address entry" element

    When I reload the page
    Then the remembered "updated address marker" should appear in the "address entry" element

    When I click the "Edit" button for the address containing the remembered "updated address marker"
    And I click precisely on the "Delete Address" element
    And I click precisely on the "Confirm Delete Address" element
    Then the remembered "updated address marker" should not appear in the "address entry" element

    Examples:
      | address type |
      | Billing      |
      | Delivery     |
