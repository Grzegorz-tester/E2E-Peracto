@regression @mutates-admin-data
Feature: Creating and Deleting Categories, Attributes, Attribute Groups, Attribute Sets, Promotions and Article Categories

  # New coverage (2026-09-18) - these five entities previously only had
  # edit-and-restore coverage (editing-existing-entities.feature,
  # editing-attributes-and-config.feature); nothing ever created or
  # deleted one. Built and confirmed live on Carbon Admin staging via a
  # standalone investigation script, not guessed.
  #
  # CONFIRMED (live, Carbon Admin staging, 2026-09-18): none of these five
  # detail pages have their own "Delete" button - deletion is LIST-ONLY,
  # via the same checkbox-select -> "Delete Row" -> confirm-modal flow
  # already generalised in content-admin.ts for Pages/Articles ("I fill in
  # the ... with a unique test title" / "I delete the content row
  # containing the stored content title") - confirmed by that file's own
  # comment that the mechanism isn't Page/Article-specific. Reused
  # verbatim here rather than writing new entity-specific steps, since the
  # "Velstar Test Content <timestamp>" value it types satisfies every one
  # of these five entities' own single required name/label/heading field:
  # - Category needs "Category Heading" (an "Identifier" field also
  #   exists, but auto-generates from the heading on blur, same as
  #   content's own slug - confirmed live it saves fine with only the
  #   heading filled).
  # - Attribute Group and Attribute Set each need only their one Name
  #   field.
  # - Promotion needs "Promotion Name" only (a "Promotion Identifier"
  #   field also exists and IS validated as required on a blank save, but
  #   auto-generates from the name on blur the same as Category's
  #   identifier - confirmed live it saves fine with only the name
  #   filled).
  #
  # Attribute is the one exception: its "Code" field also auto-generates
  # from the Label on blur, but CONFIRMED (live, Carbon Admin staging,
  # 2026-09-18) Peracto rejects any Code containing a hyphen ("Attributes
  # Codes can not begin with a number and can only contain letters,
  # numbers and underscores") - and content-admin.ts's own timestamp
  # format ("2026-09-18 09:23:42") slugifies its spaces into underscores
  # but leaves the date's hyphens in place, so auto-generation from that
  # value fails Save outright, every time. This looked exactly like a
  # save-vs-redirect timing race at first (no toast, no redirect,
  # "(could not read text)" reading a toast that was never going to
  # appear) until a failure screenshot showed the real cause: an inline
  # field error under Code, not a missing toast. Fixed by filling Code
  # explicitly with a hyphen-free value (entity-admin.ts's "unique code"
  # step, reused again below for Shipping Service's own Code field)
  # instead of relying on auto-generation - not a timing fix, a genuine
  # value fix. Worth remembering generally: an
  # unreadable/missing toast after a Save click is also exactly what a
  # silently-rejected save due to inline validation looks like - check the
  # actual page state (or a screenshot) before assuming it's a race.
  #
  # Saving redirects to the entity's own detail page for Attribute/
  # Attribute Group/Attribute Set/Promotion (matching Products/Forms), but
  # Category is the one exception - it redirects back to the LIST page
  # instead. CONFIRMED (live, Carbon Admin staging, 2026-09-18): unlike
  # Products/Forms, none of these four detail pages share a single generic
  # "back to list" testid - Attribute Group/Attribute Set each have their
  # OWN distinct one (back-to-attribute-groups/back-to-attribute-sets) and
  # Promotion has none at all. Re-navigating through the same nav-click
  # sequence used to get there in the first place (already proven to work
  # for the same reason Category needs no back-link) is more robust than
  # mapping three more one-off testids, and reuses the exact same "stale
  # bounding box" parent-click-first handling every other nav-click in
  # this suite already needs.
  #
  # "I wait for the save to complete" before every toast assertion below
  # guards against the same save-vs-redirect race editing-content.feature
  # already documented and fixed elsewhere (saving can redirect
  # client-side at almost the exact moment the toast first renders).
  #
  # Article Category needs "Category Name", "Title" AND "Locale" (a plain
  # text input, placeholder "en_GB" - not a react-select, no options to
  # open) - the only one of these six where a single field isn't enough
  # and none of the extra fields auto-generate from anything.
  #
  # User Groups and Element Areas were investigated and deliberately left
  # out entirely, not just out of this file: CONFIRMED (live, Carbon
  # Admin staging, 2026-09-18) neither has any creation UI at all -
  # /element-areas/add and a User Group's own detail page
  # (/user-groups/guest - slug-based, not numeric) both render a
  # not-found/read-only page, no save-form anywhere. User Groups' detail
  # page is a read-only permissions matrix (row-N-label/row-N-value pairs)
  # with no save or delete button of any kind. Both are structurally
  # non-CRUD-able, the same as Settings/Countries/Tasks - the existing
  # generic sweep (tabs-contain-expected-data.feature/
  # first-item-redirects.feature) is already the full extent of coverage
  # possible for either.
  #
  # Templates couldn't be verified at all: Carbon Admin currently has ZERO
  # templates (an empty list), so there's no real row to test an edit-and-
  # restore scenario against - see editing-content.feature's own comment
  # for why a Templates scenario was deliberately never promoted there.
  #
  # Location needed its own scenario in this same file rather than fitting
  # the shared single-field pattern above: CONFIRMED (live, Carbon Admin
  # staging, 2026-09-18) it requires Name, Alias, Address 1, Town/City,
  # County/State, Postal Code, Country and Latitude/Longitude - none of
  # which auto-generate from another. Country is a react-select but this
  # tenant only has one real option (United Kingdom) to pick from - a
  # tenant with more countries configured may need this scenario's
  # approach revisited if "United Kingdom" isn't guaranteed present
  # everywhere using this shared suite. Also confirmed live: Location's
  # own "Delete Location" trigger button (unlike every other entity in
  # this file) has no data-testid at all - only the modal's CONFIRM button
  # does (button-action_delete-location) - mapped by its distinguishing
  # class instead (location-detail.json).
  #
  # CONFIRMED (live, Carbon Admin staging, 2026-09-18): both Alias AND
  # "Location Identifier" must be globally unique, and NEITHER auto-
  # generates from Name or anything else - Identifier sits genuinely blank
  # until typed into (confirmed via a fresh page load, no fill/blur
  # anywhere near it). A fixed literal Alias value worked on this
  # scenario's first two runs then failed a third with "This value is
  # already used." on both Alias and Identifier - leaving Identifier
  # blank meant every run was colliding on the same empty value once one
  # run had claimed it, not a delayed-cleanup issue. Same silent-rejection
  # "(could not read text)" shape as Attribute's Code issue above - fixed
  # by filling both Alias and Identifier with their own unique value (the
  # plain "... with a unique value" step) rather than leaving Identifier
  # untouched.
  #
  # Shipping Service needs a real cost row, not just Name/Code - CONFIRMED
  # (live, Carbon Admin staging, 2026-09-18) saving with only those two
  # fields rejects with "Shipping services must have at least one cost
  # associated with them, none given." Selecting a country from "Available
  # Countries" reveals a Cost input (input[name='costs[0].cost']) for that
  # country - this tenant only has "United Kingdom" configured, same
  # single-option caveat as Location's Country field above. This field
  # also turned out to use a SECOND, different react-select shape
  # (classNamePrefix "peracto-select", not "list") from every other
  # react-select in this suite - added "... peracto-select" as its own new
  # step (form.ts) rather than guessing a combined selector into the
  # existing "... react-select" step. No delete button on its own detail
  # page either (same list-only pattern as every other entity in this
  # file).

  Scenario: Creating a new Category, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Categories" element
    And I click precisely on the "Add Category" element
    And I fill in the "Heading" input field with a unique test title
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Category successfully added!"

    # Filter by the stored heading before deleting, same reason as Attribute
    # Groups below - confirmed live on INDESPENSION_ADMIN (staging-peracto,
    # 2026-09-29): Categories paginates at 25 and the list is already full,
    # so the new row wasn't on page 1.
    When I click precisely on the "Products" element
    And I click precisely on the "Categories" element
    And I fill in the "Name filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I delete the content row containing the stored content title

  Scenario: Creating a new Attribute, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Attributes" element
    And I click precisely on the "All Attributes" element
    And I click precisely on the "Add Attribute" element
    And I fill in the "Label" input field with a unique test title
    And I fill in the "Code" input field with a unique code
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Attribute successfully added!"

    # Filter by the stored label before deleting - confirmed live on HIB
    # (hib-170-peracto, 2026-09-24): All Attributes paginates at 25 rows
    # and a new attribute doesn't land on page 1, so an unfiltered row
    # lookup timed out even though the create itself had succeeded.
    When I click precisely on the "Products" element
    And I click precisely on the "Attributes" element
    And I click precisely on the "All Attributes" element
    And I fill in the "Label filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I delete the content row containing the stored content title

  Scenario: Creating a new Attribute Group, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Attributes" element
    And I click precisely on the "Attribute Groups" element
    And I click precisely on the "Add Attribute Group" element
    And I fill in the "Name" input field with a unique test title
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Attribute Group successfully added!"

    # Filter by the stored name before deleting, same reason as All
    # Attributes above - confirmed live on KOOL_ADMIN_RELEASE
    # (2-19-0-peracto, 2026-09-28): Attribute Groups (30) and Attribute
    # Sets (61) both paginate at 25, so a new row wasn't on page 1.
    # The settle after Apply matters: confirmed live on Keylite_ADMIN_RELEASE
    # (2-0-1-peracto, 2026-09-28) - with only 7 groups the new row is already
    # visible unfiltered, so the delete step ticked its checkbox while the
    # list was still re-fetching for the filter and the re-render dropped the
    # tick ("Clicking the checkbox did not change its state").
    When I click precisely on the "Products" element
    And I click precisely on the "Attributes" element
    And I click precisely on the "Attribute Groups" element
    And I fill in the "Name filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I delete the content row containing the stored content title

  Scenario: Creating a new Attribute Set, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Attributes" element
    And I click precisely on the "Attribute Sets" element
    And I click precisely on the "Add Attribute Set" element
    And I fill in the "Name" input field with a unique test title
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Attribute Set successfully added!"

    # Filter first - see the Attribute Group scenario above.
    When I click precisely on the "Products" element
    And I click precisely on the "Attributes" element
    And I click precisely on the "Attribute Sets" element
    And I fill in the "Name filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I delete the content row containing the stored content title

  Scenario: Creating a new Promotion, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Promotions" element
    And I click precisely on the "Add Promotion" element
    And I fill in the "Promotion Name" input field with a unique test title
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Promotion successfully added!"

    When I click precisely on the "Promotions" element
    And I delete the content row containing the stored content title

  Scenario: Creating a new Article Category, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Article Categories" element
    And I click precisely on the "Add Article Category" element
    And I fill in the "Category Name" input field with a unique test title
    And I fill in the "Title" input field with a unique value
    And I fill in the "Locale" input field with "en_GB"
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Article Category successfully added!"

    # Filter first - confirmed live on ANDY_THORNTON_ADMIN (staging-peracto,
    # 2026-09-30): Article Categories paginates at 25 and already runs to a
    # second page, so the new row wasn't on page 1 and was left behind.
    When I click precisely on the "Content" element
    And I click precisely on the "Article Categories" element
    And I fill in the "Name filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I delete the content row containing the stored content title

  Scenario: Creating a new Location, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Locations" element
    And I click precisely on the "Add Location" element
    And I fill in the "Name" input field with a unique test title
    And I fill in the "Identifier" input field with a unique value
    And I fill in the "Alias" input field with a unique value
    And I fill in the "Address 1" input field with "1 Test Street"
    And I fill in the "Town City" input field with "Test City"
    And I fill in the "County State" input field with "Test County"
    And I fill in the "Postal Code" input field with "AB1 2CD"
    And I select the "United Kingdom" option from the "Country" react-select
    And I fill in the "Latitude" input field with "51.5074"
    And I fill in the "Longitude" input field with "-0.1278"
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Location successfully added!"

    When I click precisely on the "Delete Location" element
    And I click precisely on the "Confirm Delete Location" element

  Scenario: Creating a new Shipping Service, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Shipping Services" element
    And I click precisely on the "Add Service" element
    And I fill in the "Name" input field with a unique test title
    And I fill in the "Code" input field with a unique code
    And I select the "United Kingdom" option from the "Available Countries" peracto-select
    And I fill in the "Cost" input field with "5.99"
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Shipping Service successfully added!"

    # Filter first - same pagination problem, confirmed on the same tenant
    # and day (35 services across 2 pages).
    When I click precisely on the "Configuration" element
    And I click precisely on the "Shipping Services" element
    And I fill in the "Service Name filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I delete the content row containing the stored content title
