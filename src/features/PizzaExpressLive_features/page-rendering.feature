@PizzaExpressLive_regression
Feature: Page rendering
  Production site (www.pizzaexpresslive.com) - read-only browsing checks that
  the site's main templates render real content. No orders are placed here.

  Scenario: Homepage renders correctly
    Given I am on the "home" page
    Then the "header" should be displayed
    And the "desktop navigation" should be displayed
    And the "Find an Event widget" should be displayed
    And the "homepage events carousel" should be displayed
    And the "footer" should be displayed

  # Clicking "next" doesn't change the carousel's own text (confirmed live:
  # every slide's markup is already in the DOM, "next" just slides the
  # track), so the real, meaningful signal that it moved is the "prev"
  # arrow's enabled state flipping - it's genuinely disabled at the start
  # (nothing to go back to) and genuinely enabled once you've moved.
  Scenario: Coming Soon carousel on the homepage
    Given I am on the "home" page
    Then the "Coming Soon heading" should be displayed
    And the "Coming Soon event card link" should be displayed
    And the "Coming Soon carousel prev button" should not be enabled
    When I click on the "Coming Soon carousel next button" element
    Then the "Coming Soon carousel prev button" should be enabled
    When I click on the "View all events button" element
    Then I should be redirected to the "whats-on" page

  Scenario: What's On page loads events
    Given I am on the "whats-on" page
    Then the "filter bar" should be displayed
    And the "event card link" should be displayed

  # The 4 venues actually featured on this page (confirmed live 2026-08-20)
  # are Soho, Holborn, Chelsea and Piano Lounge (Leicester Square) - not
  # Covent Garden, despite a /piano-lounge-covent-garden page existing
  # elsewhere on the site.
  Scenario: Venues page lists all venues and a venue page renders
    Given I am on the "venues" page
    Then the "content page" should contain the text "Soho"
    And the "content page" should contain the text "Holborn"
    And the "content page" should contain the text "Chelsea"
    And the "content page" should contain the text "Piano Lounge"
    When I click on the "Soho venue dropdown link" element
    Then I should be redirected to the "venue-soho" page
    And the "content page" should be displayed

  Scenario Outline: Static CMS pages load with content
    Given I am on the "<page>" page
    Then the "content page" should be displayed
    Examples:
      | page       |
      | about-us   |
      | membership |
      | faqs       |

  # Not every event card leads to a page with a Book Tickets table - an
  # event that's already sold out/past its cutoff for every date (confirmed
  # live 2026-08-20, e.g. an event whose only date is later that same day)
  # renders with no #event-dates section at all, not an empty one. "1st
  # event card" alone is therefore too unreliable for this check.
  Scenario: PDP renders event details
    Given I am on the "whats-on" page
    When I open the first "event card link" element whose "Book Tickets heading" is present on the destination page
    Then I should be redirected to the "pdp" page
    And the "event title" should be displayed
    And the "Book Tickets table" should be displayed
