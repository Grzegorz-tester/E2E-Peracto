@regression @mutates-admin-data
Feature: Editing Existing Attributes, Attribute Groups, Attribute Sets, Locations and Shipping Services

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - Attributes/Attribute Groups/Attribute Sets/Locations/
  # Shipping Services are standard Peracto Admin entities, confirmed
  # present via the same nav testids in every admin tenant's own
  # dashboard.json. Their detail-page selectors (attribute-detail.json,
  # attribute-group-detail.json, attribute-set-detail.json,
  # location-detail.json, shipping-service-detail.json) were previously
  # only defined in MIPA's config; copied verbatim to every other tenant
  # on promotion, since they're plain data-testid/name selectors with no
  # MIPA-specific text. Not yet live-verified against every tenant
  # individually; each tenant's own regression run will surface any real
  # gap.
  #
  # Same edit-and-restore shape as editing-existing-entities.feature, and
  # for the same reason: each of these is a REAL, pre-existing entity (the
  # first row in its list) with no disposable-create-then-delete
  # equivalent available, so every scenario remembers the field's
  # original value first and restores it at the end.
  #
  # Built specifically because editing-existing-entities.feature's
  # Category scenario caught a real bug on the release branch (a save
  # returning "The type of the 'id' attribute must be 'int', 'string'
  # given.") - these five entities share the same detail-page-with-
  # save-form shape, so they're the most likely other places the same
  # underlying save/serialisation code path could be broken too. Tagged
  # @mutates-admin-data with the same "I require a staging admin" runtime
  # guard as every other write scenario in this suite.
  #
  # CONFIRMED BUG (live, MIPA_ADMIN STAGING - not just the release branch,
  # 2026-09-09): the Attribute Set scenario below is expected to keep
  # failing right now, for a different and unrelated reason to the
  # Category "id" bug - saving the "Default" Attribute Set (even an
  # otherwise-no-op rename) is rejected outright with "Cannot save
  # Attribute Set, an Attribute references multiple AttributeGroups in
  # AttributeSet." This is a real data-integrity problem with one of
  # Default's own attributes (it references more than one Attribute
  # Group, which the backend won't accept), not a flaky test - it blocks
  # ANY save to this Attribute Set via the admin UI until that underlying
  # attribute/group relationship is fixed. Left asserting success (not
  # "adjusted" to expect this failure) so the scenario starts passing
  # again the moment that data issue is actually fixed, same reasoning as
  # tasks.feature's Inactive-task assertions.

  Scenario: Editing an Attribute's label persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Attributes" element
    And I click precisely on the "All Attributes" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Label" input field as "original attribute label"
    And I fill in the "Label" input field with a unique value, remembering it as "new attribute label"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Label" input field should have the remembered "new attribute label"

    When I fill in the "Label" input field with the remembered "original attribute label"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Label" input field should have the remembered "original attribute label"


  Scenario: Editing an Attribute Group's name persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Attributes" element
    And I click precisely on the "Attribute Groups" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Name" input field as "original attribute group name"
    And I fill in the "Name" input field with a unique value, remembering it as "new attribute group name"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Name" input field should have the remembered "new attribute group name"

    When I fill in the "Name" input field with the remembered "original attribute group name"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Name" input field should have the remembered "original attribute group name"


  Scenario: Editing an Attribute Set's name persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Attributes" element
    And I click precisely on the "Attribute Sets" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Name" input field as "original attribute set name"
    And I fill in the "Name" input field with a unique value, remembering it as "new attribute set name"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Name" input field should have the remembered "new attribute set name"

    When I fill in the "Name" input field with the remembered "original attribute set name"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Name" input field should have the remembered "original attribute set name"


  Scenario: Editing a Location's name persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Locations" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Name" input field as "original location name"
    And I fill in the "Name" input field with a unique value, remembering it as "new location name"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Name" input field should have the remembered "new location name"

    When I fill in the "Name" input field with the remembered "original location name"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Name" input field should have the remembered "original location name"


  Scenario: Editing a Shipping Service's name persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Shipping Services" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Name" input field as "original shipping service name"
    And I fill in the "Name" input field with a unique value, remembering it as "new shipping service name"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Name" input field should have the remembered "new shipping service name"

    When I fill in the "Name" input field with the remembered "original shipping service name"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Name" input field should have the remembered "original shipping service name"
