@PizzaExpressLive_regression
Feature: API response verification

  Scenario: API base URL referenced correctly
    Given I am on the "whats-on" page
    When I open the first "event card link" element whose "Book Tickets heading" is present on the destination page
    Then I should be redirected to the "pdp" page
    And I read window.__NEXT_DATA__
    Then the page data should reference "api.pizzaexpresslive.com"

  Scenario: Product attributes present in page data
    Given I am on the "whats-on" page
    When I open the first "event card link" element whose "Book Tickets heading" is present on the destination page
    Then I should be redirected to the "pdp" page
    And I read window.__NEXT_DATA__
    Then the page data at "props.pageProps.event.slug" should be present
    And the page data at "props.pageProps.event.sku" should be present
    And the page data at "props.pageProps.event.prices" should be present
    And the page data at "props.pageProps.event.attributes" should be present
    And every entry in the page data at "props.pageProps.event.attributes" should have a "value" field

  Scenario: Event image asset returns 200 OK
    Given I am on the "whats-on" page
    Then the "event card image" should be displayed
    And the "event card image" image should return a 200 OK response with content-type "image"

  # "Failed to load resource" is ignored wholesale rather than by URL:
  # confirmed live, Chromium's own console message for a failed sub-resource
  # (Spektrix's bookings.pizzaexpresslive.com widget script 403ing on every
  # page, harmless and outside this site's control) never includes the
  # failing URL in msg.text() at all, so it can't be filtered any more
  # narrowly than this - same trade-off footer.ts's link-checker already
  # makes by excluding facebook.com wholesale rather than per-URL. The
  # image-asset check (case 192, above) already separately covers "is a
  # resource actually broken", so this scenario is scoped to JS errors.
  Scenario: No unexpected console errors across key pages
    Given I am on the "home" page
    When I start monitoring console errors, ignoring messages matching "mailerlite|googletagmanager|spotify|bookings\.pizzaexpresslive\.com|Didomi|X-Frame-Options|Failed to load resource"
    And I am on the "whats-on" page
    And I click on the "1st" "event card link" element
    Then I should be redirected to the "pdp" page
    When I am on the "venue-soho" page
    And I am on the "about-us" page
    And I am on the "membership" page
    And I am on the "faqs" page
    And I am on the "basket" page
    And I am on the "account" page
    Then there should be no unexpected console errors
