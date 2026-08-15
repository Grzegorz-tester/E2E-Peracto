@regression
Feature: Product registration

  # Ported from Insinkerator_EU's product-registration.feature. This site
  # is single-market (no locale prefix on the route, unlike the EU site's
  # /en-gb, /de, etc.) - there is only one registration form to cover.
  #
  # Place of purchase is marked required (an asterisk on its label) AND the
  # submit button stays disabled while it's empty - both the UI and backend
  # agree on this field being mandatory.

  Background:
    Given I am on the "product-registration" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: The registration form displays, with Place of purchase marked required
    Then the "registration first name input" should be displayed
    And the "registration last name input" should be displayed
    And the "registration email input" should be displayed
    And the "registration place of purchase input" should be displayed
    And the "registration serial number input" should be displayed
    And the "Submit" should be displayed
    And the "registration place of purchase label" should contain the text "*"

  Scenario: Leaving Place of purchase blank keeps the submit button disabled
    When I fill in a freshly generated product registration except "placeOfPurchase", remembering it as "incomplete registration"
    Then the "Submit" should not be enabled

  Scenario: A fully completed registration submits successfully
    When I fill in a freshly generated product registration, remembering it as "uk registration"
    And I click on the "Submit" button
    Then the "success icon" should be displayed
