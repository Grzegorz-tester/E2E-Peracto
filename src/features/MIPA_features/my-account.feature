@regression

Feature: Operations in the users account


  Scenario: Verify: - the presence of Dashboard tab elements, the orders table and redirection to "All Orders"
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Dashboard" tab
    Then the "Recent Orders table" should be displayed
    And the "Delivery Address" should be displayed
    And the "Billing Address" should be displayed
    Then I should be redirected to the "account" page
    When I click on the "orders - View all" link
    Then I should be redirected to the "account-orders" page

  Scenario: Verify: - a presence of the Profile tab elements, that non-editable fields are disabled, editable fields are not disabled, and required fields are not empty
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Profile" tab
    Then I should be redirected to the "account-profile" page

    And the "Email" should not be enabled
    And the "Email" should not equal the value ""

    And the "First name" should be enabled
    And the "First name" should not equal the value ""

    And the "Last name" should be enabled
    And the "Last name" should not equal the value ""

    And the "Contact number" should be enabled

    And the "Save Changes" should be enabled


  Scenario: Verify: - a presence of Address Book tab elements

    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Address Book" tab
    Then I should be redirected to the "account-address-book" page
    And the "Delivery Address" should be displayed
    And the "Billing Address" should be displayed


  Scenario: Verify: - a presence of Orders tab elements

    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Orders" tab
    Then I should be redirected to the "account-orders" page
    And the "Order picker" should be displayed
    And the "Refresh" should be displayed
    And the "Orders table" should be displayed

  Scenario: Verify: - a presence of My Lists tab elements

    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "My Lists" tab
    Then I should be redirected to the "account-wishlist" page
    And the "search bar" should be displayed
    And the "Refresh" should be displayed
    And the "Create a new Wishlist" should be displayed
    And the "Wishlists table" should be displayed

  # 2026-09-25: Make a Payment and Invoices are in the account menu but had
  # no coverage. Confirmed live on feature-next-15: the payment button stays
  # disabled at the default £0 and enables once an amount is entered. This
  # scenario never clicks it - it would take a real payment against the
  # trade account.
  Scenario: Verify: - Make a Payment shows the account balance and only enables payment once an amount is entered
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Make a Payment" tab
    Then I should be redirected to the "account-make-a-payment" page
    And the "Account Balance" should be displayed
    And the "Amount to pay" should be displayed
    And the "MAKE A PAYMENT" should not be enabled
    When I fill in the "Amount to pay" input field with "1.00"
    Then the "MAKE A PAYMENT" should be enabled

  # This test account has no invoices (confirmed live: "Sorry, no results
  # found for your search."), so either real rows or that genuine empty
  # state passes.
  Scenario: Verify: - the Invoices tab loads its table with real invoices or a genuine empty state
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Invoices" tab
    Then I should be redirected to the "account-invoices" page
    And the "Invoices table" should be displayed
    And the "invoice row" should be displayed or the "no invoices message" should be displayed

  # 2026-09-25: CONFIRMED SITE BUG - expected to stay red until fixed.
  # Opening any order (from the dashboard or the Orders list) briefly hits
  # /account/orders/MSO-xxxxxx, then falls back to the Orders list. On
  # feature-next-15 the page calls GET staging-api.../dc/orders/146892
  # (the MSO- prefix stripped), which returns a 500 for every order tried
  # (MSO-146883/146885/146892); on staging and release-2-8-1 it redirects
  # without calling the API at all. Waits for the page to settle before
  # checking the URL, because a plain redirect check can pass on the brief
  # first navigation before the fallback kicks in.
  Scenario: Verify: - opening an order from the dashboard shows its order detail page
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "first recent order link" element
    And I wait for the page to settle
    Then the current URL should contain "/account/orders/MSO-"
