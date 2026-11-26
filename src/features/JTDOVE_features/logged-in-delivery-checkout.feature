@regression
Feature: Logged-in delivery checkout

  # Added 2026-11-19. Until now the only logged-in card checkout was Click &
  # Collect, and only the guest decline was covered (manual case 87 is the
  # logged-in cash customer's decline).
  #
  # Runs as the shared cash account ("logged in", account 103128, pays by
  # card through Opayo), using its saved default address. On 2026-11-19 that
  # was a Harrogate (HG1) address, which IS in the delivery area (DOVE
  # Delivery, £11 ex VAT). The address is shared and others edit it: if these
  # fail on "outside delivery area message", check the account's address
  # first. Delivery doesn't depend on branch stock, but logged-in payment
  # does depend on Kerridge (account status check, see Background).
  #
  # WARNING: the first scenario places a REAL delivery order on staging.

  Background:
    Given I require staging for this scenario
    And I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I wait for the page to settle
    And I clear the basket
    And I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    And the "basket line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    And the "logged in as" should contain the "logged in" user's email
    And I click on the "Signed in Continue" button
    Then I should eventually be redirected to the "checkout-delivery" page
    And I wait for the page to settle
    When I click on the "Saved address Continue" button
    Then the "outside delivery area message" should not be displayed
    When I click on the "Dove Delivery option" element
    And I fill in the "contact mobile" input field with "07700900000"
    And I fill in the "delivery notes" input field with "Velstar Test - automated test order, please ignore"
    And I click on the "Delivery Continue" button
    Then I should eventually be redirected to the "checkout-billing" page
    And I wait for the page to settle
    When I click on the "Saved address Continue" button
    Then I should eventually be redirected to the "checkout-review" page
    And I wait for the page to settle
    And the "review product name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    # Logged-in payment needs a live account-status check against Kerridge.
    # On 2026-11-19 (Kerridge down) PROCEED TO PAYMENT showed "we are unable
    # to check the status of your account at this time" and never reached
    # Opayo; the pay step then fails quoting that message.
    When I click on the "PROCEED TO PAYMENT" button


  @places-real-order
  Scenario: A logged-in cash customer pays by card for a delivery order
    When I pay with the "default" Opayo test card
    Then I should eventually be redirected to the "thank-you" page
    And the "order reference" should be displayed
    And the "order line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    # The order reached Peracto admin, paid, as a delivery line.
    When I remember the part of the "order reference" text matching the pattern "\d{6}" as "order reference"
    And I authenticate against the API as the "admin" user
    And I GET the API path "/orders?reference={{order reference}}"
    Then the response status should be 200
    And the response JSON at "hydra:totalItems" should equal "1"
    And the response JSON at "hydra:member[0].status" should equal "successful"
    And the response JSON at "hydra:member[0].lines" should contain an entry whose "item.sku" is "310239" and whose "shippingServiceType" is "delivery"
    And the response JSON at "hydra:member[0].deliveryAddress.postalCode" should be present


  # Case 87. Opayo's sandbox declines any card number not on its test list.
  @places-real-order
  Scenario: A logged-in cash customer's declined card is refused
    When I pay with the "declined" Opayo test card
    Then the "Opayo decline message" should be displayed within "30" seconds
    And the "Opayo card choices" should be displayed
    And the current URL should contain "opayo"
