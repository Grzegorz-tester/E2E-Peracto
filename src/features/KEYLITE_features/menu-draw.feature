@regression
Feature: Mobile navigation drawer

  # Confirmed live 2026-09-06: the mobile hamburger ("Mobile menu",
  # brand-bar__menu-button) only renders at a mobile viewport width - the
  # desktop nav uses a separate always-visible bar, not this drawer. The
  # drawer's own outer container (navigation-drawer) is a zero-size Radix
  # portal wrapper that never reports Playwright-"visible" even once open -
  # its links inside genuinely are, so those are asserted on instead.
  # Links found: QA Smoke Test Page, Products, Replace My Window,
  # Homeowners, Professionals, Support, Find Installer - same content as
  # the desktop nav (see home.feature).

  Scenario: Opening the mobile menu shows the main navigation links
    Given I resize the browser to a "mobile" viewport
    And I am on the "home" page
    And I dismiss the newsletter popup if present
    When I click on the "Mobile menu" button
    Then the "navigation drawer links" should be displayed

  # NOT COVERED: actually navigating from a drawer link. Confirmed live
  # 2026-09-06 - this drawer is a Radix Sheet portal, and neither a real
  # (even JS-dispatched) click on its links ever navigates in headless
  # automation (repeatedly stayed on "/" with no error), NOR does the link
  # carry a real href to check instead (confirmed href="" on the actual
  # DOM node - routing here is entirely onClick-driven with no URL
  # fallback). Both approaches used elsewhere in this suite for a
  # similarly awkward click (JS-dispatch, or checking href directly) come
  # up empty here, so this is left as a known gap rather than asserting
  # something that was never actually verified working.
