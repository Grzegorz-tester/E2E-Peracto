@regression @mutates-admin-data
Feature: Admin Tasks Can All Be Triggered

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - the Tasks list and its "run" mechanism are standard
  # Peracto Admin functionality, confirmed present via the same nav/row
  # testids in every admin tenant's own dashboard.json/tasks.json mapping
  # (task name link/play button were already scaffolded identically on
  # every tenant except two, which were filled in on promotion). Triggering
  # a task actually runs a real backend job (reindexing, sitemap
  # regeneration, cache invalidation, import cleanup...), a write/mutating
  # action rather than a read-only nav check - per the user directly,
  # these can't be run in production but must be tested on release
  # branches and staging, so this is tagged @mutates-admin-data with the
  # same "I require a staging admin" runtime guard as every other write
  # scenario in this suite, rather than being excluded from the shared
  # folder outright.
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
  #
  # "hello_world" is excluded by name (not just by not-yet-existing): it's
  # leftover scaffolding from this task runner's own initial development,
  # not a real business task - CONFIRMED (live, Andy Thornton, 2026-09-10)
  # it exists there too, so this is standard Peracto Admin scaffolding, not
  # a MIPA-only artifact - per the user, remove it from scope rather than
  # keep asserting on it.
  #
  # Every OTHER task is expected to genuinely succeed regardless of its
  # Active/Inactive status - "Inactive" only means it has no automated
  # schedule (manual-trigger-only), not that it's allowed to fail when
  # manually triggered via this same play button. CONFIRMED (live,
  # MIPA_ADMIN_RELEASE 2.8.0, 2026-09-08): on MIPA specifically it's
  # actually a systemic bug, not a per-task one - all 3 Active tasks
  # return 200/success, while EVERY Inactive task 500s with "There was a
  # problem when attempting to run the {task} task." CONFIRMED (live, Andy
  # Thornton, 2026-09-10) this is NOT universal: every one of Andy
  # Thornton's 16 tasks is Inactive, and triggering one (back_in_stock)
  # returned a real 200 with the expected success toast - so this scenario
  # asserts the ideal (every non-excluded task succeeds) rather than
  # baking in MIPA's own bug as an expected result everywhere.
  #
  # Each row is checked independently rather than the scenario stopping at
  # the first failing task (admin-tasks.ts's "I click on ... for every ...
  # row ..." step collects every row's result and reports all failures
  # together) - with a systemic issue like MIPA's, stopping at the first
  # failure would hide exactly how widespread it is, which is the useful
  # part of this scenario's evidence on any tenant that has one.
  #
  # Merged in from several since-removed tenant-specific duplicates of this
  # same scenario (written 2026-08-31, before this file was shared -
  # discovered via scripts/check-duplicate-admin-features.sh) rather than
  # lost on cleanup:
  # - CONFIRMED (live, Carbon Admin staging, 2026-08-31): all 15 of Carbon's
  #   tasks render the same play button/toast shape as MIPA's, EXCEPT
  #   "Cleanup old Import data" - triggering it returns a genuine HTTP 500
  #   from GET /tasks/cleanup_old_import_data/run, surfaced correctly as its
  #   own error toast, not a success one. Confirmed a real backend bug on
  #   Carbon specifically (reproduced twice), not a selector/config gap - so
  #   this scenario is expected to keep failing on that one row for Carbon
  #   until it's fixed, same "assert reality" reasoning as everywhere else.
  # - CONFIRMED (live, HIB/Insinkerator/Indespension/KOOL/Russells staging,
  #   2026-08-31): every task on all five tenants triggers successfully
  #   regardless of its listed Active/Inactive status - further confirming
  #   MIPA's own systemic Active-succeeds/Inactive-fails split (see above)
  #   is a MIPA-specific data bug, not something to expect elsewhere.
  # - CONFIRMED (live, Insinkerator/Carbon, 2026-08-31): navigating directly
  #   to /tasks via a bare page load (not a sidebar click) renders an empty
  #   list/body on both - the SPA doesn't hydrate correctly on a fresh
  #   deep-link to this route. Irrelevant to this scenario (it always
  #   arrives via a real sidebar click), but worth knowing if reproducing a
  #   failure here manually.
  # - CONFIRMED (live, Russells, 2026-08-31): task rows can render into the
  #   DOM a moment after the page/table shell itself does - a query taken
  #   immediately after navigating can transiently see 0 rows even though
  #   real ones exist. Not tenant-specific: the "task name link"/"play
  #   button" step already waits for attachment before counting, so this
  #   is a non-issue for the scenario itself, just worth knowing if
  #   debugging a similar page in future.

  Scenario: Every task's play button successfully triggers its own run
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    And I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time, excluding "hello_world"
