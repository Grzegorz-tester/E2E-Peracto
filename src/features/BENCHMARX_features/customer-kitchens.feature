@smoke @regression
Feature: Customer kitchens gallery

  # Qase BEN-117, BEN-118, BEN-119. Built 2026-10-24 from a live inspection
  # of staging's /customer-kitchens grid. A card opens a modal (no
  # role=dialog or data-testid on it, so its mappings anchor on the "Browse
  # by style" heading). The X and a click on the dark backdrop both close
  # it; Escape does not (confirmed live, not asserted here). Style pills
  # link to /kitchen-ranges/<style>; "Get this look" cards link to a PDP.

  Scenario: The kitchen modal opens from a card and closes with the X or a click outside it
    Given I am on the "customer-kitchens" page
    Then the "kitchen cards" should be displayed
    When I click on the "first kitchen card" element
    Then the "kitchen modal" should be displayed
    And the "kitchen modal title" should be displayed
    When I click on the "kitchen modal close button" button
    Then the "kitchen modal" should not be displayed
    And the "kitchen cards" should be displayed
    When I click on the "first kitchen card" element
    Then the "kitchen modal" should be displayed
    When I click outside the "kitchen modal"
    Then the "kitchen modal" should not be displayed
    And the "kitchen cards" should be displayed

  Scenario: The kitchen modal's image gallery moves between images
    Given I am on the "customer-kitchens" page
    When I click on the "first kitchen card" element
    Then the "kitchen modal main image" should be displayed
    And the "kitchen modal main image" image should return a 200 OK response with content-type "image/"
    And the "1st" "kitchen gallery dots" should have class "text-white"
    When I click on the "kitchen gallery next arrow" button
    Then the "2nd" "kitchen gallery dots" should have class "text-white"
    And the "1st" "kitchen gallery dots" should not have class "text-white"
    When I click on the "kitchen gallery next arrow" button
    Then the "3rd" "kitchen gallery dots" should have class "text-white"
    When I click on the "kitchen gallery previous arrow" button
    Then the "2nd" "kitchen gallery dots" should have class "text-white"

  Scenario: A style pill opens that kitchen style's range page
    Given I am on the "customer-kitchens" page
    When I click on the "first kitchen card" element
    Then the "style pills" should be displayed
    When I click on the "first style pill" button
    Then I should be redirected to the "kitchen-range" page
    And the "product cards" should be displayed

  Scenario: A Get this look card opens that kitchen's PDP
    Given I am on the "customer-kitchens" page
    When I click on the "first kitchen card" element
    And I remember the text of "first get this look card" as "look"
    And I click on the "first get this look card" link
    Then I should be redirected to the "pdp" page
    And the "product title" should contain the remembered "look"

  Scenario: The kitchen modal's consultation button opens the booking form
    Given I am on the "customer-kitchens" page
    When I click on the "first kitchen card" element
    And I click on the "kitchen modal Book a design consultation" link
    Then I should be redirected to the "book-a-consultation" page
    And the "step heading" should contain the text "Find your nearest branch"
