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

  # 2026-11-22: rows cut. Already loaded and asserted elsewhere: /contact-us (contact-us.feature),
  # /contract-furniture and /pub-furniture (category-plp.feature), /articles/projects
  # (articles.feature). Same CMS/listing template as a kept row: the other header CMS
  # pages (kept /about), venue content pages (kept /hotel-furniture), News From The
  # Workshop, and the footer CMS pages (kept /delivery-and-returns). Every header and
  # footer link is still HTTP-checked by the two link scenarios at the end.

  Scenario Outline: The "<path>" page loads with its own heading
    Given I navigate directly to the path "<path>"
    Then the "page not found" should not be displayed
    And a heading with the text "<heading>" should be displayed

    Examples: Header and menu
      | path                        | heading                                           |
      | /by-venue                   | Choose By Venue                                   |
      | /about                      | EXPERIENCE \| CHOICE \| SUPPORT                   |

    Examples: By venue
      | path                  | heading                      |
      | /hotel-furniture      | Hotel Furniture              |

    Examples: Footer
      | path                       | heading                                |
      | /delivery-and-returns      | Delivery & Returns                     |
      | /sitemap                   | Sitemap                                |

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
