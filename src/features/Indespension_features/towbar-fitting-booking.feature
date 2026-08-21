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
  # CORRECTION to this file's own previous revision: the booking scenario
  # used to navigate directly to "towbar-fixed-flange-pdp" by URL, and
  # "zero enabled Fitting slot candidates across every week" was wrongly
  # attributed to genuine slot exhaustion or a selector problem. Neither
  # was true - confirmed live: direct URL navigation to a towbar PDP shows
  # a "may not be compatible with your vehicle" warning and the fitting
  # date/time widget never properly renders (0 comboboxes, no "Select your
  # preferred date" text) because the widget depends on vehicle context
  # set during the real search flow, which a direct navigation skips
  # entirely. Reached via the real flow (this Background, then selecting
  # a recommended towbar), the exact same "Fitting slot" selector and
  # week-selection step both work correctly - confirmed live, the week
  # trigger's own visible text changes from one real date range to
  # another after selecting an option, and the last week option
  # genuinely has real, mostly-enabled slots (this vehicle/centre
  # combination's first recommended towbar happens to be
  # "towbar-fixed-flange-pdp" itself, confirmed live).
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

  Scenario: Completing the fitting-booking form books a real appointment and reaches the confirmation page
    Given I click on the "1st" "Select towbar button" button
    # CONFIRMED LIVE: without this explicit wait, the very next step's
    # element lookup runs against page.url() before the click's
    # client-side route change has actually landed - getElementLocator
    # itself doesn't poll, unlike "I should be redirected to ... page"
    # (which does, via waitFor) - so it silently resolves "Fitting week
    # dropdown" against the PREVIOUS page (towbar-comparison, which has
    # no such key, nor does common.json), producing a literal
    # locator('undefined') rather than a real failure. This vehicle +
    # centre combination's first recommended towbar is deterministically
    # "towbar-fixed-flange-pdp" (ta1006), confirmed live.
    And I should be redirected to the "towbar-fixed-flange-pdp" page
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
    #
    # CORRECTION - the "zero enabled candidates across every week" finding
    # reported earlier was traced to two real bugs, both now fixed and
    # confirmed live via direct DOM inspection (not guessed at): (1) this
    # scenario used to navigate directly to the PDP by URL, which shows a
    # "may not be compatible with your vehicle" warning and never
    # properly renders the fitting widget at all, because it depends on
    # vehicle context set during the real search flow - fixed by reaching
    # it through the Background's real flow instead (see the "Given I
    # click ... Select towbar button" / "Then I should be redirected"
    # pair above). (2) a race condition: the element lookup immediately
    # after that click ran before the client-side route change had
    # landed, resolving against the PREVIOUS page's mapping instead - the
    # explicit "I should be redirected to ... page" step above (which
    # polls, unlike a bare element lookup) fixes this too. With both
    # fixed, the exact same selector and week-selection step ARE
    # confirmed live to work correctly (the week trigger's own visible
    # text changes to the real selected date range; the last week
    # genuinely had 9 of 10 real slots enabled when checked directly).
    #
    # CORRECTION #2, with stronger evidence than the "genuine exhaustion"
    # theory above: instrumented this live (dumped isEnabled(),
    # aria-disabled, the native disabled attribute, and class list for
    # every candidate, for the actual week cucumber has selected at the
    # moment of the check). Every one of the 10 slot buttons in the last
    # week genuinely has a native disabled="" attribute present, which is
    # exactly what the button's own Tailwind classes
    # (disabled:bg-brand-light-metal-grey etc.) key off - so isEnabled()
    # is reporting the real, correct state; this is NOT an isEnabled()
    # bug, and NOT the week-selection step resetting anything.
    #
    # The real explanation: there is more than one recommended towbar on
    # /towbars/comparison, and each has its OWN independent fitting-slot
    # inventory. This scenario always targets the 1st one
    # (towbar-fixed-flange-pdp / ta1006) via the Background - confirmed
    # live that a 2nd recommended towbar exists too (a different product,
    # "ta1006vk", not yet registered as its own page id), which the user
    # separately reported seeing real availability on. So the "zero
    # enabled slots" failure is specific to ta1006's own calendar right
    # now (plausibly exhausted by this exact scenario's own repeated runs
    # today, since every prior successful run consumed a real slot from
    # THIS SAME towbar), not proof the whole booking system/day is
    # unavailable.
    #
    # NOT FIXED HERE - flagging rather than half-building it: making this
    # resilient the same way week-selection already is (try each
    # recommended towbar in turn, not just the 1st, until one's calendar
    # has an enabled slot) needs each candidate towbar's own PDP
    # registered as a page id first (only ta1006/towbar-fixed-flange-pdp
    # is registered right now) and a step generic enough to navigate
    # back to /towbars/comparison and retry with the next "Select towbar
    # button" candidate - a real but bounded follow-up, not attempted in
    # this pass to avoid guessing at how many towbars are typically
    # recommended or half-committing an untested retry loop.
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
