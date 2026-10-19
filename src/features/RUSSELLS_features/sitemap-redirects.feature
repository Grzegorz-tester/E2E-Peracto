@regression
Feature: Sitemap redirects

  # Russells has 8 real sitemap categories (more than Insinkerator's 5 -
  # per-storefront content, not shared). "article_categories" is skipped
  # below - a known, currently-failing category (RUS-474: a ~78,600-item
  # unfiltered list where none of the items ever become visible), flagged
  # as commented-out in the source suite rather than fixed.

  Background:
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present

  @smoke
  Scenario: User can navigate to the sitemap page from the footer
    When I click on the "Sitemap link" link
    Then I should be redirected to the "sitemap" page
    And the "Sitemap heading" should equal text "Sitemap"

  Scenario Outline: Each sitemap category's first item redirects to a real page - "<category>"
    Given I am on the "sitemap" page
    When I click on the "<category> tab" link
    Then the "Sitemap category item" should be displayed
    When I click on the "first Sitemap category item" element and note the response status
    Then the noted response status should be less than 400

    Examples:
      | category        |
      | products        |
      | categories      |
      | content         |
      | articles        |
      | locations       |
      | article_images  |
      | product_images  |
