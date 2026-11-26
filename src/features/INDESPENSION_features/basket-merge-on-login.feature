@regression @serial
Feature: Guest basket on login

  # IND-729 (Peracto API upgrade) case 317: what happens to a guest basket
  # when the visitor logs in to an account that already has a basket.
  #
  # BASELINE, CONFIRMED 2026-11-13 (staging, pre-upgrade): the baskets do NOT
  # merge. The guest basket REPLACES the account's saved basket - the item
  # already saved on the account is dropped. This scenario pins that current
  # rule so the upgrade can't change it silently. Whether it is the INTENDED
  # rule has not been confirmed with dev yet; if they want merging, this
  # scenario is expected to go red until it is built.
  #
  # The "new visitor" step clears cookies/storage to stand in for a second
  # device: signing out is not a clean break here (the guest session kept the
  # account's basket after Sign Out, 2026-11-13).
  #
  # @serial: it rewrites the shared logged-in account's basket, and empties it
  # again at the end.

  Scenario: Logging in with a guest basket replaces the account's saved basket
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I wait for the page to settle
    And I clear the basket
    And I am on the "blueline-trailer-pdp" page
    And I wait for the page to settle
    And I click on the "Add to basket" button, retrying until the "added to basket confirmation" appears

    When I clear the browser's cookies and storage, as a new visitor
    And I am on the "marineTrailerPdp" page
    And I wait for the page to settle
    And I click on the "Add to basket" button, retrying until the "added to basket confirmation" appears
    And I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I wait for the page to settle

    Then the "Marine trailer basket line" should be displayed
    And the "Blueline trailer basket line" should not be displayed
    # Clean-up: one line left, removed directly ("I clear the basket" loops
    # and outran the 20s step timeout here on staging, 2026-11-13).
    When I click on the "remove basket line" button
    Then the "no items message" should be displayed
