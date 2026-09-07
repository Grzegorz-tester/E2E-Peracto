@regression
Feature: Admin Tasks Can All Be Triggered

  # Bespoke to Indespension, not the shared Carbon_admin boilerplate suite
  # - same reasoning as MIPA_ADMIN_features/tasks.feature: triggering a
  # task actually runs a real backend job, a write/mutating action rather
  # than a read-only nav check, so per CLAUDE.md's "Staging vs production
  # rules" this is only safe on a staging admin. Indespension has no
  # production admin env in this repo today, but the shared Carbon_admin
  # folder IS reused by tenants that DO have one (e.g. KOOL_ADMIN_PROD.env)
  # - so this deliberately lives in its own Indespension-only feature path
  # rather than the shared folder.
  #
  # CONFIRMED (live, INDESPENSION_ADMIN staging, 2026-08-31): every one of
  # Indespension's 11 current tasks (Product Indexer, Article Sitemap,
  # Article Image Sitemap, Category Sitemap, Article Category Sitemap,
  # Product Sitemap, Product Image Sitemap, Content Sitemap, Location
  # Sitemap, Cleanup old Import data, Google Product Feed) renders its own
  # play button and, on click, raises a distinct "The {task_slug} task
  # will begin shortly." success toast, identical shape to MIPA's - same
  # "I click on the ... for every ... row ..." generic step (admin-tasks.ts)
  # applies unmodified, checking each row against its OWN slug rather than
  # a fixed list of expected task names.

  Scenario: Every task's play button successfully triggers its own run
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    When I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time
