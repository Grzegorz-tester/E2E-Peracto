@MIPA_regression
Feature: Products page functionality


  Scenario: Filtering products
    Given I am on the "bathroom-cabinets" page
    When I click on the "Filter" element
    And I click on the "Apex checkbox" element


  Scenario: Sorting products
    Given I am on the "bathroom-mirrors" page
    When I click on the "Sort By" dropdown
#    And I click on the "A-Z" element
