@regression
Feature: Shopping at phone width

  # Added 2026-11-19 for the Next.js upgrade tickets: until now only the side
  # drawer ran at mobile width. Uses the same 390x844 viewport as the drawer
  # feature. Baseline confirmed live 2026-11-19: no core page scrolls
  # sideways at 390px, and the PDP shows both DELIVERY and CLICK & COLLECT
  # (each button is rendered twice, one copy hidden per breakpoint, which is
  # why the mappings use :visible). Never places an order.

  Scenario Outline: The <page> page fits a phone screen without sideways scrolling
    Given I am on the "home" page
    And I resize the browser to a "mobile" viewport
    When I navigate directly to the path "<path>"
    And I wait for the page to settle
    Then the "not found heading" should not be displayed
    And the page should not scroll horizontally
    Examples:
      | page     | path                                    |
      | home     | /                                       |
      | category | /category/Special-Offers                |
      | product  | /products/2440x1220x18mm-marine-plywood |
      | search   | /search?q=plywood                       |
      | branches | /branches                               |
      | branch   | /branches/hexham                        |
      | basket   | /basket                                 |
      | login    | /login                                  |


  Scenario: A guest on a phone can add to basket and start checkout
    Given I am on the "home" page
    And I resize the browser to a "mobile" viewport
    And I am on the "test-product" page
    And I wait for the page to settle
    Then the "CLICK & COLLECT" should be displayed
    When I click on the "DELIVERY" button
    Then the "added to basket drawer" should be displayed within "15" seconds
    When I am on the "basket" page
    And I wait for the page to settle
    Then the "basket line name" should contain the text "Marine Plywood Sheet (2440 x 1220 x 18mm)"
    And the page should not scroll horizontally
    When I click on the "Go to checkout" element, retrying until redirected to the "checkout-sign-in" page
    And I wait for the page to settle
    Then the page should not scroll horizontally


  Scenario: A phone user can search from the menu drawer
    Given I am on the "home" page
    And I resize the browser to a "mobile" viewport
    And I wait for the page to settle
    When I click on the "Menu button" element
    Then the "navigation drawer" should be displayed
    When I fill in the "drawer search input" input field with "310239"
    And I wait for the search results to update
    Then the "first search result" should contain the text "Marine Plywood"
