@regression
Feature: Admin Tasks Can All Be Triggered

  # Bespoke to KOOL, not the shared Carbon_admin boilerplate suite - same
  # reasoning as MIPA's tasks.feature: triggering a task actually runs a
  # real backend job (reindexing, sitemap regeneration, import cleanup,
  # price import...), a write/mutating action rather than a read-only nav
  # check, so per CLAUDE.md's "Staging vs production rules" this is only
  # safe on a staging admin. KOOL DOES have a production admin env in
  # this repo (KOOL_ADMIN_PROD.env), but that env's FEATURE_PATH only
  # globs the shared Carbon_admin folder, not this KOOL-only feature
  # path - so this scenario is inherently safe from running against
  # KOOL's production admin without needing any extra tag/guard.
  #
  # CONFIRMED (live, KOOL_ADMIN staging, 2026-08-31): every one of KOOL's
  # 15 current tasks (Article Category Sitemap, Article Images Sitemap,
  # Article Sitemap, Category Sitemap, Cleanup old Import data, Content
  # Sitemap, Location Sitemap, Product and ProductVariant Price Import,
  # Quote Pricing Import, Quote Supersession Update, Product Images
  # Sitemap, Product Indexer, Product Sitemap, Kerridge Failed Orders
  # Resend, Hello world) renders its own play button and, on click,
  # raises a distinct "The {task_slug} task will begin shortly." success
  # toast, with the slug taken from that row's own detail link - identical
  # shape to MIPA. The "I click on the ... for every ... row ..." step
  # (admin-tasks.ts) checks each row against its OWN slug rather than a
  # fixed list of expected task names, so a task added or removed on the
  # backend later doesn't require this feature file to be updated.

  Scenario: Every task's play button successfully triggers its own run
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    When I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time
