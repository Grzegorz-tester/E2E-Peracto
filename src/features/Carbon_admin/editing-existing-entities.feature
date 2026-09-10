@regression @mutates-admin-data
Feature: Editing Existing Categories and Promotions

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - Categories and Promotions are standard Peracto Admin
  # entities, confirmed present via the same nav testids in every admin
  # tenant's own dashboard.json. Their detail-page selectors
  # (category-detail.json/promotion-detail.json) were previously only
  # defined in MIPA's config; copied verbatim to every other tenant on
  # promotion, since they're plain data-testid selectors with no
  # MIPA-specific text. Not yet live-verified against every tenant
  # individually; each tenant's own regression run will surface any real
  # gap.
  #
  # Unlike product-management.feature's create-then-delete product (fully
  # disposable), these scenarios edit a REAL, pre-existing entity (the
  # first row in each list) - there's no equivalent "delete what we
  # created" cleanup available, so each scenario remembers the field's
  # original value first and restores it at the end, leaving the entity
  # exactly as it found it. Tagged @mutates-admin-data and starting with
  # "I require a staging admin for this scenario" for the same reason
  # address-book-management.feature is - see src/index.ts's
  # @mutates-admin-data comment for why both the tag exclusion and this
  # runtime guard exist independently.

  Scenario: Editing a Category's heading persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Categories" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Heading" input field as "original category heading"
    And I fill in the "Heading" input field with a unique value, remembering it as "new category heading"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Heading" input field should have the remembered "new category heading"

    When I fill in the "Heading" input field with the remembered "original category heading"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Heading" input field should have the remembered "original category heading"


  Scenario: Editing a Promotion's success message persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Promotions" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Promotion Success Message" input field as "original promotion message"
    And I fill in the "Promotion Success Message" input field with a unique value, remembering it as "new promotion message"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Promotion Success Message" input field should have the remembered "new promotion message"

    When I fill in the "Promotion Success Message" input field with the remembered "original promotion message"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed

    When I reload the page
    Then the "Promotion Success Message" input field should have the remembered "original promotion message"
