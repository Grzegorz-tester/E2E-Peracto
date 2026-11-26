@regression
Feature: Operations in the user's account

  # Full rewrite - the real account area has only four tabs (Dashboard,
  # Profile, Address Book, Orders), confirmed live 2026-08-21. The previous
  # version's "STOCK CHECK & QUICK ORDER" tab (an HIB trade-portal concept)
  # doesn't exist here and has been dropped rather than faked with a made-
  # up selector. The Profile form also has no Company Name/Account Number/
  # Currency fields (also HIB-only) - real fields are Email, Title,
  # First Name, Last Name and Contact Number.

  Scenario: Dashboard shows the account's delivery address
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    Then the "Delivery Address" should be displayed


  Scenario: Profile tab shows real, non-empty account details
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "PROFILE" tab
    Then I should be redirected to the "account-profile" page
    And the "Email" should not equal the value ""
    And the "First name" should not equal the value ""
    And the "Last name" should not equal the value ""
    And the "Contact number" should be enabled


  Scenario: Address Book tab shows the saved address
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "ADDRESS BOOK" tab
    Then I should be redirected to the "account-address-book" page
    And the "Delivery Address" should be displayed


  Scenario: Orders tab shows the order history widgets
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "ORDERS" tab
    Then I should be redirected to the "account-orders" page
    And the "Orders table" should be displayed


  # IND-729 case 304: historic orders created before the upgrade must still
  # open with their lines, totals and VAT intact. Uses the newest order on the
  # shared test account, so no order number is hard-coded.
  Scenario: Opening a historic order shows its lines and consistent totals
    Given I am navigating the page as a "logged in" user
    When I am on the "account-orders" page
    And I wait for the page to settle
    And I remember the text of "first order number" as "order number"
    And I click on the "first order row" element
    Then I should be redirected to the "account-order-detail" page
    And the "order reference" should contain the remembered "order number"
    And the "order delivery address" should be displayed
    And the "order delivery method" should be displayed
    And the "order line name" should not equal text ""
    And the "order VAT" should contain the text "VAT"
    And the "order payment details" should be displayed
    # The discount row only appears on orders that used a promotion. CONFIRMED
    # 2026-11-13: the prod account's only order (000118) has one (-£69.00).
    And the price in "order total" should equal "order subtotal" plus "order shipping" minus "order discount" if present
