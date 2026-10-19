@regression
Feature: Change account password

  # Changes the "logged in" test account's REAL password twice (to a fixed,
  # documented temporary value, then back) to verify the change takes
  # effect immediately. Unlike the source Playwright suite this was
  # migrated from, Gherkin has no try/finally - if this scenario fails
  # between changing the password and reverting it, the shared account is
  # left on "Temp1234Velstar!" and every other logged-in scenario will
  # start failing until someone signs in with that password and reverts it
  # by hand via Account > Profile > Reset Password. Keep this scenario
  # short and don't add steps between the change and the revert.

  Scenario: User can change their account password
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

    When I navigate directly to the path "/account/profile"
    And I click on the "Reset Password" button
    And I fill in the "Existing password" input field with the "logged in" user's password
    And I fill in the "New password" input field with "Temp1234Velstar!"
    And I fill in the "Repeat new password" input field with "Temp1234Velstar!"
    And I click on the "Save Changes" button
    Then the "Change password alert" should equal text "Password successfully updated"

    When I click on the "Sign Out" button
    And I am on the "login" page
    And I click on the "Accept cookies" button if present
    And I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with "Temp1234Velstar!"
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page

    When I navigate directly to the path "/account/profile"
    And I click on the "Reset Password" button
    And I fill in the "Existing password" input field with "Temp1234Velstar!"
    And I fill in the "New password" input field with the "logged in" user's password
    And I fill in the "Repeat new password" input field with the "logged in" user's password
    And I click on the "Save Changes" button
    Then the "Change password alert" should equal text "Password successfully updated"

    When I click on the "Sign Out" button
    And I am on the "login" page
    And I click on the "Accept cookies" button if present
    And I fill in the "Email address" input field with the "logged in" user's email
    And I fill in the "Password" input field with the "logged in" user's password
    And I click on the "Sign In" button
    Then I should be redirected to the "account" page
