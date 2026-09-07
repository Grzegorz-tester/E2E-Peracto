@regression
Feature: Admin Tasks Can All Be Triggered

  # Bespoke to PizzaExpressLive, not the shared Carbon_admin boilerplate
  # suite - same reasoning as MIPA's own tasks.feature: triggering a task
  # actually runs a real backend job, a write/mutating action rather than
  # a read-only nav check, so per CLAUDE.md's "Staging vs production
  # rules" this is only safe on a staging admin. PizzaExpressLive has no
  # production admin env in this repo today, but the shared Carbon_admin
  # folder IS reused by tenants that DO have one - so this deliberately
  # lives in its own PizzaExpressLive-only feature path rather than the
  # shared folder.
  #
  # CONFIRMED (live, PIZZAEXPRESSLIVE_ADMIN staging, 2026-08-31): 13
  # tasks exist (Product Import, Product Relations Import, Product
  # Archive, Product Indexer, Article Category Sitemap, Article Images
  # Sitemap, Article Sitemap, Category Sitemap, Content Sitemap, Product
  # Sitemap, Location Sitemap, Cleanup old Import data, Hello world).
  # Four of them (the Product ones) show status "Inactive" rather than
  # "Active" - unlike MIPA where every task was Active - but this does
  # NOT stop their play button from working: every row still renders a
  # clickable button regardless of status, and triggering an Inactive
  # task raises the exact same "The {task_slug} task will begin
  # shortly." success toast as an Active one (confirmed live triggering
  # "Product Import" while Inactive). The existing "I click on the ...
  # for every ... row ..." step (admin-tasks.ts) needed no changes.

  Scenario: Every task's play button successfully triggers its own run
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Tasks" element
    Then I should be redirected to the "tasks" page
    When I click on the "play button" for every "task name link" row, confirming the "success toast" appears each time
