@regression
Feature: Health check

  # Every internal page linked from the header, menu and footer should load
  # with its own content. Built 2026-09-30 from a live crawl of staging.
  #
  # Unlike HIB, a missing page on Andy Thornton returns a real HTTP 404
  # ("We couldn't find the page you're looking for"), so the HTTP link-check
  # scenarios below are meaningful here. The per-page rows also render each
  # page and check its own heading, which catches a page that loads but is
  # empty or wrong.
  #
  # Production rate-limits fast traffic (HTTP 429 after ~10 quick page loads,
  # confirmed 2026-09-30), which a full production run of this feature may
  # trip.

  Scenario Outline: The "<path>" page loads with its own heading
    Given I navigate directly to the path "<path>"
    Then the "page not found" should not be displayed
    And a heading with the text "<heading>" should be displayed

    Examples: Header and menu
      | path                        | heading                                           |
      | /contact-us                 | How can we help?                                  |
      | /contract-furniture         | Contract Furniture                                |
      | /by-venue                   | Choose By Venue                                   |
      | /interior-fittings-antiques | Interior Fittings & Antiques                      |
      | /architectural-metalwork    | ARCHITECTURAL METALWORK                           |
      | /articles/projects          | Projects                                          |
      | /about                      | EXPERIENCE \| CHOICE \| SUPPORT                   |
      | /bespoke-furniture          | BESPOKE FURNITURE                                 |
      | /sales-support              | Let us help you with your next commercial project |
      | /outdoor-furniture          | Outdoor Contract Furniture & More                 |
      | /banquette-seating          | Banquette Seating                                 |
      | /vintage-furniture          | Vintage Furniture                                 |
      | /articles/news-from-the-workshop | News From The Workshop                       |
      | /showroom                   | SPECIFICATION SHOWROOM                            |

    Examples: By venue
      | path                  | heading                      |
      | /pub-furniture        | Pub Furniture                |
      | /hotel-furniture      | Hotel Furniture              |
      | /cafe-furniture       | Café & Coffee Shop Furniture |
      | /bar-furniture        | Bar Furniture                |
      | /restaurant-furniture | Restaurant Furniture         |

    Examples: Footer
      | path                       | heading                                |
      | /table-top-stains          | STAINS FOR TABLE TOPS                  |
      | /choose-your-fabric        | CHOOSE YOUR FABRIC                     |
      | /standard-furniture-stains | STANDARD FURNITURE STAINS              |
      | /furniture-care            | CARE & MAINTENANCE OF FURNITURE        |
      | /stainless-steel-care      | CARE & MAINTENANCE OF STAINLESS STEEL  |
      | /delivery-and-returns      | Delivery & Returns                     |
      | /environmental-policy      | Environmental Policy                   |
      | /sitemap                   | Sitemap                                |
      | /our-clients               | OUR CLIENTS                            |
      | /privacy-policy            | Andy Thornton Ltd - Privacy Policy     |
      | /terms-conditions          | Andy Thornton Ltd - Terms & Conditions |

    # /services redirects to the home page on both environments (confirmed
    # live 2026-09-30), and the two home pages have different headings.
    @not-on-production
    Examples: Footer, staging home page
      | path      | heading       |
      | /services | Andy Thornton |

    @production-only
    Examples: Footer, production home page
      | path      | heading                       |
      | /services | Find Furniture for your Venue |


  # These three have real content but no heading element (confirmed live), so
  # their own text is checked instead.
  Scenario Outline: The "<path>" page loads with its own content
    Given I navigate directly to the path "<path>"
    Then the "page not found" should not be displayed
    And the "page body" should contain the text "<text>"

    Examples:
      | path                             | text                               |
      | /downloads                       | Workshop Journal                   |
      | /seating-guide:-table-tops-pdf   | Seating Guide For Table Tops (PDF) |

    # Staging-only content: linked from the staging home page, but production
    # neither links to it nor has it (real HTTP 404, confirmed 2026-09-30).
    @not-on-production
    Examples: Staging only
      | path                             | text                                |
      | /best-hospitality-furniture-2024 | Customised Georgian Refectory Table |


  Scenario: Every internal header link resolves without an error
    Given I am on the "home" page
    And I click on the "Allow all cookies" button if present
    Then all "header internal links" links should resolve without an error


  Scenario: Every internal footer link resolves without an error
    Given I am on the "home" page
    And I click on the "Allow all cookies" button if present
    Then all "footer internal links" links should resolve without an error
