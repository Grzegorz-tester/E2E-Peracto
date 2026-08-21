@regression
Feature: Footer newsletter sign-up, company details and social links

  # Covers the manual test plan's "Footer" suite (5 cases). Newsletter
  # input is a native <input type="email" required> - same pattern as
  # Insinkerator's footer-newsletter-signup.feature, confirmed live
  # (2026-08-21): a valid submission reveals a "newsletter-form__alert"
  # containing "Thank you"/"subscri..." text.

  Background:
    Given I am on the "home" page

  @smoke
  Scenario: User can submit the newsletter form, which validates email input and surfaces a response
    Then the "newsletter form" should be displayed
    And the "newsletter email input" should be displayed
    And the "newsletter submit button" should be displayed

    When I fill in the "newsletter email input" input field with ""
    And I click on the "newsletter submit button" button
    Then the "newsletter email input" input should be rejected as empty
    And the "newsletter alert" should not be displayed

    When I fill in the "newsletter email input" input field with "not-an-email"
    And I click on the "newsletter submit button" button
    Then the "newsletter email input" input should be rejected as invalid
    And the "newsletter alert" should not be displayed

    When I fill in the "newsletter email input" input field with a unique guest email
    And I click on the "newsletter submit button" button
    Then the "newsletter alert" should contain the text "Thank you"

  Scenario: Company registration details are displayed in the footer
    Then the "footer company details" should contain the text "Company Registration No"
    And the "footer company details" should contain the text "VAT No"

  Scenario Outline: Social media icons in the footer link out correctly
    Then the "<icon>" should be displayed
    Examples:
      | icon                    |
      | Facebook footer icon    |
      | Twitter footer icon     |
      | Instagram footer icon   |
      | TikTok footer icon      |
      | YouTube footer icon     |
      | LinkedIn footer icon    |

  Scenario Outline: Footer links redirect to the correct page
    When I click on the "<link>" element
    Then I should be redirected to the "<page>" page

    Examples:
      | link                             | page           |
      | Privacy Policy footer link       | privacy-policy |
      | Terms and Conditions footer link | terms-and-conditions |
