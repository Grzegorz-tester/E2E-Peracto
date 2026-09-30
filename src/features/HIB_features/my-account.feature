@regression

Feature: Operations in the users account


  Scenario: Verify: - the presence of DASHBOARD tab elements, the orders table, and redirection to "Stock Check & Quick Order" and "All Orders"
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "DASHBOARD" tab
    Then the "Orders table" should be displayed
    When I click on the "Stock Check & Quick Order" button
    Then I should be redirected to the "place-order" page
    When I click on the "Back to Portal" button
    Then I should be redirected to the "account" page
    When I click on the "View all and search" link
    Then I should be redirected to the "account-orders" page

  # 2026-09-29: confirmed live - the dashboard's Contact Us button is a
  # plain client-side link to the public /contact-us page.
  Scenario: Verify: - the DASHBOARD "Contact Us" button opens the Contact Us page
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "Contact Us" button
    Then I should eventually be redirected to the "contact-us" page
    And a heading with the text "Contact Us" should be displayed

  # 2026-09-29: confirmed live - Sign Out lands on the homepage with the
  # Portal link back, and /account then bounces to /login?to=/account.
  Scenario: Signing out logs the user out and protects the account pages
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "Sign Out" link
    Then I should eventually be redirected to the "home" page
    And the "Portal" should be displayed
    When I am on the "account" page
    Then I should eventually be redirected to the "login" page

  # Not covered: saving the PROFILE (Contact number is the only editable
  # field). Confirmed live 2026-09-29 on BOTH feature-hib-170 and staging:
  # Save Changes first POSTs /api/recaptcha, which scores the headless test
  # browser 0.1 (reCAPTCHA v3 "likely a bot"), and the site then silently
  # drops the update - no PUT /users/<id>, no error. Real users score higher.
  # Automating it needs HIB's devs to use Google's reCAPTCHA test keys (or a
  # bypass) on staging/release.
  #
  # Not covered: order history detail. The test account has no orders at
  # all (/users-orders returns none), and HIB orders are never placed by
  # this suite on any environment, so there's nothing to open.
  #
  # The ADDRESS BOOK is read-only for this B2B account (no add/edit/delete
  # controls - the two "add address" links render empty), so only its
  # presence is checked.
  Scenario: Verify: - a presence of the PROFILE tab elements, that non-editable fields are disabled, editable fields are not disabled, and required fields are not empty
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "PROFILE" tab
    Then I should be redirected to the "account-profile" page

    And the "Email" should not be enabled
    And the "Email" should not equal the value ""

    And the "First name" should not be enabled
    And the "First name" should not equal the value ""

    And the "Last name" should not be enabled
    And the "Last name" should not equal the value ""

    And the "Contact number" should be enabled

    And the "Company Name" should not be enabled
    And the "Company Name" should not equal the value ""

    And the "Account Number" should not be enabled
    And the "Account Number" should not equal the value ""

    And the "Currency" should not be enabled
    And the "Currency" should not equal the value ""

    And the "Save Changes" should be enabled


  Scenario: Verify: - a presence of ADDRESS BOOK tab elements

    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "ADDRESS BOOK" tab
    Then I should be redirected to the "account-address-book" page
    And the "Delivery Address" should be displayed
    And the "Billing Address" should be displayed


  Scenario: Verify: - a presence of ORDERS tab elements

    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "ORDER HISTORY" tab
    Then I should be redirected to the "account-orders" page
    And the "Order picker" should be displayed
    And the "Date picker" should be displayed
    And the "Refresh" should be displayed
    And the "Orders table" should be displayed


  Scenario: Verify: - the STOCK CHECK & QUICK ORDER tab functionality

    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "STOCK CHECK & QUICK ORDER" tab
    Then I should be redirected to the "place-order" page


  # End-to-end Stock Check & Quick Order journey, starting from My Account
  # rather than navigating to place-order directly (see basket.feature for
  # the individual pieces tested in isolation).
  # 2026-09-28: expected prices updated for feature-hib-170 - confirmed
  # live the first "Vanquish" hit is now "Vanquish Bathroom Cabinet" (first
  # variant W53 x H73 x D12.5cm, £749.00; 3 = £2,247.00) rather than the
  # £84.00 item the search ranked first before.
  Scenario Outline: Search, add, adjust quantity and add a recommended product via Stock Check & Quick Order
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "account" page
    And I click on the "STOCK CHECK & QUICK ORDER" tab
    Then I should be redirected to the "place-order" page
    When I fill in the "Search products" input field with "<product>"
    And I wait for the search results to update
    Then the "search results" should be displayed
    When I click on the "first search result" element
    And I slowly click on the "first variant" element
    And I slowly click on the "Add to basket" button
    Then the "product's price" should contain the text "<price>"
    And the "Quantity selector" should equal the value "1"
    And the "product's total price" should contain the text "<price>"
    When I fill in the "Quantity selector" input field with "<new quantity>"
    And I click on the "Update" button
    Then the "product's total price" should contain the text "<new total>"
    # "basket subtotal", not "order total price": confirmed live on
    # feature-hib-170 (2026-09-28) that a 10% "Total discount" line now
    # appears (Subtotal £2,247.00, discount £224.70, RRP Total £2,022.30), so
    # the RRP total no longer equals the line total. The subtotal is what
    # reflects the quantity change being tested.
    And the "basket subtotal" should contain the text "<new total>"
    When I click on the "Products you may also need" button
    Then the "you may also need draw" should be displayed
    # 2026-09-28: the drawer's recommendations (Vanquish trims) are now
    # multi-variant, so each shows a "View Options" link to its own PDP
    # instead of an inline Add to basket - confirmed identical on staging and
    # feature-hib-170. Follow it, add a variant there, then come back.
    When I click on the "View Options - you may also need" element
    Then I should eventually be redirected to the "vanquish-trim" page
    And I wait for the page to settle
    And I click on the "first variant" button
    And the "Add to basket" should be enabled
    And I click on the "Add to basket" button
    And I click on the "Place Order" button
    Then I should be redirected to the "place-order" page
    And the "second basket item" should be displayed
    Examples:
      | product  | price | new quantity | new total |
      | Vanquish | 749.00 | 3            | 2,247.00  |