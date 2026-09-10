@regression @mutates-admin-data
Feature: Content Editing Known Issues

  # Split out of editing-content.feature when that file's portable
  # scenarios (Page/Article/Element edit-and-restore) were promoted to the
  # shared Carbon_admin boilerplate (2026-09-10). This scenario asserts a
  # CURRENT, MIPA-specific broken result as the expected outcome, so it
  # isn't safe to assume for every tenant using the shared suite.
  #
  # CONFIRMED BUG (live, MIPA_ADMIN staging, 2026-09-09): EVERY Template
  # row tried (ids 53 and 52, both of MIPA's first two) is currently
  # un-savable - "Templates can only support a single row. Ensure all
  # blocks sit within a single Container before saving." This is a
  # structural content-layout warning wholly unrelated to the name field
  # being edited, and it reproduced on 2 different templates, so it looks
  # like a systemic issue (a validation rule the existing template content
  # no longer satisfies) rather than one broken record - kept here as its
  # own scenario asserting the CURRENT (buggy) rejection, same "assert
  # reality, not the ideal" approach as tasks.feature's Inactive-task
  # scenario, so it starts failing loudly (a useful signal) the moment
  # Template saving is fixed and this scenario needs to be rewritten to
  # expect success instead.

  Scenario: Saving a Template is currently rejected due to a real content-structure validation bug
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Content" element
    And I click precisely on the "Templates" element
    And I click precisely on the "first item link" element if present
    And I click precisely on the "Save content" element
    Then the "warning toast" should contain the text "Templates can only support a single row"
