@PizzaExpressLive_regression
Feature: Navigation, basket, account and mobile
  Basket and My Account are, like booking (see spektrix-booking.feature),
  entirely inside the Spektrix iframe - so these scenarios confirm the right
  iframe loads on each page rather than logging in or driving basket
  contents, for the same Cloudflare/production reasons documented there.

  # The header "Venues" dropdown itself lists only the 3 PizzaExpress Live
  # venues (Soho, Holborn, Chelsea) - confirmed live 2026-08-20 by scoping
  # to the dropdown's own [role="dialog"], not the whole page (Covent
  # Garden and Piano Lounge (Leicester Square) exist as pages but aren't
  # in this particular dropdown; Piano Lounge has its own separate nav item).
  # Also permanently strips the undismissable "outdated browser" banner
  # first - the same top-of-viewport click-interception risk as every
  # other header click in this project, and confirmed live that a one-shot
  # "removing the X overlay if it interferes" isn't reliable here (it
  # keeps reappearing, so removal and the click can still lose the race).
  Scenario: Header nav Venues dropdown lists the 3 Live venues
    Given I am on the "home" page
    And I permanently remove the "outdated browser banner" overlay for this scenario
    When I click on the "Venues nav dropdown" button
    Then the "Soho venue dropdown link" should be displayed
    And the "Holborn venue dropdown link" should be displayed
    And the "Chelsea venue dropdown link" should be displayed
    When I click on the "Holborn venue dropdown link" element
    Then I should be redirected to the "venue-holborn" page

  Scenario: Basket page loads the Spektrix basket iframe
    Given I am on the "basket" page
    Then the "booking iframe" should be displayed
    And the "booking iframe" should have attribute "src" containing "bookings.pizzaexpresslive.com/pizzaexpress/website/Basket2.aspx"

  Scenario: Account page loads the Spektrix account iframe
    Given I am on the "account" page
    Then the "booking iframe" should be displayed
    And the "booking iframe" should have attribute "src" containing "bookings.pizzaexpresslive.com/pizzaexpress/website/secure/MyAccount.aspx"

  Scenario Outline: Footer renders across pages
    Given I am on the "<page>" page
    Then the "desktop footer" should be displayed
    And the "desktop footer socials" should be displayed
    And the "desktop footer bottom links" should be displayed
    Examples:
      | page       |
      | home       |
      | whats-on   |
      | about-us   |
      | membership |

  # The source test case also expects a basket icon directly in the mobile
  # header, alongside the hamburger/logo/account icon - not confirmed live:
  # this production build's mobile-navigation testid group has no basket
  # icon of its own (only the drawer, opened via the hamburger, has one -
  # see the next scenario). Asserting one here would be testing something
  # that doesn't currently exist rather than a real regression.
  Scenario: Mobile viewport renders nav elements
    When I resize the browser to a "mobile" viewport
    And I am on the "home" page
    Then the "hamburger button" should be displayed
    And the "mobile logo" should be displayed
    And the "mobile account icon" should be displayed

  # A permanent, undismissable "outdated browser" banner (confirmed live,
  # both viewports, no close button) sits fixed at the top of every page
  # and intercepts clicks on anything underneath it, and keeps reappearing
  # after a one-shot removal - permanently stripping it up front is what
  # actually made this scenario reliable (see the Venues dropdown scenario
  # above for the same fix).
  Scenario: Mobile hamburger menu opens and expands Venues
    When I resize the browser to a "mobile" viewport
    And I am on the "home" page
    And I permanently remove the "outdated browser banner" overlay for this scenario
    And I click on the "hamburger button" button
    Then the "navigation drawer" should be displayed
    When I click on the "navigation drawer Venues link" element
    Then the "Soho venue dropdown link" should be displayed
    And the "Holborn venue dropdown link" should be displayed
    And the "Chelsea venue dropdown link" should be displayed
