@regression
Feature: Admin Tasks Can All Be Triggered

  # Bespoke to Insinkerator, not the shared Carbon_admin boilerplate suite -
  # same reasoning as MIPA's own tasks.feature: triggering a task actually
  # runs a real backend job, a write/mutating action rather than a
  # read-only nav check, so per CLAUDE.md's "Staging vs production rules"
  # this is only safe on a staging admin. Insinkerator has no production
  # admin env in this repo today, but the shared Carbon_admin folder IS
  # reused by tenants that DO have one (e.g. KOOL_ADMIN_PROD.env) - so this
  # scenario deliberately lives in its own Insinkerator-only feature path
  # rather than the shared folder.
  #
  # CONFIRMED (live, INSINKERATOR_ADMIN staging, 2026-08-31): every one of
  # Insinkerator's 12 current tasks (Product Indexer, Article Sitemap,
  # Article Image Sitemap, Category Sitemap, Article Category Sitemap,
  # Product Sitemap, Product Image Sitemap, Content Sitemap, Location
  # Sitemap, Cleanup, Order export, Google Product Feed) renders its own
  # play button and, on click, raises a "The {task_slug} task will begin
  # shortly." success toast, identical shape to MIPA - the "I click on the
  # ... for every ... row ..." step (admin-tasks.ts) checks each row
  # against its own slug rather than a fixed list, so this doesn't need
  # updating if a task is added/removed later.
  #
  # CONFIRMED QUIRK: navigating directly to /tasks by URL renders an empty
  # list (client-side data fetch doesn't fire the same way) - going
  # through the sidebar nav click (Configuration > Tasks) as this scenario
  # does works correctly and shows all 12 rows.

  Scenario: Every task's play button successfully triggers its own run
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    When I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time
