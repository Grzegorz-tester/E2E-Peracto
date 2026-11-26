@regression @PE-76
Feature: PE-76 admin session and write operations

  PizzaExpress Live specific gap scenarios for PE-76 (Peracto 72 -> 79,
  Symfony 7.4, Doctrine ORM 3). The shared CARBON_ADMIN_SHARED_features suite
  already covers login, create/delete and list loading; these add the write
  and session paths the PE-76 test plan calls out as uncovered. Staging only.

  # PE-76 AUTH-08 / AUTH-05 (admin side). Logging out must end the session:
  # a protected route afterwards, and the browser's back button, both land
  # on the login page rather than restoring the admin.
  Scenario: Logging out ends the admin session
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Logout" element
    Then I should eventually be redirected to the "login" page
    When I navigate directly to the path "/orders"
    Then I should eventually be redirected to the "login" page
    When I go back in the browser history
    Then I should eventually be redirected to the "login" page

  # PE-76 ADM-04. Uses the Utilities tab's Key Category Label: empty on
  # staging (confirmed live 2026-11-14) and restored to its original value
  # straight after, so the storefront utility bar is only touched briefly.
  @mutates-admin-data @serial
  Scenario: A settings change persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Settings" element
    Then I should be redirected to the "settings" page
    When I click precisely on the "Utilities tab" element
    And I remember the value of the "Key Category Label" input field as "original key category label"
    And I fill in the "Key Category Label" input field with a unique value, remembering it as "new key category label"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed
    When I reload the page
    And I click precisely on the "Utilities tab" element
    Then the "Key Category Label" input field should have the remembered "new key category label"
    When I fill in the "Key Category Label" input field with the remembered "original key category label"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed
    When I reload the page
    And I click precisely on the "Utilities tab" element
    Then the "Key Category Label" input field should have the remembered "original key category label"

  # PE-76 ADM-06. The shared suite creates and deletes a user; this adds the
  # role change and deactivation saves in between, on a throwaway user so
  # no real account is ever disabled.
  @mutates-admin-data
  Scenario: A new user's role and account status can be changed, then the user deleted
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Users" element
    And I click precisely on the "All Users" element
    And I click precisely on the "Add User" element
    And I fill in the "User First Name" input field with "Velstar"
    And I fill in the "User Last Name" input field with a unique value, remembering it as "new user last name"
    And I fill in the "User Email" input field with a unique email, remembering it as "new user email"
    And I click precisely on the "Save" element
    And I wait for the save to complete
    Then the "success toast" should be displayed
    When I click precisely on the "Users" element
    And I click precisely on the "All Users" element
    And I fill in the "Email filter" input field with the remembered "new user email"
    And I click precisely on the "Apply" element
    And I click precisely on the "first item link" element
    Then the "page heading" should contain the text "Edit User"
    When I click precisely on the "Edit customer button" element
    And I select the "Admin" option from the "Roles" react-select
    And I select the "Disabled" option from the "Account Status" react-select
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed
    When I reload the page
    Then the "customer summary" should contain the text "Admin"
    When I click precisely on the "Edit customer button" element
    Then the "Account Status" should contain the text "Disabled"
    When I click precisely on the "Delete User" element
    And I click precisely on the "Confirm Delete User" element
    Then the "success toast" should be displayed

  # PE-76 PHP-04 (parent event). A full save of a real Spektrix-imported
  # event (with its child-event variants and 20 event attributes) goes
  # through the ProductVariant override and the Doctrine 3 mapping. Uses
  # "Ivo Neame Trio", a DRAFT event on staging (confirmed live 2026-11-14),
  # so nothing changes on the staging storefront. Pre Title is empty there
  # and is restored afterwards.
  #
  # NOT ADM-09: this tenant has no seo_title/seo_description attributes at
  # all (not in the "Event" attribute set, not defined as attributes;
  # CONFIRMED via the API 2026-11-14). The admin still shows a Search Engine
  # Listing Preview "Edit" panel, and saving it toasts "Product successfully
  # updated!", but the value is sent as a stray top-level
  # "attribute-seo_description" key and silently dropped. Pre-existing
  # config gap, raised with PE-76; add an SEO scenario once the attributes
  # exist.
  @mutates-admin-data
  Scenario: An event attribute persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I fill in the "Name filter" input field with "Ivo Neame Trio"
    And I click precisely on the "Apply" element
    And I click precisely on the "first item link" element
    Then I should be redirected to the "product-detail" page
    When I wait for the page to settle
    And I remember the value of the "Pre Title" input field as "original pre title"
    And I fill in the "Pre Title" input field with a unique value, remembering it as "new pre title"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed
    When I reload the page
    And I wait for the page to settle
    Then the "Pre Title" input field should have the remembered "new pre title"
    When I fill in the "Pre Title" input field with the remembered "original pre title"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed
    When I reload the page
    And I wait for the page to settle
    Then the "Pre Title" input field should have the remembered "original pre title"

  # PE-76 PHP-04 (child event). Saves a child event's price and checks the
  # decimal round-trips exactly (Doctrine DBAL 4 changed decimal/float
  # handling), then restores it. Same draft event as above.
  @mutates-admin-data
  Scenario: A child event's price persists after a reload, and can be restored
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "All Products" element
    And I fill in the "Name filter" input field with "Ivo Neame Trio"
    And I click precisely on the "Apply" element
    And I click precisely on the "first item link" element
    Then I should be redirected to the "product-detail" page
    When I click precisely on the "Manage Variants button" element
    Then I should be redirected to the "product-variants-list" page
    When I click precisely on the "first variant link" element
    Then I should be redirected to the "product-variant-detail" page
    When I remember the value of the "Price" input field as "original variant price"
    And I fill in the "Price" input field with "19.99"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed
    When I reload the page
    Then the "Price" should equal the value "19.99"
    When I fill in the "Price" input field with the remembered "original variant price"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed
    When I reload the page
    Then the "Price" input field should have the remembered "original variant price"
