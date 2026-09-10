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

  Scenario: Every task's play button successfully triggers its own run
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    And I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time, excluding "hello_world"
