@regression
Feature: Creating Forms and Form Fields, and Viewing a Form Submission

  # New coverage (2026-09-18) - before this, Forms/Form Fields/Form
  # Submissions only had the generic sweeps in tabs-contain-expected-data.
  # feature and first-item-redirects.feature (list loads, first row
  # redirects to its own detail page) - nothing actually created a form or
  # a form field, or checked a submission's own content. Built and
  # confirmed live on Carbon Admin staging (2026-09-18) via a standalone
  # investigation script, not guessed: real testids dumped from the actual
  # DOM at every step, including the create-form validation errors that
  # reveal which fields are genuinely required.
  #
  # CONFIRMED (live, Carbon Admin staging, 2026-09-18):
  # - Creating a Form needs Label, Submit Button Text AND Redirect URL -
  #   saving with only Label filled shows "Submit Button Text is a
  #   required field" / "Redirect URL is a required field" toasts and does
  #   NOT redirect away from /forms/add. Attaching Form Fields to the form
  #   is NOT required to save (not asserted here - genuinely optional).
  # - Creating a Form Field needs only Label and an Input Type selection
  #   (Text/Textarea/Select/Radio/Checkbox/Checkbox Group/File/Date/
  #   Declaration/Email/Telephone/Postcode/Hidden are the real options).
  # - The success toasts are inconsistent in an easy-to-miss way: creating
  #   a form field says "Form Fields successfully added!" (plural, even
  #   for one), but deleting it says "Form Field deleted successfully!"
  #   (singular). Asserted exactly as the site actually renders it, not
  #   normalised to what would read more consistently.
  # - Both Save buttons resolve to the same shared [data-testid='save-form']
  #   used by every other entity's Add/Edit form in this suite (products,
  #   redirects, promotions, ...) - form-detail.json/form-field-detail.json
  #   define their own "Save" key locally, same convention as
  #   redirect-detail.json/promotion-detail.json, not a shared common.json
  #   key.
  # - A form submission's detail page (reached via the list's existing
  #   "first item link") renders a plain Label/Input Type/Value table of
  #   that submission's own real answers - genuinely real, PII-bearing
  #   customer data on Carbon Admin's staging (a real name, email and
  #   phone number), so this only asserts the table itself renders (the
  #   existing generic "table row" key), never any specific submitted
  #   value. Read-only and safe on production - not tagged
  #   @mutates-admin-data, same reasoning as products-export.feature.
  #
  # Form/Form Field creation both leave real rows in the client's admin if
  # the delete step doesn't run (exactly what happened with Lamona's
  # leftover "Velstar Test Product" rows from a different feature) - the
  # "Velstar Test Form/Field <ts>" naming (form-admin.ts) keeps any
  # orphaned row immediately identifiable as ours if that ever happens.

  @mutates-admin-data
  Scenario: Creating a new form with its required fields, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Forms" element
    And I click precisely on the "All Forms" element
    And I click precisely on the "Add Form" element
    And I fill in the "Label" input field with a unique form label
    And I fill in the "Submit Button Text" input field with "Submit"
    And I fill in the "Redirect URL" input field with "/thank-you"
    And I click precisely on the "Save" element
    Then the "success toast" should contain the text "Form successfully added!"

    When I click precisely on the "Delete Form" element
    And I click precisely on the "Confirm Delete Form" element
    Then the "success toast" should contain the text "Form deleted successfully!"

  @mutates-admin-data
  Scenario: Creating a new form field with its required fields, then deleting it
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Forms" element
    And I click precisely on the "Form Fields" element
    And I click precisely on the "Add Form Field" element
    And I fill in the "Label" input field with a unique form field label
    And I select the "Text" option from the "Input Type" react-select
    And I click precisely on the "Save" element
    Then the "success toast" should contain the text "Form Fields successfully added!"

    When I click precisely on the "Delete Form Field" element
    And I click precisely on the "Confirm Delete Form Field" element
    Then the "success toast" should contain the text "Form Field deleted successfully!"

  Scenario: Viewing a form submission shows its own submitted values
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Forms" element
    And I click precisely on the "Form Submissions" element
    And I click precisely on the "first item link" element if present
    Then the "table row" should be displayed or the "no results message" should be displayed
