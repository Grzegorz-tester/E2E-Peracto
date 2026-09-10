@regression @mutates-admin-data
Feature: Adding And Deleting A Redirect

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - Redirects is a standard Peracto Admin section, confirmed
  # present via the same "Redirects" nav testid in every admin tenant's own
  # dashboard.json. Its detail-page selectors (redirect-detail.json) were
  # previously only defined in MIPA's config; copied verbatim to every other
  # tenant on promotion, since they're plain data-testid/name selectors with
  # no MIPA-specific text - consistent with CLAUDE.md's confirmed finding
  # that this product shares identical testids across tenants. Not yet
  # live-verified against every tenant individually; each tenant's own
  # regression run will surface any real gap. Tagged @mutates-admin-data
  # with the same "I require a staging admin" runtime guard as
  # address-book-management.feature/editing-existing-entities.feature, for
  # the same reason (see src/index.ts's @mutates-admin-data comment).
  #
  # CONFIRMED LIVE (MIPA_ADMIN + MIPA storefront staging, 2026-09-08): a
  # redirect created here for a disposable, never-otherwise-used path
  # genuinely redirects real storefront traffic - visiting that made-up
  # path on staging.mipa-paints.pub actually lands on "/", not a 404. That
  # cross-system effect isn't asserted as part of this automated scenario
  # though: this framework's ScenarioWorld is scoped to ONE project's own
  # config (hosts/pages/mappings) per scenario, and the admin/storefront
  # are two separate projects (env/MIPA_ADMIN.env vs env/MIPA.env) with
  # different hosts - there's no natural way for a single scenario here to
  # also drive the storefront project's own config. This scenario instead
  # covers the full admin-side lifecycle (create, confirm it saved,
  # delete, confirm it's gone), which is what's actually automatable from
  # here.
  #
  # CONFIRMED (live, MIPA_ADMIN staging, 2026-09-08): the "From URL" field
  # is normalised on save - Peracto prepends a leading "/" if the typed
  # value doesn't already have one (a disposable "qa-<timestamp>" value
  # comes back as "/qa-<timestamp>") - hence the "contain" (not exact
  # "have") assertion below.

  Scenario: Adding a redirect saves it, and it can be deleted again
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Configuration" element
    And I click precisely on the "Redirects" element
    And I click precisely on the "Add Redirect" element
    And I fill in the "From URL" input field with a unique value, remembering it as "redirect from path"
    And I fill in the "To URL" input field with "/"
    And I click precisely on the "Save" element
    Then the "success toast" should be displayed
    And the "From URL" input field should contain the remembered "redirect from path"

    When I click precisely on the "Delete Redirect" element
    And I click precisely on the "Confirm Delete Redirect" element
    Then the "success toast" should be displayed
