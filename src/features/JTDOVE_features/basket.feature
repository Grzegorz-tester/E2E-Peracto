@regression
Feature: Basket page

  # Full rewrite (2026-10-05). The previous version searched for HIB
  # products ("Greg's Mirror", "Solas") from an inline basket search box and
  # opened "Specifications"/"You may also need" drawers - none of which exist
  # on JT Dove. Runs as a guest: every scenario gets a fresh browser context,
  # so the basket is always empty to start with and never collides with the
  # shared logged-in test account's server-side basket.

  Background:
    Given I am navigating the page as a "guest" user


  Scenario: An empty basket says so
    Given I am on the "basket" page
    And I wait for the page to settle
    Then the "basket title" should contain the text "Basket"
    And the "no items message" should be displayed
    And the "Go to checkout" should not be displayed


  Scenario: A product added from the PDP is listed with its price and totals
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    Then the "basket line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And the "basket line sku" should contain the text "310239"
    And the "basket line price" should contain the text "£56.98"
    And the "basket sub total" should contain the text "£56.98"
    And the "basket total" should contain the text "£56.98"
    And the basket sub total should equal the sum of all basket line totals
    And the "Go to checkout" should be displayed


  Scenario: Changing the quantity updates the line and basket totals
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    And the "basket line name" should be displayed
    When I click precisely on the "basket quantity increment" element
    And I wait for the basket update to complete
    Then the "basket quantity input" should equal the value "2"
    And the "basket total" should contain the text "£113.96"
    When I click precisely on the "basket quantity decrement" element
    And I wait for the basket update to complete
    Then the "basket quantity input" should equal the value "1"
    And the "basket total" should contain the text "£56.98"


  Scenario: Removing the only product empties the basket
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    And the "basket line name" should be displayed
    When I click on the "Remove item" button
    Then the "no items message" should be displayed


  Scenario: A delivery line can be switched to Click & Collect at a branch
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    And the "basket line name" should be displayed
    When I click on the "Collect at branch toggle" button
    And the "Select this branch" should be displayed within "30" seconds
    And I click on the "Select this branch" element
    Then the "collect at branch heading" should be displayed within "15" seconds


  Scenario: An invalid promotional code is rejected
    Given I am on the "test-product" page
    And I wait for the page to settle
    When I click on the "DELIVERY" button
    And the "added to basket drawer" should be displayed within "15" seconds
    And I am on the "basket" page
    And I wait for the page to settle
    And the "basket line name" should be displayed
    When I click on the "Add a promotional code?" element
    And I fill in the "Promo code input" input field with "VELSTARTESTINVALID"
    And I click on the "Apply promo code" button
    Then the "promo code error" should be displayed
    And the "basket total" should contain the text "£56.98"


  Scenario: Continue shopping returns to the home page
    Given I am on the "basket" page
    And I wait for the page to settle
    When I click on the "Continue shopping" element, retrying until redirected to the "home" page
