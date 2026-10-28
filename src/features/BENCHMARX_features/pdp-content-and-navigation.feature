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
