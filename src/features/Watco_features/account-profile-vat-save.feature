@regression
@completes-registration
Feature: Account profile - VAT number save

  # Migrated from P3Playwright watco/tests/account/uk/account-profile-vat-save.test.ts
  #
  # WAT-305 - NOT a site bug. Previously flagged here as a "confirmed site
  # bug" (no request fired on Save, VAT number reverted on reload), but
  # that was a false positive in THIS test: the account-profile form
  # (form[name='user_profile']) has three required fields - Company, Job
  # function, Industry sector - that registration never collects, so a
  # freshly-registered account always loads the profile page with them
  # blank. The browser's native HTML5 `required` validation silently
  # blocks the form submit client-side when they're empty (no request of
  # any kind fires, no visible on-page error either, since it's a native
  # browser constraint bubble, not an app-rendered validation message) -
  # which is exactly what made this look like a broken save endpoint.
  # Confirmed live (2026-08-26): filling all three before clicking "Save
  # details" fires a real POST to /account/profile and the new VAT number
  # persists correctly across a reload. Corrected here to fill the
  # required fields first, so the scenario actually exercises VAT
  # persistence instead of getting silently blocked by unrelated fields.
  #
  # Uses a throwaway freshly-registered account rather than the shared
  # "account test user with vat" account, since this scenario's whole
  # point is to mutate a saved VAT number, and a bug here should never
  # risk leaving a shared account in an unexpected state for other tests.
  #
  # CONFIRMED live (2026-09-07): reproduced this scenario failing again
  # (VAT reverted to GB111111111 after save+reload) via a raw Playwright
  # script - same class of bug as CLAUDE.md's "Known quirks" section
  # already documents (cookie preference-centre overlay reappearing
  # mid-scenario, force:true landing the click on the overlay instead of
  # the real target underneath). Every OTHER click in this scenario
  # (Register, Sign In, Marketing agreement) already has its own
  # "removing the ... overlay if it interferes" clause; the "Save
  # details" click didn't, so a reappeared overlay could swallow that one
  # click specifically with no visible error - Playwright's force:true
  # still "succeeds" against the overlay, no POST ever fires, and the
  # page just reloads back to the unsaved value. Fixed by adding the same
  # overlay-removal clause here too; 4 consecutive clean runs afterward,
  # 0 retries needed.

  Scenario: Editing the VAT number and saving persists the new value
    Given I am on the "register" page
    When I fill in the "Email address" input field with a unique guest email
    And I select the "Mr" option from the "Title" dropdown
    And I fill in the "First name" input field with "Grzegorz"
    And I fill in the "Last name" input field with "AutomationTest"
    And I fill in the "Telephone" input field with "07700900123"
    And I fill in the "Password" input field with "Testing123!"
    And I fill in the "Confirm password" input field with "Testing123!"
    And I click on the "Marketing agreement" element, removing the "cookie preference centre overlay" overlay if it interferes
    And I fill in the "VAT number" input field with "GB111111111"
    Then the "Register" should be enabled
    And I click on the "Register" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "register-confirmed" page

    When I am on the "login" page
    And I fill in the "Email address" input field with the stored guest email
    And I fill in the "Password" input field with "Testing123!"
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page
    When I am on the "account-profile" page
    Then the "VAT number" should equal the value "GB111111111"

    When I fill in the "VAT number" input field with "GB222222222"
    # Required by the profile form but not collected at registration - left
    # blank, the browser's native required-field validation silently blocks
    # the submit below (see the WAT-305 note above).
    And I fill in the "Company" input field with "Velstar Test Ltd"
    And I select the "Facilities Manager" option from the "Job function" dropdown
    And I select the "Building/construction" option from the "Industry sector" dropdown
    And I click on the "Save details" button, removing the "cookie preference centre overlay" overlay if it interferes
    And I wait for the page to settle
    And I reload the page
    Then the "VAT number" should equal the value "GB222222222"
