@regression
Feature: Towbar vehicle search

  # Covers the confirmed-live-real part of what the manual test plan
  # spreads across three suites (Products > Towbars > Vehicle Search,
  # Towbar Fitting - booking form, and Towbar & Wiring Kit Finder).
  #
  # RESOLUTION (confirmed live, 2026-08-21): /towbars has exactly ONE
  # search tool - a cascading Make -> Model -> Year -> Body type filter
  # ("search-by-model" / "towbar-search-tabs" despite that second testid's
  # name, there is only one tab). There is NO vehicle registration/VRM
  # search anywhere on this page or site - confirmed by inspecting the
  # full page source, so manual cases 107 ("VRM search") and 109 ("invalid
  # VRM error") have no live equivalent to automate; they describe a
  # feature that doesn't exist here, not a testing gap.
  #
  # NOT RESOLVED - flagging for a human rather than guessing: no booking
  # calendar, date/time slot picker, or wiring-kit selection step was
  # found anywhere reachable from this page (the "Towbar Fitting - booking
  # form" and "Towbar & Wiring Kit Finder" suites' remaining 13 cases).
  # Two real makes were tried end-to-end (a trailer-component brand
  # "AKFS"/"AL-KO" and "FORD") - for both, the Year dropdown never
  # populated any options after selecting Make + Model, so the "Search
  # towbars" submit button never became enabled and no results/booking
  # step was ever reached. This may be a genuine live bug in the
  # cascading dropdown (Year not loading for some/all makes) rather than
  # a booking flow that's simply located elsewhere - worth a developer
  # checking directly rather than continuing to guess at combinations.
  # Whatever the booking/wiring-kit flow's real entry point turns out to
  # be, add its coverage as its own feature file rather than extending
  # this one, which is scoped to the search filter only.

  Background:
    Given I am on the "towbars" page

  Scenario: Vehicle search filter fields are present, cascading correctly
    Then the "Make dropdown" should be displayed
    And the "Model dropdown" should not be enabled
    And the "Year dropdown" should not be enabled
    And the "Body type dropdown" should not be enabled
    And the "Search towbars button" should be displayed
