@PizzaExpressLive_regression
Feature: Spektrix booking integration
  Ticketing (seat selection, login, checkout and payment) is entirely inside
  a third-party Spektrix iframe (bookings.pizzaexpresslive.com), not this
  site's own markup. Confirmed live (2026-08-20): driving that iframe
  headlessly gets blocked by Spektrix's own Cloudflare bot-protection, and
  this is a production site where a real purchase must never be attempted
  regardless. Every scenario below therefore stops at confirming the right
  iframe loads with the right src - it does not select seats, log in, or
  reach payment. Revisit this file if a non-headless or session-based
  strategy for the Spektrix side is worked out later.

  Scenario: Booking a ticket opens the Spektrix choose-seats iframe
    Given I am on the "whats-on" page
    When I open the first "event card link" element whose "Book Now button" is present on the destination page
    Then I should be redirected to the "pdp" page
    And the "booking iframe" should not be displayed
    When I click on the "1st" "Book Now button" element
    Then I should be redirected to the "choose-seats" page
    And the current URL should contain "/whats-on/choose-seats/"
    And the "booking iframe" should be displayed
    And the "booking iframe" should have attribute "src" containing "bookings.pizzaexpresslive.com/pizzaexpress/website/chooseseats.aspx"

  Scenario: Spektrix event data is present in the PDP's own page data
    Given I am on the "whats-on" page
    When I open the first "event card link" element whose "Book Tickets heading" is present on the destination page
    Then I should be redirected to the "pdp" page
    And I read window.__NEXT_DATA__
    Then the page data at "props.pageProps.event.slug" should be present
    And the page data at "props.pageProps.event.sku" should be present
    And the page data at "props.pageProps.event.availability" should be present

  # Superseded an earlier best-effort version of this scenario written
  # when no live event happened to show a "Join waiting list" CTA (every
  # sold-out event checked on 2026-08-20 had zero date rows) - confirmed
  # live on 2026-08-21 that one now does (motown-memoirs), so this uses
  # the real modal markup rather than an inferred, unverified guess.
  # Deliberately stops at "Submit Enquiry becomes enabled" rather than
  # actually submitting - this sends a real enquiry to the venue's box
  # office, a genuine side effect on a live production business system,
  # not something a read-only regression check should trigger regardless
  # of how clearly the test data is marked.
  Scenario: Waiting list form enables Submit Enquiry once filled in
    Given I am on the "whats-on" page
    When I open the first "event card link" element whose "Join waiting list button" is present on the destination page
    Then I should be redirected to the "pdp" page
    When I click on the "Join waiting list button" element
    Then the "Waiting List Form modal" should be displayed
    And the "Submit Enquiry button" should not be enabled
    When I fill in the "modal contact name input" input field with "Velstar Test"
    And I fill in the "modal email input" input field with "velstar.test@velstar.co.uk"
    And I fill in the "modal phone input" input field with "07700900000"
    And I select the "1" option from the "modal number of tickets dropdown" dropdown
    Then the "Submit Enquiry button" should be enabled

  # Same real-modal upgrade as the waiting list scenario above, confirmed
  # live 2026-08-21 against poppy-baker's Box Office Form. Also
  # deliberately stops short of the real Submit click for the same reason.
  Scenario: Contact box office form enables Submit Enquiry once filled in
    Given I am on the "whats-on" page
    When I open the first "event card link" element whose "Contact box office button" is present on the destination page
    Then I should be redirected to the "pdp" page
    When I click on the "Contact box office button" element
    Then the "Box Office Form modal" should be displayed
    And the "Submit Enquiry button" should not be enabled
    When I fill in the "modal contact name input" input field with "Velstar Test"
    And I fill in the "modal email input" input field with "velstar.test@velstar.co.uk"
    And I fill in the "modal phone input" input field with "07700900000"
    And I select the "1" option from the "modal number of tickets dropdown" dropdown
    Then the "Submit Enquiry button" should be enabled
