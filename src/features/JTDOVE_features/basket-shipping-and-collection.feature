@regression
Feature: Basket shipping and Click & Collect rules

  # Manual regression cases 111-119 (added 2026-10-23). Guest baskets only,
  # so nothing touches the shared account.
  #
  # Test products (staging, chosen 2026-10-23 from the live catalogue):
  # - Marine Plywood 310239: JT Dove delivery ("Delivery" shipping type).
  # - Scruffs Trade Neck Warmer 203734: courier, no Click & Collect.
  # - Brett Martin overflow tee 668087: Click & Collect, stocked at only two
  #   or three branches, so other branches can't take it.
  # - Yellow Building Sand 25kg 351725: Click & Collect, stocked at about 20
  #   branches.
  # Branch stock is live ERP data and moves around, so the scenarios never
  # name a branch: they take whichever branch the stock pop-up lists first
  # (highest stock) and check the rules relative to that. If the tee ever
  # runs out at every branch, swap in another narrowly-stocked product.


  Scenario: Each basket line shows its own delivery service
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "courier-product" page
    And I wait for the page to settle
    Then the "CLICK & COLLECT" should not be displayed
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "narrow-stock-product" page
    And I wait for the page to settle
    And I click on the "CLICK & COLLECT" button
    Then the "branch picker" should be displayed within "15" seconds
    When I click on the first enabled "Select this branch buttons" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    Then the "collect at branch section" should contain the text "Brett Martin Waste White Overflow Tee"
    And the "collect at branch name" should contain the text "JT Dove"
    And the "delivery section" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And the "delivery section" should contain the text "Scruffs Trade Neck Warmer"
    And the "delivery section" should contain the text "Delivered by Courier"
    And the "courier message" should contain the text "The delivery charge will be calculated at checkout"
    And the "collect at branch section" should not contain the text "Delivered by Courier"


  Scenario: Every collection item must come from the one selected branch
    Given I am on the "narrow-stock-product" page
    And I wait for the page to settle
    When I click on the "CLICK & COLLECT" button
    And I click on the first enabled "Select this branch buttons" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I remember the text of "collect at branch name" as "basket branch"
    # A second collection product is checked against the basket's branch
    When I am on the "wide-stock-product" page
    And I wait for the page to settle
    And I click on the "CLICK & COLLECT" button
    Then the "branch picker selected branch note" should contain the remembered "basket branch"
    When I click on the first enabled "Select this branch buttons" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    Then the "collect at branch name" text should equal the remembered "basket branch"
    And the "collect at branch section" should contain the text "Brett Martin Waste White Overflow Tee"
    And the "collect at branch section" should contain the text "Yellow Building Sand"


  Scenario: Change Branch only offers branches that stock the whole basket
    Given I am on the "narrow-stock-product" page
    And I wait for the page to settle
    When I click on the "CLICK & COLLECT" button
    And I click on the first enabled "Select this branch buttons" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I remember the text of "collect at branch name" as "original branch"
    When I click on the "Change Branch" button
    Then the "branch picker" should be displayed within "15" seconds
    And the "branch picker in stock" should be displayed
    And the "branch picker out of stock" should be displayed
    And the "disabled branch select" should be displayed


  # Manual cases 119 and 213/214 (smoke). Places a REAL order on staging
  # every run (Opayo sandbox card, no money moves), with Velstar details
  # throughout.
  @places-real-order
  Scenario: A guest can check out a basket mixing JT Dove delivery, courier and Click & Collect
    Given I require staging for this scenario
    And I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "courier-product" page
    And I wait for the page to settle
    And I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "wide-stock-product" page
    And I wait for the page to settle
    And I click on the "CLICK & COLLECT" button
    And I click on the first enabled "Select this branch buttons" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    And I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    And I click on the "Guest checkout option" element, retrying until the "guest email" is displayed
    And I fill in the "guest email" input field with a unique guest email
    And I click on the "Continue as guest" button
    # Collection comes first in a mixed basket, then delivery for the rest
    # (confirmed live 2026-10-23).
    Then I should eventually be redirected to the "checkout-click-and-collect" page
    And I wait for the page to settle
    And the "click and collect branch" should contain the text "JT Dove"
    When I fill in the "contact mobile" input field with "07700900000"
    And I click on the "Click and collect Continue" button
    Then I should eventually be redirected to the "checkout-delivery" page
    And I wait for the page to settle
    When I fill in the "address first name" input field with "Velstar"
    And I fill in the "address last name" input field with "Test"
    And I pick the first Loqate address for the postcode "NE46 4DQ" in the "address search" field
    And I click on the "Use this address" button
    Then the "current address postcode" should contain the text "NE46 4DQ"
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
    And the "review collection branch" should be displayed
    And the "page content" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And the "page content" should contain the text "Scruffs Trade Neck Warmer"
    And the "page content" should contain the text "Yellow Building Sand"
    And the "page content" should contain the text "Courier"
    When I click on the "PROCEED TO PAYMENT" button
    And I pay with the "default" Opayo test card
    Then I should eventually be redirected to the "thank-you" page
    And the "thank you heading" should be displayed
    And the "order reference" should be displayed
    And the "page content" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And the "page content" should contain the text "Scruffs Trade Neck Warmer"
    And the "page content" should contain the text "Yellow Building Sand"
