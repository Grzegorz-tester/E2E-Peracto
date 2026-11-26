@regression
Feature: Navigation

  # Covers Benchmarx BEN-394 (Next 15: header links did a full page reload
  # instead of a client-side navigation), re-checked on this site
  # 2026-11-26. A marker set on window survives a client-side navigation but
  # is wiped by a full document load. Confirmed live 2026-11-26: every
  # utility bar, logo, footer and menu-drawer link below is client-side on
  # staging. Our Accessories opens a side menu (tier-2 "View All") rather
  # than navigating, same as live.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present

  Scenario: Header, footer and menu links navigate client-side without a full page reload
    When I wait for the page to settle
    And I mark the current document so a full page reload can be detected
    And I click on the "Showroom Collection link" link
    Then I should be redirected to the "showroom-collection" page
    And the page should not have been fully reloaded since it was marked
    When I click on the "About Us link" link
    Then I should be redirected to the "about-us" page
    And the page should not have been fully reloaded since it was marked
    When I click on the "Contact Us link" link
    Then I should be redirected to the "contact-us" page
    And the page should not have been fully reloaded since it was marked
    When I click on the "header logo" link
    Then I should be redirected to the "home" page
    And the page should not have been fully reloaded since it was marked
    When I click on the "footer Warranty Finder link" link
    Then I should be redirected to the "warranty-finder" page
    And the page should not have been fully reloaded since it was marked
    When I click on the "footer FAQ link" link
    Then I should be redirected to the "faq" page
    And the page should not have been fully reloaded since it was marked
    When I click on the "footer Accessories link" link
    Then I should be redirected to the "accessories-plp" page
    And the page should not have been fully reloaded since it was marked
    When I click on the "Menu" button
    And I choose the "Our Accessories" category from the menu
    And I click on the "View All accessories" link
    Then I should be redirected to the "accessories-landing" page
    And the page should not have been fully reloaded since it was marked
