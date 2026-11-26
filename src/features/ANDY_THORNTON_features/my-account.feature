@regression
Feature: Operations in the user's account

  # UPDATED (2026-09-14): real Andy Thornton production accounts now
  # exist (see logging-in.feature) and the account.json tab selectors
  # (Radix UI data-value, matching this same site's checkout components)
  # have now had their first live confirmation - Dashboard/Address Book/
  # Orders are all genuinely correct as guessed. Profile and Moodboards
  # needed real fixes, see their own scenarios below.

  # 2026-11-22: Dashboard tab scenario removed - the account page is loaded by account-actions.feature and quote-builder-access.feature.

  # CONFIRMED SITE BUG (live, production/www.andythornton.com,
  # 2026-09-14): clicking "Profile tab" doesn't navigate anywhere - the
  # URL stays on "/account" instead of moving to "/account/profile",
  # unlike Address Book/Orders which redirect correctly. Raised with the
  # site owner 2026-09-14 - expected to stay red until fixed, not a
  # test/mapping gap.
  Scenario: Check the presence of Profile elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Profile tab" tab
    Then I should be redirected to the "account-profile" page

  # 2026-11-22: Address book tab scenario removed - account-actions.feature's address scenarios load that page on every environment.

  Scenario: Check the presence of Orders elements
    Given I am navigating the page as a "logged in" user
    When I am on the "account" page
    And I click on the "Orders tab" tab
    Then I should be redirected to the "account-orders" page

  # CONFIRMED (live, production/www.andythornton.com, 2026-09-14):
  # Moodboards isn't available to the "logged in" account (an admin-type
  # user) - it's a non-admin-only feature. Uses a dedicated "non admin"
  # user (ANDY_THORNTON_PROD_NON_ADMIN_EMAIL/PASSWORD) instead.
  Scenario: Check the presence of Moodboards elements
    Given I am navigating the page as a "non admin" user
    When I am on the "account" page
    And I click on the "Moodboards tab" tab
    Then I should be redirected to the "account-moodboards" page
