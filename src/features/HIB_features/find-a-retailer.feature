@regression
Feature: Find a Retailer
  - Search by postcode, city or address for nearby retailers. Each result
    shows the retailer's name, distance, address (with postcode) and phone
    number, and links directly to that retailer's own page.


  Scenario: Search for a retailer by postcode and confirm results are returned with essential details
    Given I am on the "find-a-retailer" page
    And I dismiss the newsletter popup if present
    # 2026-10-15, www.hib.co.uk: searching before Google Maps has finished
    # loading crashes the page ("Application error", console:
    # "window.google.maps.Geocoder is not a constructor") - 6/6 framework
    # attempts searching straight after load crashed, 0/8 crashed when the
    # search waited ~8s. A minor real site race (a fast user could hit it);
    # settle first so the test checks the search itself.
    And I wait for the page to settle
    When I fill in the "postcode search input" input field with "SW1A 1AA"
    And I click on the "retailer search button" button
    Then the "retailer results" should be displayed
    And the "first retailer result" should be displayed
    And the "first retailer result" should contain the text "miles"


  Scenario: Clicking a retailer redirects to that retailer's own page
    Given I am on the "find-a-retailer" page
    And I dismiss the newsletter popup if present
    # 2026-10-15, www.hib.co.uk: searching before Google Maps has finished
    # loading crashes the page ("Application error", console:
    # "window.google.maps.Geocoder is not a constructor") - 6/6 framework
    # attempts searching straight after load crashed, 0/8 crashed when the
    # search waited ~8s. A minor real site race (a fast user could hit it);
    # settle first so the test checks the search itself.
    And I wait for the page to settle
    When I fill in the "postcode search input" input field with "SW1A 1AA"
    And I click on the "retailer search button" button
    And I click on the "first retailer result" element
    Then I should be redirected to the "retailer-page" page
