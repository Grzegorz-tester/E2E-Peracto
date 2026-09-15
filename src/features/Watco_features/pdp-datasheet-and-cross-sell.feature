@regression
Feature: Product page - data sheet downloads and cross-sell

  # UK-only, not shared: unlike PDP title/breadcrumb/price/Add to basket
  # (genuinely present on every product across every market, see
  # pdp.feature), which tabs/content-blocks a PDP has is per-product CMS
  # content that varies significantly - CONFIRMED LIVE (staging-uk,
  # 2026-09-09) that the "epoxy" search result used elsewhere in this
  # suite (Watco Epoxy Gloss Coat) has neither a "Data sheets" tab nor a
  # "Tools and accessories" cross-sell block, while "Watco Epoxy Matt
  # Coat" (reached directly, not via search) has both. Pinning this
  # feature to that one specific, known-good SKU trades cross-market
  # portability for actually exercising these two real, previously
  # untested product-page features at all; extending it to other markets
  # would need each one's own equivalent SKU confirmed first.

  Background:
    Given I navigate directly to the path "/products/watco-epoxy-matt-coat"
    And I click on the "Accept cookies" button if present

  Scenario: A product's Safety/Technical Data Sheet can be downloaded from its Data sheets tab
    When I click on the "Data sheets tab" element
    Then the "first data sheet download link" should be displayed
    When I click on the "first data sheet download link" button, remembering the downloaded file as "data sheet"
    Then the remembered "data sheet" download should not be empty

  Scenario: The cross-sell "Tools and accessories" section lists related products
    Then the "cross-sell section" should be displayed
    And the "cross-sell product card" should be displayed
