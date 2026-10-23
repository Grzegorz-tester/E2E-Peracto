@regression
Feature: Card payment failures

  # Declined-card journeys (added 2026-10-23), kept out of the @smoke guest
  # purchase journey because one of them is a known site defect.

  # Manual cases 87/89 (added 2026-10-23). Any card number not on Opayo's
  # test list is declined in the sandbox (the "declined" test card,
  # 4111 1111 1111 1111). Starts a real order on staging that stays unpaid.
  @places-real-order
  Scenario: A declined card is refused and the order isn't completed
    Given I require staging for this scenario
    And I am navigating the page as a "guest" user
    And I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    And the "basket line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    And I click on the "Guest checkout option" element, retrying until the "guest email" is displayed
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "Continue as guest" button
    Then I should eventually be redirected to the "checkout-delivery" page
    And I wait for the page to settle
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I pick the first Loqate address for the postcode "NE46 4DQ" in the "address search" field
    And I click on the "Use this address" button
    Then the "current address postcode" should contain the text "NE46 4DQ"
    And the "outside delivery area message" should not be displayed
    When I click on the "Dove Delivery option" element
    And I fill in the "contact mobile" input field with "07700900000"
    And I fill in the "delivery notes" input field with "Velstar Test - automated test order, please ignore"
    And I click on the "Delivery Continue" button
    Then I should eventually be redirected to the "checkout-billing" page
    And I wait for the page to settle
    When I click on the "Same as delivery address" element
    And I click on the "Billing Continue" button
    Then I should eventually be redirected to the "checkout-review" page
    And I wait for the page to settle
    And the "review product name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    When I click on the "PROCEED TO PAYMENT" button
    And I pay with the "declined" Opayo test card
    Then the "Opayo decline message" should be displayed within "30" seconds
    And the "Opayo card choices" should be displayed
    And the current URL should contain "opayo"


  # KNOWN SITE ISSUE (confirmed live 2026-10-23): pressing Cancel on Opayo
  # after a decline sends the customer to /checkout, which is a 404 on
  # staging, the 4-4-0 release AND production (www.jtdove.co.uk/checkout).
  # Their basket survives, but they land on "We couldn't find the page".
  # Expected to stay red until the payment cancel URL points at a real
  # checkout page.
  @places-real-order
  Scenario: Cancelling after a declined card takes the customer back to their checkout
    Given I require staging for this scenario
    And I am navigating the page as a "guest" user
    And I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    And the "basket line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    And I click on the "Guest checkout option" element, retrying until the "guest email" is displayed
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "Continue as guest" button
    Then I should eventually be redirected to the "checkout-delivery" page
    And I wait for the page to settle
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I pick the first Loqate address for the postcode "NE46 4DQ" in the "address search" field
    And I click on the "Use this address" button
    Then the "current address postcode" should contain the text "NE46 4DQ"
    And the "outside delivery area message" should not be displayed
    When I click on the "Dove Delivery option" element
    And I fill in the "contact mobile" input field with "07700900000"
    And I fill in the "delivery notes" input field with "Velstar Test - automated test order, please ignore"
    And I click on the "Delivery Continue" button
    Then I should eventually be redirected to the "checkout-billing" page
    And I wait for the page to settle
    When I click on the "Same as delivery address" element
    And I click on the "Billing Continue" button
    Then I should eventually be redirected to the "checkout-review" page
    And I wait for the page to settle
    And the "review product name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    When I click on the "PROCEED TO PAYMENT" button
    And I pay with the "declined" Opayo test card
    Then the "Opayo decline message" should be displayed within "30" seconds
    When I click on the "Opayo Cancel" element
    And I wait for the page to settle
    Then the "not found heading" should not be displayed
    And the current URL should contain "/checkout/"
