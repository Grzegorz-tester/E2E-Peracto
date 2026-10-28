@smoke
@regression
Feature: Admin login

  # Watco's admin is the LEGACY server-rendered Peracto (v6.1) at
  # <storefront host>/peracto, not the React Peracto Admin, so the shared
  # CARBON_ADMIN_SHARED_features suite doesn't apply. This whole folder is
  # READ-ONLY by design (user, 2026-10-24): nothing is created, edited or
  # deleted. Logs in as the Velstar "Test Automation" account (Admin role,
  # staging-uk only; WATCO_ADMIN_ADMIN_* in .env).
  #
  # CONFIRMED live (2026-10-24): a real account's wrong password and an
  # unregistered email both get the same "Invalid credentials." message, so
  # the form doesn't reveal which emails exist. The "Forgotten your
  # password?" link leaves the admin for the STOREFRONT's /forgotten page.

  Scenario: Successful log in to the admin
    Given I am navigating the page as a "admin" user
    Then I should be redirected to the "dashboard" page
    And the "Logout" should be displayed
    And the "dashboard tables" should be displayed

  Scenario: Logging in with a real account's wrong password is rejected
    Given I am on the "login" page
    When I fill in the "Email address" input field with the "admin" user's email
    And I fill in the "Password" input field with "wrongPassword"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "Invalid credentials."
    And I should be redirected to the "login" page

  Scenario: Logging in with an unregistered email gives the same message
    Given I am on the "login" page
    When I fill in the "Email address" input field with "not_registered@velstar.co.uk"
    And I fill in the "Password" input field with "Password123"
    And I click on the "Sign In" button
    Then I should be presented with a "validation message" "Invalid credentials."

  Scenario: The forgotten password link leads to the password reset page
    Given I am on the "login" page
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "forgotten-password" page
