@regression
Feature: User Group Business Rules

  # From KOOL-2026-08-17.json, "User Group Cases" (cases 434-460 area) -
  # F-Gas registration gating messaging and account-type-driven UI
  # differences. Qase describes 3 F-Gas variants: guest, logged-in
  # non-F-Gas-registered, and F-Gas-registered. Only the first two are
  # covered here.
  #
  # CONFIRMED SITE GAP (live, 2026-08-19): neither of this project's two
  # available test accounts ("logged in", "quotes user 2") is F-Gas
  # registered, and no F-Gas-certified account exists in this framework's
  # credentials - so the "unlocked" variant (F-Gas-registered user can add a
  # gas product to basket without this warning) cannot be verified. The
  # bottle/environmental surcharge messaging cases in this same Qase suite
  # depend on actually being able to purchase a bottled gas product, blocked
  # by the same missing F-Gas-registered test data - not covered here.
  #
  # Confirmed live: guest and the logged-in non-F-Gas account see the exact
  # same warning and the same "confirm your F Gas registration" link
  # (perhaps notably, that link points to /login even for the already
  # logged-in account - not something this suite changes or asserts on
  # further, just observed as-is).
  #
  # CONFIRMED SITE CONTENT CHANGE (live on production, 2026-09-11):
  # "gas-pdp" (config/KOOL_config/pages.json) pointed at the stale slug
  # /products/r407f, which 404s on production (still resolves on staging -
  # another environment divergence, see navigation-menu.feature). The real
  # current URL is /products/r407f-refrigerant-9kg. Also confirmed live the
  # gating behaves differently by user type: as a GUEST the whole Add to
  # Basket area is replaced by the warning box entirely (no button at all,
  # matching pdp.feature's own note that this site generally doesn't render
  # pricing/purchase controls for guests) - "PDP add to basket" (scoped to
  # exclude the page's own "You may also like" cross-sell cards, which
  # share the generic "Add to basket" testid) settles to 0 matches. As a
  # LOGGED-IN user, the button DOES render, just disabled - confirmed live,
  # "visible, disabled" via the same scoped selector.

  Scenario: A guest sees the F-Gas registration warning and cannot add a gas product to basket
    Given I am on the "gas-pdp" page
    And I click on the "Accept cookies" button if present
    Then the "F-Gas registration warning" should contain the text "F Gas Registration Required"
    And the "PDP add to basket" should not be displayed

  @smoke
  Scenario: A logged-in, non-F-Gas-registered user sees the same warning and gating
    Given I am navigating the page as a "logged in" user
    And I am on the "gas-pdp" page
    And I click on the "Accept cookies" button if present
    Then the "F-Gas registration warning" should contain the text "F Gas Registration Required"
    And the "PDP add to basket" should not be enabled

  # Confirmed live: this project's two test accounts differ in exactly this
  # way - "logged in" (a staff/quote-builder-capable account) sees an
  # Invoices link in its account menu, "quotes user 2" (a plain trade
  # account) doesn't. This is the one concretely testable part of Qase's
  # "invoice visibility by account type" case with the credentials
  # available - it's an account-role difference actually observed, not a
  # confirmed Cash-vs-Credit distinction (which account type each is hasn't
  # been established).
  @smoke
  Scenario: The Invoices account menu link is visible for the staff/quote-builder account
    Given I am navigating the page as a "logged in" user
    And I am on the "account" page
    And I click on the "Accept cookies" button if present
    Then the "Invoices menu item" should be displayed

  @smoke
  Scenario: The Invoices account menu link is not visible for a plain trade account
    Given I am navigating the page as a "quotes user 2" user
    And I am on the "account" page
    And I click on the "Accept cookies" button if present
    Then the "Invoices menu item" should not be displayed
