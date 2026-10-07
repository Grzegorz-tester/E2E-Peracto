@regression
Feature: Footer and newsletter sign-up

  # New coverage (2026-10-05).
  # KNOWN SITE ISSUE: the newsletter block's own "Privacy Policy" link (on
  # every page, plus the contact/basket/checkout pages) points at
  # /privacy-policy, which 404s on staging. The footer's "Privacy Policy"
  # link uses /privacy-policy-nov-2023, which works. The footer's
  # "Cookie Policy" link (/cookie-policy) also 404s. Both confirmed in a real
  # browser. The link-resolution scenarios below are expected to stay red
  # until those are fixed.

  Scenario: Footer shows company details and social links
    Given I am on the "home" page
    And I wait for the page to settle
    Then the "footer company info" should contain the text "Company Registration No: 00085529"
    And the "Facebook icon" should have attribute "href" containing "facebook.com/JTDoveBuildingMaterials"
    And the "Instagram icon" should have attribute "href" containing "instagram.com/jtdove_buildingmaterials"
    And the "LinkedIn icon" should have attribute "href" containing "linkedin.com/company/4834260"
    And the "eCommerce by Velstar" should have attribute "href" containing "velstar.co.uk"


  Scenario: Every footer navigation link resolves
    Given I am on the "home" page
    And I wait for the page to settle
    Then all "footer navigation links" links should resolve without an error


  Scenario: Newsletter privacy policy link resolves
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "newsletter privacy policy link" element
    Then the "not found heading" should not be displayed
    And the "category page title" should contain the text "Privacy"


  Scenario: Newsletter rejects an invalid email address
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "newsletter email input" input field with "not_an_email@"
    And I click on the "newsletter subscribe" button
    Then the "newsletter email input" input should be rejected as invalid
    And the "newsletter success message" should not be displayed


  # Subscribes a Velstar-owned address (Klaviyo), so no real customer is
  # contacted.
  # SUSPECTED ISSUE (2026-10-07): passed earlier the same week, but the
  # subscribe server action (POST /) now returns 403 and no alert ever
  # renders, even from a plain browser - possibly rate limiting after
  # repeated test subscriptions. Expected red until confirmed either way.
  @submits-real-form
  Scenario: Newsletter sign-up confirms the subscription
    Given I am on the "home" page
    And I wait for the page to settle
    When I fill in the "newsletter email input" input field with a unique email, remembering it as "newsletter email"
    And I click on the "newsletter subscribe" button
    Then the "newsletter success message" should be displayed within "30" seconds
    And the "newsletter success message" should contain the text "Thank you for subscribing to our newsletter."
