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
  # UPDATED (2026-09-14): now operates on a disposable user created fresh
  # in the Background (via user-management.feature's "Add User" flow) and
  # deleted again at the end of the scenario, rather than the shared
  # "admin" login account used previously. The "admin" account's own
  # address book accumulates real addresses over repeated regression runs
  # and can genuinely run out of a safely-freeable one for the
  # retry-once-if-needed logic below to use (confirmed live, Keylite
  # ADMIN_RELEASE, 2026-09-14: the account had 11 addresses, but only one
  # was tagged "Delivery" and it had no other type to fall back on) - a
  # brand-new user has zero addresses, so add/edit/delete always exercises
  # the real flow without ever needing the one-per-type workaround at all.
  # Previously operated on the SAME account this scenario itself logs in
  # as (the "admin" user's own email, filtered on the Users list) rather
  # than an arbitrary other user - CONFIRMED LIVE (2026-08-31): a Peracto
  # Admin "Users" list mixes real staff/admin accounts with different
  # roles (UserAdmin/AdminUser/User), and at least one such account
  # (MIPA's own "Peracto Support" UserAdmin seed user) is a protected
  # system account the backend API genuinely refuses to add an address to
  # - which is exactly why this feature creates its own user rather than
  # picking "whichever user happens to be first" in the list.
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
  # twice; root cause narrowed further live on MIPA_ADMIN_RELEASE 2.8.0,
  # 2026-09-08): MIPA's admin API rejects a BILLING address-create attempt
  # with a 403 "Access Denied" whenever the account already has one - NOT
  # a blanket billing permission ban, but a genuine one-billing-address-
  # per-user LIMIT, misreported as a 403 instead of a proper validation
  # error. Reproduced against BOTH the protected system user above AND
  # the ordinary admin login user this scenario operates on; a DELIVERY
  # address-create with the exact same account/fields/flow always
  # succeeds (201, no such limit), and Carbon has no such limit on either
  # type (identical billing request there succeeds with 201 even with an
  # existing billing address) - so this is a MIPA-specific, billing-only
  # count limit, not a blanket permissions gap.
  #
  # Rather than let the Billing example just fail on MIPA (which is what
  # a test account with a pre-existing default billing address hits every
  # time), "I add a new ... address, remembering its last name as ... and
  # any freed-up address as ..., retrying once if needed" (admin-address-
  # book.ts) treats this as a real, working-as-designed limit to test
  # around: if the first create attempt doesn't persist, it finds whatever
  # existing address is "using" the type under test, removes just that
  # type from it (keeping any other type it also has), retries the create
  # once, and remembers which address it borrowed from. The matching "I
  # restore ... to the address remembered as ..., if any was freed" step
  # at the end puts it back, leaving the account exactly as it started.
  # For any tenant without this limit (Carbon, the common case) the very
  # first attempt already persists and both steps are a no-op - this is a
  # generic safety net, not a MIPA-specific branch, so it needs no
  # per-tenant tagging per CLAUDE.md's shared-suite conventions.
  #
  # NOTE (2026-09-14): the one-billing-address-per-user LIMIT above is
  # still real, but now that Background creates a brand-new, zero-address
  # user per run, the very first create attempt should always persist -
  # this retry/free-capacity path exists as a defensive fallback (in case
  # a fresh user is ever seeded with a default address, or the limit turns
  # out to apply some other way) rather than the everyday path it used to
  # be against the shared "admin" account's accumulating address book.
  #
  # CONFIRMED LIVE (2026-08-31): a rejected create does NOT stop the
  # address from appearing to save - Peracto Admin's UI updates the
  # address list OPTIMISTICALLY on the client before the API call
  # resolves, so a naive "should appear" check alone would pass even when
  # the write was rejected server-side. The "I add a new ... address ..."
  # step above always reloads before deciding whether an attempt actually
  # persisted, rather than trusting the optimistic render, and the
  # scenario's own subsequent "When I reload the page" / "Then ... should
  # appear" pair does the same for the edit/delete steps that follow.
  #
  # CONFIRMED (live, HIB_ADMIN release branch, 2026-09-12, per the user):
  # both Billing and Delivery address-create failed outright on HIB even
  # after the retry-once/free-capacity logic above - a HARD block, not a
  # per-type count limit like MIPA's. Root cause: the admin login user's
  # own account had a "User Group" assigned (Users > All Users > Edit >
  # Customer > "User Group" field) - a DIFFERENT field from "Roles"
  # (Admin/User) and from the separate "User Groups" nav item, easy to
  # conflate. Clearing "User Group" back to unset on that account (via
  # "Clear Value" next to the field) let both scenarios pass end-to-end.
  # No test-side change needed - this is account configuration, not a
  # step/mapping gap - but flag it if HIB's test admin account ever gets
  # a User Group reassigned, since it'll silently reintroduce this exact
  # failure on both address types.

  Background:
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Users" element
    And I click precisely on the "All Users" element
    And I click precisely on the "Add User" element
    And I fill in the "User First Name" input field with "Velstar"
    And I fill in the "User Last Name" input field with a unique value, remembering it as "disposable user name"
    And I fill in the "User Email" input field with a unique email, remembering it as "disposable user email"
    And I fill in the "User Account Number" input field with a unique value if present
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I click precisely on the "Users" element
    And I click precisely on the "All Users" element
    And I fill in the "Email filter" input field with the remembered "disposable user email"
    And I click precisely on the "Apply" element
    And I click precisely on the "first item link" element

  Scenario Outline: Adding, editing and then deleting a <address type> address

    When I add a new "<address type>" address, remembering its last name as "address marker" and any freed-up address as "freed capacity marker", retrying once if needed:
      | title      | Mr              |
      | first name | Velstar         |
      | line 1     | 123 Test Street |
      | city       | Leeds           |
      | postcode   | LS1 1AA         |
      | country    | United Kingdom  |
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

    When I restore "<address type>" to the address remembered as "freed capacity marker", if any was freed

    When I click precisely on the "Delete User" element
    And I click precisely on the "Confirm Delete User" element
    Then the "success toast" should be displayed

    Examples:
      | address type |
      | Billing      |
      | Delivery     |
