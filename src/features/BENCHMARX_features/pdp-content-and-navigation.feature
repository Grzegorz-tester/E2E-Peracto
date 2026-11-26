@smoke @regression
Feature: Product detail page

  # Qase BEN-98. Built 2026-10-24 from a live inspection of staging. A
  # Benchmarx "product" is a kitchen range colourway (/kitchens/<slug>): no
  # price or basket, the PDP's job is images, colours and the route into a
  # design consultation. The PDP renders a desktop and a mobile copy of the
  # same content, so its mappings filter on ">> visible=true".

  Scenario: The PDP loads with its title, images and key content sections
    Given I am on the "pdp" page
    Then the "product title" should contain the text "Nordica Blue True Handleless"
    And the "breadcrumb" should be displayed
    And the "main product image" should be displayed
    And the "main product image" image should return a 200 OK response with content-type "image/"
    And the "colour swatches" should contain the text "Available Colours"
    And the "Book a design consultation button" should be displayed
    And the "technical specification link" should be displayed
    And the "at a glance" should be displayed
    And the "related products" should be displayed

  # Confirmed live: picking a thumbnail swaps the main image to that
  # thumbnail's picture (main image alt = the thumbnail's alt). The
  # highlighted border does NOT move with it, so it isn't asserted. Waits for
  # hydration first: a click before React attaches does nothing.
  Scenario: Additional product images can be viewed from the thumbnails
    Given I am on the "pdp" page
    And I wait for the page to settle
    When I remember the "alt" attribute of the "second thumbnail image" as "second image"
    Then the "main product image" should not have attribute "alt" equal to the remembered "second image"
    When I click on the "2nd" "product thumbnails" button
    Then the "main product image" should have attribute "alt" equal to the remembered "second image"
    And the "main product image" image should return a 200 OK response with content-type "image/"

  Scenario: The PDP's design consultation button opens the booking form
    Given I am on the "pdp" page
    And I wait for the page to settle
    When I click on the "Book a design consultation button" button
    Then I should be redirected to the "book-a-consultation" page
    And the "step heading" should contain the text "Find your nearest branch"

  # ---- BEN-379 (Next.js 15 upgrade) additions, 2026-11-11 ----

  # PDP-01: one kitchen, reached the way a shopper does (range listing,
  # first card), so the test doesn't depend on a fixed slug. Every kitchen
  # PDP is the same template (was one per range until 2026-11-22).
  Scenario: A kitchen's PDP loads with full content
    Given I navigate directly to the path "/kitchen-ranges/true-handleless"
    And I wait for the page to settle
    When I remember the text of "first product card name" as "product name"
    And I click on the "first product card" link
    Then I should be redirected to the "pdp" page
    And the "product title" should contain the remembered "product name"
    And the "main product image" should be displayed
    And the "main product image" image should return a 200 OK response with content-type "image/"
    And the "colour swatches" should be displayed
    And the "Book a design consultation button" should be displayed
    And the "at a glance" should be displayed

  # PDP-02: a swatch is a link to that colourway's own PDP; the URL, title
  # and image change with it.
  Scenario: Choosing another colour swatch opens that colourway's PDP
    Given I am on the "pdp" page
    And I wait for the page to settle
    When I remember the "href" attribute of the "first other colour swatch" as "swatch path"
    And I remember the "src" attribute of the "main product image" as "original image"
    And I click on the "first other colour swatch" link
    Then the current URL should contain "/kitchens/nordica-white-true-handleless"
    And the "product title" should contain the text "Nordica White True Handleless"
    And the "main product image" should not have attribute "src" equal to the remembered "original image"
    And all "colour swatch links" links should resolve without an error

  # PDP-05: the technical specification is a PDF that opens in a new tab.
  Scenario: The technical specification link opens a PDF in a new tab
    Given I am on the "pdp" page
    Then the "technical specification link" should have attribute "target" with value "_blank"
    And the "technical specification link" should have attribute "href" containing ".pdf"
    When I remember the "href" attribute of the "technical specification link" as "spec pdf"
    Then requesting the remembered path "spec pdf" should return status 200 with content-type "application/pdf"

  # PDP-07
  Scenario: The PDP's related products open their own PDPs
    Given I am on the "pdp" page
    Then the "related products" should be displayed
    And all "related product card links" links should resolve without an error
    When I remember the text of "first related product card name" as "related"
    And I click on the "first related product card" link
    Then I should be redirected to the "pdp" page
    And the "product title" should contain the remembered "related"

  # PDP-08: an unknown kitchen slug must be a real 404 (status AND page).
  # CONFIRMED 2026-11-11: next-15 serves the branded 404 page with HTTP 200
  # (a "soft 404"); staging returns 404.
  Scenario: An unknown kitchen URL shows the branded 404 page with a 404 status
    Given I navigate directly to the path "/kitchens/does-not-exist"
    Then the "not found page" should be displayed
    And the "page heading" should contain the text "We couldn't find the page you're looking for"
    And requesting the path "/kitchens/does-not-exist" should return status 404
