@regression
Feature: Ex VAT / Inc VAT price display toggle

  # Shared across every Watco market. CONFIRMED LIVE (staging-uk,
  # 2026-09-09): the header's "Ex VAT" control is a plain link
  # (href="/toggle-tax/...") that does a full page navigation and flips
  # which of two always-present spans ("Ex VAT" / "Inc VAT") is hidden via
  # a "d-none" class - not a client-side-only re-render, and not something
  # a raw "should contain the text" check can see, since BOTH labels are
  # always present in the DOM regardless of which one is currently shown.

  Scenario: Toggling the price display switches the visible Ex VAT / Inc VAT label
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    Then the "Ex VAT label" should not have class "d-none"
    And the "Inc VAT label" should have class "d-none"

    When I click on the "Ex VAT toggle" element
    Then the "Inc VAT label" should not have class "d-none"
    And the "Ex VAT label" should have class "d-none"

    When I click on the "Ex VAT toggle" element
    Then the "Ex VAT label" should not have class "d-none"
    And the "Inc VAT label" should have class "d-none"
