@regression
Feature: Towbar fitting booking

  # Covers the manual test plan's remaining "Towbar Fitting - booking form"
  # and "Towbar & Wiring Kit Finder" cases, picking up where
  # towbar-vehicle-search.feature intentionally stopped (that file is
  # scoped to the search filter fields only). The exact real flow below
  # was provided directly after live verification, not guessed at - a
  # previous pass got stuck on "Search towbars" appearing to do nothing
  # because it never looked for the confirmation modal it actually opens.
  #
  # CONFIRMED LIVE (2026-08-21): submitting the vehicle search opens an
  # "Is this your vehicle?" modal, not an inline results list. Confirming
  # it lands on /towbars/comparison, which shows the resolved fitting
  # Centre (derived from the postcode entered - there is no separate
  # centre-picker dropdown/listbox, "Change Centre" just re-opens the same
  # postcode field) alongside recommended towbars for that vehicle.
  # Selecting one goes to that towbar's own PDP, which carries a date/time
  # fitting-booking widget (product-fitting-datepicker) entirely separate
  # from the storefront's ordinary basket/checkout flow - this booking is
  # submitted through its own dedicated widget and popups, never touching
  # the basket.
  #
  # CONFIRMED LIVE: the PDP's two tabs (one per towbar variant) both render
  # their own copy of this whole widget simultaneously in the DOM rather
  # than unmounting the inactive one - every mapping selector below that
  # could otherwise match both needs ":visible" to resolve to the active
  # tab's copy only (confirmed live: without it, several steps throw a
  # Playwright strict-mode violation instead of a real failure).
  #
  # CONFIRMED LIVE: the nearest/current week's slots can be entirely
  # disabled (every time greyed out) while a later week's are genuinely
  # bookable - consistent with the manual test plan's "post-Wednesday
  # midnight" cutoff case, though the exact cutoff rule itself wasn't
  # independently reverse-engineered here, just its visible effect.
  # Selecting the LAST available week deliberately avoids landing on a
  # cutoff-blocked one, using the "last" option added to the shared
  # "... listbox" step (form.ts) for exactly this reason - hardcoding a
  # numeric position instead would silently start picking the wrong week
  # as the number of weeks offered shifts over time.
  #
  # NOT COVERED: no wiring-kit selection step exists anywhere in this flow
  # - confirmed live, "Fitting included" is the only related messaging on
  # both the comparison table and the PDP, and the page's own FAQ copy says
  # wiring kits are supplied and fitted "on the day" rather than chosen
  # during booking. The manual plan's wiring-kit case has no live
  # equivalent to automate here. A confirmation EMAIL is also not checked -
  # no test-inbox pattern exists elsewhere in this repo to build one on,
  # and inventing that infrastructure is out of scope for this pass; the
  # on-page "Booking Confirmation" popup and the final redirect to
  # /towbar-booking-complete are covered instead, as the observable proof
  # the booking succeeded.
  #
  # WARNING: the last scenario below completes a REAL booking on staging
  # every time it runs (fine per CLAUDE.md - Indespension is not HIB - but
  # don't re-run this needlessly).

  Background:
    Given I am on the "towbars" page
    When I select the "AUDI" option from the "Make dropdown" listbox
    And I select the "A4" option from the "Model dropdown" listbox
    And I select the "2003" option from the "Year dropdown" listbox
    And I select the "Avant Estate" option from the "Body type dropdown" listbox
    And I fill in the "Postcode input" input field with "LS10 1TD"
    And I click on the "Search towbars button" button
    And I click on the "Yes, this is my vehicle" button
    Then I should be redirected to the "towbar-comparison" page

  Scenario: Vehicle search resolves a fitting centre and recommended towbars
    Then the "Centre" should be displayed
    And the "Select towbar button" should be displayed

  Scenario: Selecting a recommended towbar leads to its own PDP with a fitting date/time picker
    When I click on the "1st" "Select towbar button" button
    Then the current URL should contain "/products/"
    And the "Fitting week dropdown" should be displayed

  # Navigates directly to the known towbar's own PDP (the Background above
  # already reaches /towbars/comparison but doesn't click "Select" -
  # that's exercised on its own in the scenario above) so this scenario's
  # coverage of the booking widget itself doesn't depend on that click
  # path also working.
  Scenario: Completing the fitting-booking form books a real appointment and reaches the confirmation page
    Given I am on the "towbar-fixed-flange-pdp" page
    # CONFIRMED LIVE: neither a hardcoded specific day/time slot (first
    # tried: Wednesday 09:00) nor always picking "the last" week held up
    # under repeat runs - not flakiness, this step completes a REAL
    # booking, and repeated runs (including this scenario's own past
    # runs) exhaust whichever exact slot or week they target, exactly like
    # real customers booking would. "Fitting slot" in the mapping resolves
    # to every slot button in the currently selected week, not one
    # specific testid, and this step tries weeks from the end of the list
    # backwards until it finds one where at least one slot is still
    # enabled - so the scenario keeps working run after run regardless of
    # what earlier runs have already consumed.
    When I select an option from the "Fitting week dropdown" listbox with an enabled "Fitting slot" candidate
    And I click on the first enabled "Fitting slot" button
    # CONFIRMED LIVE: the plain "I click on the ... button" step's
    # force:true can fire before this button's own re-render (from
    # disabled to enabled, triggered by the slot click above) has actually
    # settled, silently no-opping the click with no error. "I click
    # precisely" (non-forced) keeps Playwright's own actionability wait
    # intact, including the enabled check, which is what's needed here.
    And I click precisely on the "Continue to Booking" button
    And I fill in the "Full Name" input field with "Velstar Test"
    And I fill in the "Booking email" input field with a unique guest email
    And I fill in the "Booking phone" input field with "07377777777"
    And I fill in the "Booking note" input field with "Velstar Test - automated QA, please ignore."
    And I check the "Booking terms checkbox"
    And I click on the "Confirm Your Booking" button
    Then the "Confirm Your Booking" should not be displayed
    When I click on the "Finish" button
    Then I should be redirected to the "towbar-booking-complete" page
