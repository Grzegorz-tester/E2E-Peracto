@smoke
@regression
Feature: My Account & Authentication

  # From KOOL-2026-08-17.json regression suite, "Smoke Tests > My Account &
  # Authentication" (cases 537-539).

  # KOOL-537 in the source suite is "complete registration with valid data,
  # confirm account created, confirm registration email received" - a real
  # submission. Registration here requires an F-Gas certificate file upload
  # (no file-upload step exists in this framework yet) and creates a real
  # trade account on a live system, which may trigger a real approval
  # workflow/sales follow-up. Scoped down to a safe, non-destructive check
  # (required-field validation) instead - extend to a full submission (and
  # add a file-upload step) only once that's confirmed acceptable.
  Scenario: User registration - empty submission is rejected with validation
    Given I am on the "register" page
    When I click on the "Register" button
    Then the "validation message" should be displayed

  # Anchored on the "quotes user 2" account (grzegorz.hajduk@velstar.co.uk)
  # since its dashboard/orders content differs from the primary test user.
  Scenario: My Account - Manage profile, addresses and orders
    Given I am navigating the page as a "quotes user 2" user
    And I am on the "account" page
    Then the "welcome message" should be displayed
    And the "address card" should be displayed

    When I click on the "Profile menu item" element
    Then I should be redirected to the "account-profile" page

    When I click on the "Address Book menu item" element
    Then I should be redirected to the "account-address-book" page

    When I click on the "Orders menu item" element
    Then I should be redirected to the "account-orders" page

  Scenario: Password reset - From the Reset Password page
    Given I am on the "login" page
    When I click on the "Forgotten your password?" link
    Then I should be redirected to the "reset-password" page
    When I fill in the "Email address" input field with the "logged in" user's email
    And I click on the "SUBMIT" button
    Then the "reset password message" should be displayed
