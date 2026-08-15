@regression
Feature: Sitemap redirects

  # Ported from Insinkerator_EU's sitemap-redirects.feature. This site's
  # real sitemap categories differ from the EU site's - products,
  # categories, content, articles, article images and product images (no
  # "locations" category here).

  @smoke
  Scenario: User can navigate to the sitemap page from the footer
    Given I am on the "home" page
    And I click on the "Accept cookies" button if present
    When I click on the "sitemap link" link
    Then I should be redirected to the "sitemap" page
    And the "sitemap heading" should equal text "Sitemap"

  Scenario Outline: Each sitemap category's first item redirects correctly
    Given I am on the "sitemap" page
    And I click on the "Accept cookies" button if present
    When I click on the "<category tab>" link
    And I click on the "sitemap category item" element and note the response status
    Then the noted response status should <comparison> <status>

    Examples:
      | category tab         | comparison     | status |
      | products tab         | be less than   | 400    |
      | categories tab       | be less than   | 400    |
      | content tab          | be less than   | 400    |
      | articles tab         | be less than   | 400    |
      | article images tab   | be less than   | 400    |
      | product images tab   | equal          | 200    |
