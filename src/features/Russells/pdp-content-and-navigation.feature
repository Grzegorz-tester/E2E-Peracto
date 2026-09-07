@regression
Feature: PDP content and navigation

  # Confirmed on a simple (non-bundle) product PDP - accordion section
  # count/starting state is content-dependent per product, so only the
  # single-open toggle behaviour itself is asserted, not any specific
  # starting state. No FAQ accordion, feature carousel, comparison table,
  # image zoom or configurator has been confirmed on any Russells product
  # yet (RUS-474) - those Insinkerator PDP features have no known
  # equivalent here.

  Background:
    Given I navigate directly to the path "/products/roller-for-cnh-nh-92087109"
    And I click on the "Accept cookies" button if present
    And the "product name" should be displayed
    And the "product SKU" should be displayed
    And the "product price" should be displayed

  @smoke
  Scenario: Accordion allows only one section open at a time
    Then the "accordion trigger" accordion should allow only one section open at a time

  Scenario: Thumbnail carousel Previous is disabled until Next is clicked
    Then the "thumbnail prev" should not be enabled
    When I click on the "thumbnail next" button
    Then the "thumbnail prev" should be enabled
