@regression @mutates-admin-data
Feature: User Creation and Deletion

  # New coverage (2026-09-14) - Peracto Admin's "Add User" form had no
  # dedicated coverage before this. Built primarily so
  # address-book-management.feature could stop operating on the shared
  # "admin" login account (whose address book accumulates real addresses
  # over time and can hit a genuine one-address-per-type limit, e.g.
  # MIPA's confirmed one-billing-address-per-user limit, or simply run out
  # of a safely-freeable address as Keylite's account did) and instead run
  # against a disposable, freshly-created user with zero existing
  # addresses - see that feature's Background.
  #
  # LIVE-VERIFIED (2026-09-15, MIPA_ADMIN_RELEASE then cross-checked on
  # Andy Thornton) after fixing 4 real gaps found on the first real run:
  # (1) "User First Name"/"User Last Name" were guessed as "first-name"/
  # "last-name" - the real testids are "firstname"/"lastname" (no hyphen),
  # fixed across every tenant's user-detail.json. (2) The generic "...with
  # a unique value" step produces a bare "qa-<ts>" string, not a valid
  # email - Peracto Admin's Save silently no-ops (no toast, no error, no
  # navigation) when Email fails that validation, easy to misdiagnose as a
  # missing/broken toast. Added a proper "...with a unique email" step
  # (form.ts) instead. (3) MIPA's Add User form ALSO requires an "Account
  # Number" field (a B2B/ERP-only field, not present as a requirement on
  # every tenant) - added a generic "...with a unique value if present"
  # step (form.ts) so this stays a no-op on tenants without it. (4) "Users"/
  # "All Users" (and the rest of the sidebar nav) only resolved on the
  # literal "dashboard" page - they're persistent global chrome, not
  # dashboard-specific, so clicking them again from the "user-detail" page
  # (right after creating a user) failed with "no selector resolved".
  # Merged dashboard.json's nav keys into common.json on every tenant
  # (dashboard.json's own page-scoped copy left in place too - harmless
  # duplication, page-specific lookup still wins). (5) "Delete User" is a
  # plain `<a>` with no data-testid at all - fixed with a text-based XPath
  # (`//a[text()='Delete User']`), matching this suite's own existing
  # precedent for "Delete Address". Does not assume a password field
  # exists at creation - "Reset Password" already existing as a separate
  # action on the Edit User page confirms Peracto Admin invites/resets
  # rather than setting a password inline.

  Scenario: Creating a new user and deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Users" element
    And I click precisely on the "All Users" element
    And I click precisely on the "Add User" element
    And I fill in the "User First Name" input field with "Velstar"
    And I fill in the "User Last Name" input field with a unique value, remembering it as "new user last name"
    And I fill in the "User Email" input field with a unique email, remembering it as "new user email"
    And I fill in the "User Account Number" input field with a unique value if present
    And I fill in the "User Company Name" input field with a unique value if present
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should be displayed

    When I click precisely on the "Users" element
    And I click precisely on the "All Users" element
    And I fill in the "Email filter" input field with the remembered "new user email"
    And I click precisely on the "Apply" element
    And I click precisely on the "first item link" element
    Then the "page heading" should contain the text "Edit User"

    When I click precisely on the "Delete User" element
    And I click precisely on the "Confirm Delete User" element
    Then the "success toast" should be displayed
