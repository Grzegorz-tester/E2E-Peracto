@regression @mutates-admin-data
Feature: Editing Existing Pages, Articles, Templates and Elements

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - Pages/Articles/Elements are standard Peracto Admin
  # Content entities, confirmed present via the same nav testids in every
  # admin tenant's own dashboard.json/common.json. Same edit-and-restore
  # shape as editing-existing-entities.feature and
  # editing-attributes-and-config.feature, for the same reason: to exercise
  # the same save/serialisation code path that editing-existing-entities.
  # feature's Category scenario caught a real "id" type-coercion bug in.
  # Each of these is a REAL, pre-existing entity, so every scenario
  # remembers the field's original value first and restores it at the end.
  # Not yet live-verified against every tenant individually; each tenant's
  # own regression run will surface any real gap.
  #
  # Toast behaviour on saving an EXISTING Page/Article/Element varies by
  # tenant, unlike Category/Promotion/Product: CONFIRMED (live, MIPA_ADMIN
  # staging, 2026-09-09) MIPA shows NO success toast at all (checked for
  # 4s after a genuinely-successful save, verified via reload) - but
  # CONFIRMED (live, Andy Thornton, 2026-09-10) Andy Thornton DOES show
  # one for the same action. Since it can't be relied on universally,
  # these scenarios only assert on the persisted value (the same
  # adjustment already made for Products' own edit step in
  # product-management.feature), not a "should contain success toast"
  # check that would fail on MIPA.
  #
  # CONFIRMED (live, Andy Thornton AT-171 admin release branch, 2026-09-10):
  # on this tenant, "Save content" ([data-testid='content-save']) exists in
  # the DOM but stays hidden until a dropdown trigger, "Open save menu"
  # ([data-testid='content-dropdown-save']), is clicked first - a two-step
  # save flow, not a missing/broken button. Carbon_admin's own common.json
  # already had this "Open save menu" key defined (predating this file's
  # promotion) but nothing exercised it until now. MIPA's admin uses a
  # different, always-visible save button instead (confirmed live: zero
  # content-dropdown-save elements on MIPA's real page) - added "Open save
  # menu" as a harmless key to every tenant's common.json (resolves fine,
  # matches nothing where the dropdown doesn't exist) and an "if present"
  # click before every "Save content" click below, so both save UIs work
  # without a tenant-specific branch in the scenario itself.
  #
  # CONFIRMED (live, Andy Thornton AT-171 admin release branch, 2026-09-10):
  # since this suite can't rely on a toast existing (see above - MIPA has
  # none), nothing was forcing a wait between the "Save content" click and
  # the next "I reload the page". Confirmed live this is a genuine race,
  # not a real bug: reload() fires while the save's own client-side
  # redirect (.../<id>, see below) is still in flight, and one navigation
  # aborts the other ("page.reload: net::ERR_ABORTED; maybe frame was
  # detached?"), intermittently (Page/Element hit it in one run, Article
  # didn't, on the exact same page/save mechanism) - manually reproducing
  # the same edit live confirmed the save itself genuinely works every
  # time, toast or not. Fixed with "I wait for the page to settle"
  # (networkidle + 1s buffer) before every reload in this file, rather
  # than waiting on a toast that isn't universal.
  #
  # The Page scenario below uses the same generic "first item link"
  # pattern as Article/Element (not a hardcoded content ID) so it's
  # portable across tenants. Known issue: on MIPA specifically, the FIRST
  # row of the Pages list (id 60, "Category Slug Test page") cannot be
  # saved at all - "Slug should only contain numbers, hyphens and
  # lowercase letters..." (its own stored slug contains a "/", which fails
  # current validation on ANY save attempt) - so this scenario is expected
  # to fail for MIPA until that data bug is fixed, per this suite's
  # "assert reality" approach (see tasks.feature's Inactive-task scenario
  # for the same reasoning). A Template scenario asserting a similar
  # MIPA-specific known bug ("Templates can only support a single row")
  # was deliberately NOT promoted here, since it bakes in a
  # currently-broken result as the expected one - not safe to assume for
  # every tenant. See MIPA_ADMIN_features/content-known-issues.feature.

  Scenario: Editing an existing Page's name persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Content Name" input field as "original page name"
    And I fill in the "Content Name" input field with a unique value, remembering it as "new page name"
    And I click precisely on the "Open save menu" element if present
    And I click precisely on the "Save content" element

    When I wait for the page to settle
    And I reload the page
    Then the "Content Name" input field should have the remembered "new page name"

    When I fill in the "Content Name" input field with the remembered "original page name"
    And I click precisely on the "Open save menu" element if present
    And I click precisely on the "Save content" element

    When I wait for the page to settle
    And I reload the page
    Then the "Content Name" input field should have the remembered "original page name"


  Scenario: Editing an existing Article's heading persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Articles" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Article Heading" input field as "original article heading"
    And I fill in the "Article Heading" input field with a unique value, remembering it as "new article heading"
    And I click precisely on the "Open save menu" element if present
    And I click precisely on the "Save content" element

    When I wait for the page to settle
    And I reload the page
    Then the "Article Heading" input field should have the remembered "new article heading"

    When I fill in the "Article Heading" input field with the remembered "original article heading"
    And I click precisely on the "Open save menu" element if present
    And I click precisely on the "Save content" element

    When I wait for the page to settle
    And I reload the page
    Then the "Article Heading" input field should have the remembered "original article heading"


  Scenario: Editing an existing Element's name persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Elements" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Content Name" input field as "original element name"
    And I fill in the "Content Name" input field with a unique value, remembering it as "new element name"
    And I click precisely on the "Open save menu" element if present
    And I click precisely on the "Save content" element

    When I wait for the page to settle
    And I reload the page
    Then the "Content Name" input field should have the remembered "new element name"

    When I fill in the "Content Name" input field with the remembered "original element name"
    And I click precisely on the "Open save menu" element if present
    And I click precisely on the "Save content" element

    When I wait for the page to settle
    And I reload the page
    Then the "Content Name" input field should have the remembered "original element name"
