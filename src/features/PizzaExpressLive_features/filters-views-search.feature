@PizzaExpressLive_regression
Feature: What's On filters, views and search

  # Confirmed live 2026-08-20: the listbox's own first option is the "All
  # Venues" placeholder itself, so clicking a plain "1st" option (as this
  # scenario originally did) re-selects "show everything" and never
  # actually filters anything - "some event card exists" would have passed
  # either way, filtered or not. Selecting "Soho" specifically and checking
  # the OTHER venue names are gone (not just "some card exists") is what
  # actually proves narrowing - confirmed live via the results container's
  # real textContent, not just an element count (the underlying listing
  # keeps a constant ~120-node DOM regardless of filter, so a raw count
  # comparison can't detect this).
  #
  # Runs across all 3 views (not just the default Grid) since filtering is
  # applied by the SAME comboboxes regardless of which view is active, but
  # each view renders results into a genuinely different container -
  # confirmed live the filter narrows correctly in each, but Grid/List
  # share "results wrapper" while Calendar has no such element at all (see
  # the View toggles scenario below), so asserting against the wrong one
  # for Calendar would silently check nothing.
  Scenario Outline: Venue filter narrows results in every view
    Given I am on the "whats-on" page
    When I click on the "<view button>" element
    And I click on the "All Venues combobox" element
    Then the "combobox option" should be displayed
    When I click on the "Soho venue combobox option" element
    Then the "<results key>" should contain the text "Soho"
    And the "<results key>" should not contain the text "Holborn"
    And the "<results key>" should not contain the text "Chelsea"
    And the "<results key>" should not contain the text "Leicester Square"
    Examples:
      | view button          | results key     |
      | Grid view button     | results wrapper |
      | List view button     | results wrapper |
      | Calendar view button | calendar view   |

  # "2nd" (not "1st", for the same reason as the venue scenario above) -
  # skips the "All Months" placeholder. Doesn't assert against a specific
  # hardcoded month (that would go stale as the calendar moves on); instead
  # proves the results genuinely changed by comparing the full listing text
  # before and after, which is real given the site's own behaviour
  # (confirmed live: picking a month also broadens the range to that whole
  # month, e.g. including days earlier in it than today - not just a
  # tighter version of the default "upcoming from today" view). Same
  # per-view results-container split as the venue outline above.
  Scenario Outline: Month filter narrows results in every view
    Given I am on the "whats-on" page
    When I click on the "<view button>" element
    And I remember the text of "<results key>" as "results before month filter"
    And I click on the "All Months combobox" element
    Then the "combobox option" should be displayed
    When I click on the "2nd" "combobox option" element
    Then the "<results key>" text should not equal the remembered "results before month filter"
    Examples:
      | view button          | results key     |
      | Grid view button     | results wrapper |
      | List view button     | results wrapper |
      | Calendar view button | calendar view   |

  # Grid and List share the same results container (confirmed live), so
  # both are checked the same way. Calendar is a genuinely different
  # component with its own testid, not just a re-skinned card list
  # (confirmed live: switching to it, "results wrapper" disappears
  # entirely and a real day-of-week calendar grid renders instead) - an
  # outline sharing one "results key" column across all three would have
  # silently passed Calendar against the wrong element.
  Scenario Outline: View toggles render event data
    Given I am on the "whats-on" page
    When I click on the "<view button>" element
    Then the "<results key>" should be displayed
    Examples:
      | view button          | results key     |
      | Grid view button     | results wrapper |
      | List view button     | results wrapper |
      | Calendar view button | calendar view   |

  # Confirmed live: the same undismissable "outdated browser" banner
  # documented in navigation-basket-auth-mobile.feature (fixed top, no
  # close button) also covers the desktop header, and intercepted this
  # exact click intermittently - a one-shot "removing ... if it
  # interferes" wasn't reliable either (the banner keeps reappearing), so
  # this strips it permanently up front instead.
  Scenario: Search returns results page
    Given I am on the "home" page
    And I permanently remove the "outdated browser banner" overlay for this scenario
    When I click on the "header search icon" icon
    And I fill in the "search bar input" input field with "jazz"
    And I press Enter in the "search bar input" input field
    Then the current URL should contain "/search?query="
    And the "search results wrapper" should be displayed
