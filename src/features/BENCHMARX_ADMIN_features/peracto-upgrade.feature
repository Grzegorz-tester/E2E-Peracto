@regression
Feature: Peracto API and Admin upgrade checks (BEN-233)

  # BEN-233 (Peracto API 71.3.0 -> 73.0.0 -> 81, Admin 12.1.0 -> v12.40;
  # subtasks BEN-248, BEN-251, BEN-253). Built 2026-11-19 from a live
  # inspection of staging-peracto.benchmarx.pub, written as if the upgrade is
  # already on staging (the release host wasn't known yet). Covers only the
  # acceptance criteria the shared CARBON_ADMIN_SHARED_features suite doesn't:
  #   - page search (PER3-156) and article heading search (PER3-167): already
  #     in list-filtering.feature (Pages by Name, Articles by Heading)
  #   - every task can be triggered (incl. the Algolia indexer): tasks.feature
  #   - product relations (PER3-52) on the storefront: BENCHMARX pdp and
  #     customer-kitchens features
  # Order export filter (PER3-146) isn't covered: Benchmarx has no checkout,
  # so staging has no orders and no export to filter.
  #
  # Data baselines below are staging's counts on 2026-11-19. They're floors
  # (content may grow, never shrink): raise them if content is added.
  #
  # CONFIRMED 2026-11-19: choosing 1000 per page on Pages asks the API for
  # itemsPerPage=1000, gets 200 back (Pages has 355), and disables Next, so
  # 155 pages can't be reached from that view. The Pages row is expected red
  # until the admin respects the API's page cap.

  Background:
    Given I am navigating the page as a "admin" user

  # BEN-233 / BEN-251: "No payload size errors when loading large datasets"
  # and "All existing data is intact post-upgrade".
  Scenario Outline: <list> loads all <minimum>+ rows at 1000 per page without a failed API call
    Given I start monitoring failed network responses from hosts matching "benchmarx\.pub"
    And I am on the "<page id>" page
    When I select the "1000" option from the "result count dropdown" dropdown
    Then I should see at least <minimum> "table row" displayed
    And there should be no failed network responses

    Examples:
      | list                   | page id   | minimum |
      | Products               | products  | 133     |
      | Pages                  | pages     | 355     |
      | Articles               | articles  | 31      |
      | Locations              | locations | 139     |
      | User Generated Content | kitchens  | 35      |

  # BEN-233 / BEN-251: "Telephone and email fields accept valid formats
  # including + in email addresses".
  @mutates-admin-data
  Scenario: A user saved with a plus-addressed email and +44 phone numbers keeps them
    Given I require a staging admin for this scenario
    When I click precisely on the "Users" element
    And I click precisely on the "All Users" element
    And I click precisely on the "Add User" element
    And I fill in the "User First Name" input field with "Velstar"
    And I fill in the "User Last Name" input field with "Test"
    And I fill in the "User Email" input field with a unique plus-addressed email, remembering it as "plus email"
    And I fill in the "User Telephone" input field with "+44 1234 567890"
    And I fill in the "User Mobile" input field with "+447700900123"
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should be displayed

    When I click precisely on the "Users" element
    And I click precisely on the "All Users" element
    And I fill in the "Email filter" input field with the remembered "plus email"
    And I click precisely on the "Apply" element
    And I click precisely on the "first item link" element
    Then the "page heading" should contain the text "Edit User"
    # The saved details show as a summary card; Edit opens the inputs.
    When I click precisely on the "Edit user details" element
    Then the "User Email" input field should have the remembered "plus email"
    And the "User Telephone" should equal the value "+44 1234 567890"
    And the "User Mobile" should equal the value "+447700900123"

    When I click precisely on the "Delete User" element
    And I click precisely on the "Confirm Delete User" element
    Then the "success toast" should be displayed

  # BEN-251: "Locale input for ArticleCategories (PER3-133) renders and saves
  # correctly". entity-creation.feature only creates and deletes one; this
  # reopens it to check the locale was stored.
  @mutates-admin-data
  Scenario: An Article Category's locale is saved and shown when it's reopened
    Given I require a staging admin for this scenario
    When I click precisely on the "Content" element
    And I click precisely on the "Article Categories" element
    And I click precisely on the "Add Article Category" element
    Then the "Locale" should be displayed
    When I fill in the "Category Name" input field with a unique test title
    And I fill in the "Title" input field with "Velstar Test"
    And I fill in the "Locale" input field with "en_GB"
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should contain the text "Article Category successfully added!"

    When I click precisely on the "Content" element
    And I click precisely on the "Article Categories" element
    And I fill in the "Name filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I click precisely on the "first item link" element
    Then I should be redirected to the "article-category-detail" page
    And the "Locale" should equal the value "en_GB"
    And the "Category Name" input field should have the remembered "content title"

    When I click precisely on the "Content" element
    And I click precisely on the "Article Categories" element
    And I fill in the "Name filter" input field with the remembered "content title"
    And I click precisely on the "Apply" element
    And I wait for the page to settle
    And I delete the content row containing the stored content title

  # Benchmarx-only "User Generated Content" section (feeds the storefront's
  # /customer-kitchens gallery; nav "All User Generated Content" -> /kitchens).
  # Its "You may also like" list is a product relation, so it also exercises
  # the refactored relations endpoint (PER3-52) from the admin side.
  Scenario: User Generated Content lists kitchens, filters by SKU and opens one with its related kitchens
    When I click precisely on the "User Generated Content" element
    And I click precisely on the "All User Generated Content" element
    Then I should be redirected to the "kitchens" page
    And the "page heading" should contain the text "User Generated Content"
    And the "table row" should be displayed
    When I remember the text of the first non-empty "kitchen sku" as "filter term"
    And I fill in the "SKU filter" input field with the remembered "filter term"
    And I click precisely on the "Apply" element
    Then the "kitchen sku" should contain the remembered "filter term"
    When I click precisely on the "first item link" element
    Then I should be redirected to the "kitchen-detail" page
    And the "page heading" should contain the text "Edit User Generated Content"
    And the "kitchen name" should not equal the value ""
    And the "related kitchens" should be displayed
