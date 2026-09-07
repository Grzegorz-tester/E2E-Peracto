@regression
Feature: Admin Tasks Can All Be Triggered

  # Bespoke to MIPA, not the shared Carbon_admin boilerplate suite - same
  # reasoning as product-management.feature: triggering a task actually
  # runs a real backend job (reindexing, sitemap regeneration, cache
  # invalidation, import cleanup...), a write/mutating action rather than
  # a read-only nav check, so per CLAUDE.md's "Staging vs production
  # rules" this is only safe on a staging admin. MIPA has no production
  # admin env in this repo today, but the shared Carbon_admin folder IS
  # reused by tenants that DO have one (e.g. KOOL_ADMIN_PROD.env) - so
  # this scenario deliberately lives in its own MIPA-only feature path
  # (env/MIPA_ADMIN.env's FEATURE_PATH) rather than the shared folder, and
  # must stay that way rather than being moved/copied into Carbon_admin.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-08-30): every one of MIPA's
  # 12 current tasks (Hello world, Product Import, Product Indexer, DC
  # Cache Invalidate, DC Failed Orders Resend, and six sitemap/cleanup
  # jobs) renders its own play button and, on click, raises a distinct
  # "The {task_slug} task will begin shortly." success toast, with the
  # slug taken from that row's own detail link (e.g. /tasks/hello_world).
  # The "I click on the ... for every ... row ..." step (admin-tasks.ts)
  # checks each row against its OWN slug rather than a fixed list of
  # expected task names, so a task added or removed on the backend later
  # doesn't require this feature file to be updated.

  Scenario: Every task's play button successfully triggers its own run
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    When I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time
