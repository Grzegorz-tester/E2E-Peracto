@regression
Feature: Admin Tasks Can All Be Triggered

  # Bespoke to Carbon, not the shared Carbon_admin boilerplate suite - same
  # reasoning as MIPA_ADMIN_features/tasks.feature: triggering a task
  # actually runs a real backend job (reindexing, sitemap regeneration,
  # cleanup, feed exports...), a write/mutating action rather than a
  # read-only nav check, so per CLAUDE.md's "Staging vs production rules"
  # this is only safe on a staging admin. Carbon has no production admin
  # env in this repo today.
  #
  # CONFIRMED (live, Carbon Admin staging, 2026-08-31): every one of
  # Carbon's 15 current tasks (Product indexer, Back in stock, Products/
  # Product Images/Locations/Articles/Article Images/Content/Category/
  # Article Category Sitemap, Cleanup old Import data, Cleanup old data,
  # Google Product Feed, Pinterest Product Feed, Hello World) renders its
  # own play button and, on click, raises its own "The {task_slug} task
  # will begin shortly." success toast - identical shape to MIPA's. The
  # "I click on the ... for every ... row ..." step (admin-tasks.ts, no
  # changes needed) checks each row against its OWN slug rather than a
  # fixed list, so this doesn't need updating if Carbon's task list
  # changes later.
  #
  # CONFIRMED SITE BUG - Carbon Admin only (live, 2026-08-31, reproduced
  # twice): triggering "Cleanup old Import data" returns a genuine HTTP
  # 500 from `GET /tasks/cleanup_old_import_data/run` - the UI correctly
  # surfaces this as its own error toast ("There was a problem when
  # attempting to run the cleanup_old_import_data task."), not a success
  # one, so this scenario legitimately and correctly fails on that one
  # row rather than silently passing. Not a selector/config gap and not
  # worked around here - every other one of Carbon's 15 tasks succeeds
  # normally; this is a real backend bug on Carbon specifically, worth
  # raising separately.
  #
  # CONFIRMED SITE QUIRK: navigating directly to /tasks via a full page
  # load (a bare URL, not a click through the sidebar) renders a
  # completely empty body - the SPA doesn't hydrate correctly on a fresh
  # deep-link to this route. Irrelevant to this scenario itself (it always
  # arrives via "I click precisely on ... Configuration/Tasks", never a
  # direct navigation), but worth knowing if debugging a failure here ever
  # involves reproducing manually with a raw page.goto().

  Scenario: Every task's play button successfully triggers its own run
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    When I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time
