@regression
Feature: Product quoting

  # Shared across every Watco market. "Add to quote" and "My Quotes" are
  # B2B-facing storefront features with no prior coverage anywhere in this
  # suite.
  #
  # CONFIRMED LIVE (staging-uk, 2026-09-09): clicking "Add to quote" as a
  # guest opens the SAME shared "Sign In" modal used elsewhere on the site
  # (a fresh "Invalid credentials" alert seen during exploratory probing
  # turned out to be a stale artifact from reusing one browser page across
  # many manual navigations, not real behaviour - a real, single Cucumber
  # run confirms the modal every time), with its own "Continue as guest"
  # option - so a guest is never silently able to add an item to a quote.
  #
  # CONFIRMED LIVE (staging-uk, 2026-09-09): for a LOGGED-IN customer,
  # "Add to quote" opens an "Add to quote" modal offering "Create new
  # quote" (a name input + submit button) - it does not add the item
  # instantly, and does not redirect anywhere on its own.

  Scenario: A guest is prompted to sign in before adding a product to a quote
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to quote" element
    Then the "sign-in prompt continue as guest button" should be displayed

  Scenario: A logged-in customer can create a new quote from a product page
    Given I am on the "login" page
    And I click on the "Accept cookies" button if present
    When I fill in the "Email address" input field with the "account test user 1" user's email
    And I fill in the "Password" input field with the "account test user 1" user's password
    And I click on the "Sign In" button, removing the "cookie preference centre overlay" overlay if it interferes
    Then I should be redirected to the "account" page

    When I am on the "home" page
    And I fill in the "Search products" input field with "epoxy"
    And I press Enter in the "Search products" input field
    And I wait for the search results to update
    And I click on the "first search result" link via its href on this origin
    And I click on the "Add to quote" element
    Then the "new quote name input" should be displayed

    When I fill in the "new quote name input" input field with a unique value, remembering it as "new quote name"
    And I click on the "Create new quote button" button

    When I am on the "quote-list" page
    Then the remembered "new quote name" should appear in the "quote list content" element
