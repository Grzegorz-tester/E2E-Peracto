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
  # full page source AND the "towbar-search-tabs" container's DOM (no
  # second tab, no hidden reg-plate input), so manual cases 107 ("VRM
  # search") and 109 ("invalid VRM error") have no live equivalent to
  # automate; they describe a feature that doesn't exist here, not a
  # testing gap.
  #
  # CORRECTION to this file's own previous revision: that version claimed
  # the Year dropdown "never populates" and treated it as a likely live
  # bug. That was wrong - it was a step-definition gap, not a site bug.
  # These four fields are a Radix-style combobox (button[role=combobox]
  # opening a role=listbox popup), and this framework's only pre-existing
  # dropdown-select step (`I select the "X" option from the "Y" dropdown`)
  # calls page.selectOption, which only works on a native <select> - it
  # cannot interact with this combobox shape at all. A new generic step,
  # `I select the "X" option from the "Y" listbox` (form.ts), was added to
  # cover this. With that, Year populates correctly and quickly for every
  # real vehicle make tried live (2026-08-21): FORD, VOLKSWAGEN, BMW,
  # TOYOTA, NISSAN, PEUGEOT all cascade Make -> Model -> Year -> Body Type
  # with real options at every step (confirmed via the underlying
  # GET /car-make-model-search API calls, all 200). "AKFS" and "AL-KO" -
  # the two makes the previous revision tried - sit alphabetically first
  # in the Make list but are towbar/trailer-component brands, not vehicle
  # manufacturers; they genuinely have no Model/Year data because they
  # aren't cars, which is correct behaviour, not a bug.
  #
  # STILL NOT RESOLVED - flagging for a human rather than guessing further:
  # even with a real vehicle cascaded all the way to Body Type, the
  # "Search towbars" button's enabled state was inconsistent across
  # otherwise-identical attempts (enabled once, staying disabled on
  # others), and the one time it was clicked while enabled, it produced NO
  # visible change at all - same page, same filled form, no results list,
  # no navigation, no error. The page's OWN marketing copy on this exact
  # page describes a completely different 5-step journey ("Enter your
  # vehicle registration" -> "Towbar quotes" -> "Select the electrical
  # requirement" -> "Your details" -> "Book towbar fitting") that has no
  # discoverable live entry point anywhere on this page, this page's own
  # links (checked: only self-link and "Towbar Accessories", a plain
  # product category, not a booking flow), or the "towbar-search-tabs"
  # container. Whether that 5-step journey exists elsewhere on the site,
  # was never built, or is broken, needs a developer to confirm directly -
  # this suite cannot get there through anything discoverable from here.
  # The "Towbar Fitting - booking form" and "Towbar & Wiring Kit Finder"
  # suites' remaining 13 cases stay uncovered for this reason.

  Background:
    Given I am on the "towbars" page

  Scenario: Vehicle search filter fields are present, cascading correctly
    Then the "Make dropdown" should be displayed
    And the "Model dropdown" should not be enabled
    And the "Year dropdown" should not be enabled
    And the "Body type dropdown" should not be enabled
    And the "Search towbars button" should be displayed

  # Proves the cascade genuinely works end-to-end for a real vehicle -
  # each subsequent step only succeeds if the previous field's selection
  # actually populated the next one with real, selectable options: a
  # fabricated/empty Year or Body Type listbox would time out here rather
  # than silently pass.
  Scenario: Selecting a real vehicle cascades through Model, Year and Body Type with real options
    When I select the "FORD" option from the "Make dropdown" listbox
    And the "Model dropdown" should be enabled
    And I select the "1st" option from the "Model dropdown" listbox
    And the "Year dropdown" should be enabled
    And I select the "1st" option from the "Year dropdown" listbox
    And the "Body type dropdown" should be enabled
    And I select the "1st" option from the "Body type dropdown" listbox
