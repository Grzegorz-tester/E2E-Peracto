@MIPA_regression
Feature: Register page

  # New coverage. Confirmed live: registration is a "Request an Account"
  # form (Company Name, First Name, Last Name, Email, Telephone, SEND) -
  # submitting creates a sales enquiry for Mipa's team to action manually,
  # not an instant self-serve account. Starts directly on "login" rather
  # than clicking through from the homepage first, since the homepage's
  # own "Register" text is just part of the combined "Sign In|Register"
  # link that already goes to /login - the real, separate "Register" link
  # only exists on the login page itself, inside the "Create an Online
  # Account" panel.
  #
  # This scenario previously showed shifting failures across several runs
  # (fields not retaining values, the SEND button staying disabled) -
  # consistent with the same "acted before client state was ready" race
  # diagnosed and fixed on the basket (see basket.feature's own note, and
  # navigation.ts's "I wait for the page to settle" step). Applying the
  # same fix here rather than the field-by-field patches tried before.
  Scenario: Requesting an account with valid details
    Given I am on the "login" page
    When I click on the "Register" element
    Then I should be redirected to the "register" page
    And I wait for the page to settle
    When I fill in the "Company Name" input field with "Velstar Test"
    And I fill in the "First Name" input field with "Velstar"
    And I fill in the "Last Name" input field with "Test"
    And I fill in the "Register email" input field with a unique guest email
    And I fill in the "Register phone" input field with "07377777777"
    Then the "SEND" should be enabled
    When I click on the "SEND" button, retrying until the "request success message" is displayed
