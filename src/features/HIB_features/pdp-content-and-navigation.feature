@regression
Feature: Product page (PDP) content and navigation

  # Built 2026-09-29 from a live inspection of feature-hib-170, compared
  # against production (www.hib.co.uk).
  #
  # - Guests see price, gallery, variants, specifications and downloads but
  #   no Add to basket: ordering is portal-only (logged-in retailers).
  # - Variant selection is slow on the release branch: the URL updates at
  #   once (?size=60cm), but the selected state and the price take ~5-10s to
  #   follow, and on some products the variant list briefly re-renders.
  #   Production updates near-instantly. The assertions below poll (15s)
  #   rather than check once.
  # - The mapping keys live in common.json, so these steps work on any PDP.

  Scenario: The PDP shows the product's core content
    Given I am on the "solas" page
    And I dismiss the newsletter popup if present
    Then a heading with the text "Solas Round Illuminated Bathroom Mirror - Chrome" should be displayed
    And the "product price" should contain the text "£"
    And the "product gallery image" should be displayed
    And the "product gallery thumbnail" should be displayed
    And the "product variant options" should be displayed
    And the "first variant" should be displayed
    And the "second variant" should be displayed
    And the "specification labels" should be displayed
    And the "specification values" should be displayed
    And the "product video" should be displayed
    And the "related products" should be displayed
    And the "related articles" should be displayed


  Scenario: A guest is not offered Add to basket on the PDP
    Given I am on the "solas" page
    And I dismiss the newsletter popup if present
    Then the "product price" should contain the text "£"
    And the "Add to basket" should not appear within "5" seconds


  Scenario: Selecting a different variant selects it and updates the price, and switching back restores it
    Given I am on the "solas" page
    And I dismiss the newsletter popup if present
    And I wait for the page to settle
    When I remember the text of "product price" as "first variant price"
    And I click on the "second variant" button
    Then the "second variant" should have class "border-brand-primary"
    And the "product price" text should not equal the remembered "first variant price"
    When I click on the "first variant" button
    Then the "first variant" should have class "border-brand-primary"
    And the "product price" text should equal the remembered "first variant price"


  Scenario: The PDP downloads (technical data sheet, fitting instructions) resolve
    Given I am on the "solas" page
    And I dismiss the newsletter popup if present
    Then the "product downloads" should be displayed
    And all "product downloads" links should resolve without an error


  Scenario: Clicking a "You May Also Like" product opens that product's own PDP
    Given I am on the "solas" page
    And I dismiss the newsletter popup if present
    When I click on the "first related product" element
    Then I should eventually be redirected to the "product" page
    And the "application error" should not appear within "5" seconds
    And the "product price" should contain the text "£"


  Scenario: Clicking a related article opens that article
    Given I am on the "solas" page
    And I dismiss the newsletter popup if present
    When I click on the "first related article" element
    Then I should eventually be redirected to the "article" page
    And the "application error" should not appear within "5" seconds
    And the "page not found" should not be displayed
    And the "page title" should be displayed


  Scenario: A logged-in retailer is offered Add to basket on the PDP
    Given I am navigating the page as a "logged in" user
    And I dismiss the newsletter popup if present
    When I am on the "solas" page
    And I wait for the page to settle
    Then the "Add to basket" should be displayed
