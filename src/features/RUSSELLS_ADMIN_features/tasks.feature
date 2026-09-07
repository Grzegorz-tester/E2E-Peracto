@regression
Feature: Admin Tasks Can All Be Triggered

  # Bespoke to Russells, not the shared Carbon_admin boilerplate suite -
  # same reasoning as MIPA_ADMIN_features/tasks.feature: triggering a task
  # actually runs a real backend job (reindexing, sitemap regeneration,
  # cleanup...), a write/mutating action rather than a read-only nav
  # check, so per CLAUDE.md's "Staging vs production rules" this is only
  # safe on a staging admin. Russells has no production admin env in this
  # repo today, but the shared Carbon_admin folder IS reused by tenants
  # that DO have one (e.g. KOOL_ADMIN_PROD.env) - so this scenario
  # deliberately lives in its own Russells-only feature path rather than
  # the shared folder.
  #
  # CONFIRMED (live, RUSSELLS_ADMIN staging, 2026-08-31): every one of
  # Russells' 11 current tasks (Product Indexer, Article Sitemap, Article
  # Image Sitemap, Category Sitemap, Article Category Sitemap, Product
  # Sitemap, Product Image Sitemap, Content Sitemap, Location Sitemap,
  # Cleanup, S3 Product Delta Import) renders its own play button and, on
  # click, raises a distinct "The {task_slug} task will begin shortly."
  # success toast, with the slug taken from that row's own detail link
  # (e.g. /tasks/product_indexer) - identical shape to MIPA's, confirming
  # this is the shared Peracto Admin Tasks feature, not a bespoke one.
  # The "I click on the ... for every ... row ..." step (admin-tasks.ts)
  # checks each row against its OWN slug rather than a fixed list of
  # expected task names, so a task added or removed on the backend later
  # doesn't require this feature file to be updated.
  #
  # CONFIRMED QUIRK (live, 2026-08-31): the Tasks list's rows can render
  # into the DOM a moment after the page/table shell itself does (a
  # client-fetched list, same as elsewhere in this suite) - a query taken
  # immediately after navigating can transiently see 0 rows even though
  # 11 real ones exist. Not a Russells-specific bug: the same
  # "task name link"/"play button" step already waits for attachment
  # before counting, so this is a non-issue for the actual scenario below,
  # just worth knowing if debugging a similar page here in future.

  Scenario: Every task's play button successfully triggers its own run
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    When I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time
