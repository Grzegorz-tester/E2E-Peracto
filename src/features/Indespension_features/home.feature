@regression
Feature: Home page

  # Previously carried a large block of commented-out scenarios cloned from
  # HIB (bathroom category cards - "Mirrors card", "BATHROOM LIGHTING",
  # etc.) that never applied to this trailer/towbar storefront. Removed
  # rather than adapted - Indespension's homepage has no equivalent fixed
  # set of category cards to assert against; its real content (USP bar,
  # newsletter signup, product carousels) is covered by other features
  # (header.feature's USP/menu coverage, footer-newsletter-signup once
  # written).

  @smoke
  Scenario: Verify page elements
    Given I am on the "home" page
    Then the "header logo" should be displayed
