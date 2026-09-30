@regression @mutates-admin-data
Feature: Creating A Page Or Article Adds It To The Orphaned Pages Menu

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - Pages/Articles and the Orphaned Pages navigation menu are
  # standard Peracto Admin functionality, confirmed present via the same
  # nav testids in every admin tenant's own dashboard.json/common.json, and
  # the same "Create New Page"/"Create New Article"/orphaned-pages selectors
  # (added to the two tenants that were missing them, INSINKERATOR_EU_ADMIN
  # and PIZZAEXPRESSLIVE_ADMIN, to match every other tenant). Tagged
  # @mutates-admin-data with the same "I require a staging admin" runtime
  # guard as address-book-management.feature/editing-existing-entities.
  # feature, for the same reason (see src/index.ts's @mutates-admin-data
  # comment) - this WRITES real data (creates a page/article, adds and
  # removes a menu item, deletes the page/article row), which is only safe
  # on a staging admin, and the shared folder is reused by tenants with a
  # production admin env (e.g. KOOL_ADMIN_PROD.env).
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-08-30):
  # - Only ONE field needs filling - "Page Name" for a Page (content-name),
  #   "Article Heading" for an Article (content-heading) - the slug
  #   (content-slug) auto-generates from it on blur; a separate "Title"
  #   field exists but is genuinely optional, saving fine when left blank.
  # - Saving raises a "Content successfully saved!" success toast and
  #   moves the URL from /content/edit/page/ (or .../article/) to
  #   .../<id> - reloading that URL afterwards still shows the same
  #   title, confirming it genuinely persisted server-side rather than
  #   just rendering optimistically.
  # - Configuration > Navigation > Orphaned pages > "Add Item" opens a
  #   modal with a "Navigation Item Type" react-select (Category/Page/
  #   Article/Article Category/Direct Link/Branch - the existing "...
  #   react-select" step handles this, since its options are already
  #   rendered), then a "Select Item" react-select that is an ASYNC
  #   SEARCH box (starts as "Enter text to begin searching.", not a
  #   pre-populated list) - typing the page/article's own title finds it.
  #   Submitting raises an "Item successfully added!" toast and the new
  #   row appears in the menu tree as "<title> (<slug>)".
  # - The menu can hold many real, unrelated existing items (confirmed
  #   live: 17 pre-existing rows on MIPA's Orphaned Pages menu today), so
  #   verifying/cleaning up must target the row matching OUR OWN title,
  #   never "the first row" or "the only row".
  # - The content editor (both Page and Article) renders full-screen with
  #   NO sidebar at all - confirmed live: none of the "nav-*" testids the
  #   rest of this suite clicks through exist on that page, only its own
  #   "navigate-back" (chevron-left) control, which returns to that
  #   content type's own list (/pages or /articles). Every other admin
  #   page (the list views, Navigation, Orphaned Pages) keeps the normal
  #   sidebar - "Back to list" is only needed once, straight after
  #   leaving the editor.
  # - Cleanup removes the menu item first (Remove Item -> confirm), then
  #   deletes the underlying Page/Article row itself (checkbox -> Delete
  #   Row -> confirm) - same order the data depends on, so repeated
  #   regression runs don't pile up disposable pages/articles or menu
  #   items on any tenant's real site.
  # - Same "Open save menu" two-step save flow as editing-content.feature
  #   applies here too on tenants that have it (e.g. Andy Thornton, Carbon
  #   Admin) - "Save content" stays hidden until "Open save menu" is
  #   clicked; MIPA's always-visible save button needs no such click. The
  #   "if present" click before "Save content" below handles both.
  #
  # Merged in from several since-removed tenant-specific duplicates of this
  # same scenario (written 2026-08-31, before this file was shared -
  # discovered via scripts/check-duplicate-admin-features.sh) rather than
  # lost on cleanup:
  # - CONFIRMED (live, Carbon Admin staging, 2026-08-31) Carbon's own
  #   dropdown save genuinely opens and works. CONFIRMED SEPARATELY (live,
  #   PizzaExpressLive staging) its identical-LOOKING dropdown never opens -
  #   a real site bug on PizzaExpressLive specifically, not a selector gap -
  #   so a failure there on the "Save content" click (stuck behind a
  #   dropdown that won't open) is expected until that's fixed, not a sign
  #   the "if present" handling here is wrong.
  # - CONFIRMED (live, HIB staging, 2026-08-31): HIB's dropdown has a THIRD
  #   option too ("Save and Index"), not just "Save" - only "Save content"
  #   is clicked here, same as everywhere else. Clicking the dropdown
  #   toggle alone (without then picking an option) does nothing visible -
  #   no toast, no request - which can look like a broken Save button if a
  #   failure investigation stops there; it just needs the second click.
  # - CONFIRMED (live, Indespension/KOOL/Russells staging, 2026-08-31):
  #   identical field/slug/toast shape to MIPA on all three. The save
  #   icon's SVG data-icon attribute varies by tenant (e.g. "floppy-disk"
  #   on Indespension/Russells, "save" on MIPA/KOOL) - already handled by
  #   each tenant's own "Save content" mapping, no scenario change needed.
  # - CONFIRMED, THEN RE-CONFIRMED FIXED (live, JTDove staging): on
  #   2026-08-31 a plain "click precisely" (non-forced) on "Save content"
  #   reliably failed here - Playwright's own "receives events" check never
  #   passed, an overlay-interference issue - while a forced click worked
  #   every time. Live-verified again on 2026-09-10 (prompted by this
  #   duplicate-file cleanup): the plain, non-forced click now succeeds
  #   instantly and saves correctly (toast + real persisted page, cleaned
  #   up afterwards) - the underlying site issue looks to have been fixed
  #   since. Deliberately NOT switched to a forced click here on the
  #   strength of a 10-day-old finding - re-verify live again if this
  #   scenario ever fails specifically on JTDove's "Save content" step.
  # - CONFIRMED (live, Russells staging, 2026-08-31): the Orphaned Pages
  #   menu genuinely has real pre-existing rows here - an earlier
  #   investigation (recorded in a since-deleted Indespension-side file)
  #   had wrongly concluded Russells' list was empty, which was a
  #   live-verification miss, not a real gap. Worth remembering as a
  #   general caution: a claim about tenant B recorded in tenant A's
  #   comments is only as reliable as whoever last actually checked B.

  Scenario: Creating a new page adds it to the Orphaned Pages menu
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I click precisely on the "Create New Page" element
    # CONFIRMED (HIB hib-170-peracto, 2026-09-24, 2/2 full runs): without a
    # settle, Save was clicked ~220ms after the editor opened, before it was
    # ready - the save menu stayed open and no save ever fired. Same class of
    # startup race as logging-in.feature's "Resetting password".
    And I wait for the page to settle
    And I fill in the "Page Name" input field with a unique test title
    And I click precisely on the "Open save menu" element if present
    And I click precisely on the "Save content" element
    Then the "success toast" should contain the text "Content successfully saved!"

    When I reload the page
    Then the "Page Name" input field should have the stored content title

    When I click precisely on the "Back to list" element
    And I click precisely on the "Configuration" element
    And I click precisely on the "Navigation" element
    And I click precisely on the "Orphaned pages" element
    And I click precisely on the "Add Item" element
    And I select the "Page" option from the "Navigation Item Type" react-select
    And I search for the stored content title in the "Select Item" react-select
    And I click precisely on the "Submit" element
    Then the "success toast" should contain the text "Item successfully added!"
    And the remembered "content title" should appear in the "menu item title" element

    When I remove the stored content title from the "menu item row" navigation menu
    And I click precisely on the "Content" element
    And I click precisely on the "Pages" element
    And I delete the content row containing the stored content title

  Scenario: Creating a new article adds it to the Orphaned Pages menu
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Articles" element
    And I click precisely on the "Create New Article" element
    And I fill in the "Article Heading" input field with a unique test title
    And I click precisely on the "Open save menu" element if present
    And I click precisely on the "Save content" element
    Then the "success toast" should contain the text "Content successfully saved!"

    When I reload the page
    Then the "Article Heading" input field should have the stored content title

    When I click precisely on the "Back to list" element
    And I click precisely on the "Configuration" element
    And I click precisely on the "Navigation" element
    And I click precisely on the "Orphaned pages" element
    And I click precisely on the "Add Item" element
    And I select the "Article" option from the "Navigation Item Type" react-select
    And I search for the stored content title in the "Select Item" react-select
    And I click precisely on the "Submit" element
    Then the "success toast" should contain the text "Item successfully added!"
    And the remembered "content title" should appear in the "menu item title" element

    When I remove the stored content title from the "menu item row" navigation menu
    And I click precisely on the "Content" element
    And I click precisely on the "Articles" element
    And I delete the content row containing the stored content title
