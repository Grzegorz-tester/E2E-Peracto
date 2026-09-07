@regression
Feature: Every Task's Play Button Successfully Triggers Its Own Run

  # Bespoke to HIB, not the shared Carbon_admin boilerplate suite - same
  # reasoning as MIPA's own tasks.feature: triggering a task runs a real
  # backend job, a write/mutating action rather than a read-only nav
  # check, so per CLAUDE.md's "Staging vs production rules" this is only
  # safe on a staging admin. HIB has no production admin env in this repo
  # today, but the shared Carbon_admin folder IS reused by tenants that DO
  # have one - so this deliberately lives in its own HIB-only feature path.
  #
  # CONFIRMED (live, HIB_ADMIN staging, 2026-08-31): all 11 of HIB's tasks
  # trigger successfully regardless of their listed Status badge (9 show
  # "Inactive", 2 show "Active") - every row's play button raises the
  # same "The {task_slug} task will begin shortly." success toast and a
  # real 200 from its own /tasks/{slug}/run endpoint. "Inactive" here
  # describes the task's own scheduling state, not whether it can be
  # manually triggered - reused the same generic step unmodified.

  Scenario: Every task's play button successfully triggers its own run
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    When I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time
