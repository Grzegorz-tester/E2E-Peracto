@regression
Feature: Swatch samples

  # Built 2026-09-29 from a live inspection of feature-hib-170 and production.
  # Swatches are ordinary (free) products: the menu's "Samples" goes to
  # /swatch-samples, whose "Order samples" / "View all" links lead to the
  # /category/bathroom-swatches category, and each swatch is ordered through
  # the portal basket like any other product. Navigation only - nothing is
  # added to a basket or ordered here.
  #
  # The header's "Request Swatch Sample" icon goes to /samples instead,
  # which only has a "Request Swatch Sample" heading and no other content,
  # on production as well. header.feature checks that redirect; whether
  # /samples is meant to be that empty is a question for HIB.

  Scenario: The Swatches page links through to the swatch category
    Given I am on the "swatch-samples" page
    And I dismiss the newsletter popup if present
    Then a heading with the text "Swatches" should be displayed
    When I click on the "Order samples link" link
    Then I should eventually be redirected to the "category" page
    And the "product card" should be displayed
    And the "product card name" should contain the text "Swatch"


  Scenario: A featured swatch on the Swatches page opens its own PDP
    Given I am on the "swatch-samples" page
    And I dismiss the newsletter popup if present
    When I click on the "first featured swatch" element
    Then I should eventually be redirected to the "product" page
    And the "application error" should not appear within "5" seconds
    And the "product gallery image" should be displayed
