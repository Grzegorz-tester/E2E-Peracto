@regression
Feature: Health check

  # Every internal page linked from the header, menu draw and footer should
  # render its own content. Built 2026-09-29 from a live crawl of every
  # internal header/footer link on feature-hib-170.
  #
  # This has to render each page in a browser rather than use the generic
  # "all ... links should resolve without an error" step: confirmed live,
  # HIB serves its "Page Not Found" page with HTTP 200, and a client-side
  # crash ("Application error: a client-side exception...") is also a 200,
  # so a status-code check passes both.
  #
  # Each row checks the page's own heading, taken from the DOM text (not
  # the CSS-uppercased rendering) - category pages have no <h1>, only the
  # category name as an <h2>.
  #
  # /find-a-retailer is not listed: it has no heading even on production
  # (www.hib.co.uk), and find-a-retailer.feature covers it directly.
  #
  # Known red on feature-hib-170 (2026-09-29), both fine on production:
  # - /specifiers-developers: "Application error" client-side crash
  # - /articles/blog ("Our Blog" in the footer): Page Not Found

  Scenario Outline: The "<path>" page loads with its own content
    Given I navigate directly to the path "<path>"
    Then the "application error" should not appear within "5" seconds
    And the "page not found" should not be displayed
    And a heading with the text "<heading>" should be displayed

    Examples: Header and menu draw
      | path                   | heading                                                   |
      | /specifiers-developers | Specifiers & Developers                                   |
      | /samples               | Request Swatch Sample                                     |
      | /brochure              | Brochures                                                 |
      | /products              | BATHROOM PRODUCTS                                         |
      | /inspiration           | Inspiration                                               |
      | /about                 | hib. Corporate Film                                       |
      | /support               | SUPPORT                                                   |
      | /swatch-samples        | Swatches                                                  |
      | /articles/news         | News                                                      |
      | /careers               | Join Our Growing Family Tree: Explore Your Career at hib. |

    Examples: Footer
      | path                             | heading                         |
      | /contact-us                      | Contact Us                      |
      | /guarantee                       | Our Guarantee                   |
      | /customer-feedback-form          | Customer Feedback Form          |
      | /articles/blog                   | Our blog                        |
      | /awards-affiliations             | AWARDS & AFFILIATIONS           |
      | /corporate-social-responsibility | CORPORATE SOCIAL RESPONSIBILITY |
      | /environmental-policy            | ENVIRONMENTAL POLICY            |
      | /modern-slavery-statement        | Modern Slavery Statement        |
      | /privacy-policy                  | PRIVACY NOTICE                  |
      | /sitemap                         | Sitemap                         |

    Examples: Category pages (menu draw and footer)
      | path                                   | heading                       |
      | /bathroom-furniture                    | BATHROOM FURNITURE            |
      | /category/bathroom-mirrors             | BATHROOM MIRRORS              |
      | /category/bathroom-cabinets            | BATHROOM CABINETS             |
      | /category/wall-hung-bathroom-units     | BATHROOM WALL HUNG UNITS      |
      | /category/bathroom-cloakroom-units     | BATHROOM CLOAKROOM UNITS      |
      | /category/bathroom-floor-standing-units | BATHROOM FLOOR STANDING UNITS |
      | /category/bathroom-fitted-furniture    | BATHROOM FITTED FURNITURE     |
      | /category/bathroom-washbasins          | BATHROOM WASHBASINS           |
      | /category/bathroom-brassware           | BATHROOM BRASSWARE            |
      | /category/bathroom-countertops         | BATHROOM COUNTERTOPS          |
      | /category/bathroom-handles             | BATHROOM HANDLES              |
      | /category/bathroom-back-to-wall-units  | BATHROOM BACK TO WALL UNITS   |
      | /category/bathroom-tall-storage-units  | BATHROOM TALL STORAGE UNITS   |
      | /category/bathroom-toilet              | BATHROOM TOILETS              |
      | /category/bathroom-basins              | BATHROOM BASINS               |
      | /category/bathroom-accessories         | BATHROOM ACCESSORIES          |
      | /category/bathroom-ventilation         | BATHROOM VENTILATION          |
      | /category/bathroom-lighting            | BATHROOM LIGHTING             |
