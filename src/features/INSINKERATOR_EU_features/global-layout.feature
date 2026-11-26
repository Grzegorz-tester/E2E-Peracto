@regression
Feature: Global layout

  # Covers Benchmarx BEN-390 (Next 15 / React 19: findDOMNode crash on
  # branch pages) and the general "no React errors" check, re-checked on
  # this site 2026-11-26. One row per page template.
  #
  # Staging's baseline noise, confirmed on every page 2026-11-26 and ignored:
  # Content-Security-Policy "[Report Only]" violations (ubembed, HubSpot
  # forms, Trustpilot, Typekit, model-viewer WebAssembly), "Failed to load
  # resource" (missing country flag SVGs, a tracking script with an SSL
  # error) and reCAPTCHA's "requestStorageAccess: Permission denied".
  # Nothing else was logged. A React error or a failing Next.js server
  # action ("An unexpected response was received from the server") is NOT
  # ignored.
  Scenario Outline: The <page> template loads without unexpected console errors
    Given I start monitoring console errors, ignoring messages matching "\[Report Only\]|Failed to load resource|requestStorageAccess"
    And I navigate directly to the path "<path>"
    And I click on the "Accept cookies" button if present
    And I click on the "Select Portugal" button if present
    And I wait for the page to settle
    Then there should be no unexpected console errors

    Examples:
      | page                | path                    |
      | home                | /                       |
      | plp                 | /category/accessories   |
      | pdp                 | /products/standard-460  |
      | search              | /search?q=nickel        |
      | showroom collection | /showroom-collection    |
      | warranty finder     | /warranty-finder        |
