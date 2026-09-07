@regression
Feature: Admin Tasks Can All Be Triggered

  # Bespoke to Andy Thornton, not the shared Carbon_admin boilerplate suite
  # - same reasoning as MIPA's own tasks.feature: triggering a task runs a
  # real backend job, a write/mutating action rather than a read-only nav
  # check, so per CLAUDE.md's "Staging vs production rules" this is only
  # safe on a staging admin. Andy Thornton has no production admin env in
  # this repo, so this bespoke path is safe by construction.
  #
  # CONFIRMED (live, ANDY_THORNTON_ADMIN staging, 2026-08-31): 16 tasks
  # exist (Product indexer, Back in stock, several sitemap jobs, Cleanup
  # old Import data, Google Product Feed, Update products from Sage,
  # Update discontinued skus, Pinterest Product Feed, Hello world) - most
  # show "Inactive" status, only 2 show "Active", but every row's play
  # button raises the same "The {slug} task will begin shortly." success
  # toast regardless of status. The "I click on the ... for every ... row
  # ..." step (admin-tasks.ts) checks each row against its own slug, so a
  # task added or removed later doesn't require this file to be updated.

  Scenario: Every task's play button successfully triggers its own run
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    When I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time
