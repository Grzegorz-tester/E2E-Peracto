@regression
Feature: Sitemap redirects

  # Covers the "Sitemaps" case in the manual test plan's Footer suite. The
  # sitemap link only appears on the "stripped-footer" variant shown on CMS
  # content pages (contact, about) - not the main storefront footer, so
  # this starts from "contact" rather than "home". Categories differ from
  # Insinkerator's: products, categories, content, articles,
  # article_categories, locations, article_images, product_images (this
  # project DOES have a locations category, unlike Insinkerator_EU).

  @smoke
  Scenario: User can navigate to the sitemap page from a content page's footer
    Given I am on the "contact" page
    When I click on the "sitemap link" link
    Then I should be redirected to the "sitemap" page
    And the "sitemap heading" should be displayed

  # "sitemap category item" (sitemap.json) deliberately isn't a plain
  # "a.block" class selector - that resolves to thousands of elements on
  # real category pages (e.g. every product on /sitemap/products), which
  # violates this framework's own convention that a mapping's selector
  # must resolve to exactly one element (link-navigation.ts's "note the
  # response status" step has no .first() - by design, per this repo's
  # steps-are-generic/mappings-do-the-picking split). Confirmed live
  # (2026-08-21) there's no unique container/testid around each category's
  # item grid to scope into instead, so this uses an XPath positional
  # index anchored on the page's own unique "Sitemap" h1 instead -
  # confirmed to resolve to exactly one element, the correct first real
  # item, on every category checked below.
  #
  # Each category tab is also its own sub-route (/sitemap/{category}), not
  # a client-side tab switch - "sitemap" page's own regex in pages.json
  # covers this whole route family (^/sitemap(/.*)?$) rather than only the
  # bare /sitemap page, otherwise none of these sub-route elements would
  # resolve at all (confirmed live: an unmatched route fails outright with
  # "Failed to find page name from current route", not a silent fallback).
  Scenario Outline: Each sitemap category's first item redirects correctly
    Given I am on the "sitemap" page
    When I click on the "<category tab>" link
    And I click on the "sitemap category item" element and note the response status
    Then the noted response status should be less than 400

    Examples:
      | category tab   |
      | products tab    |
      | categories tab  |
      | content tab     |
      | articles tab    |
      | locations tab   |
