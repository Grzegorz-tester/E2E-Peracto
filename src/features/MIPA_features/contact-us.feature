@regression
Feature: Contact Us page

  # New coverage. Confirmed live: no "Country dropdown" and no separate
  # "GET DIRECTIONS" button exist here (the original QA export's steps for
  # those came from a different client's site, same contamination as the
  # "Butterflies Eyecare" wording seen elsewhere in the export) - the map
  # is a plain embedded iframe with no extra controls.

  # 2026-09-25: /contact-us was redesigned as "Mipa Paints Help & Advice"
  # (identical on feature-next-15 and staging). The on-page contact form and
  # the sales@/technical@ mailto links are gone - the page now has 4 enquiry
  # tiles, each an image link out to a form on mipa-paints.uk
  # (technical-/supply-/sales-/training-enquiries), plus opening hours and a
  # telephone block. The tiles' links point off-site, so only their presence
  # is asserted, not that the external forms work.
  Scenario: Help & Advice page shows the enquiry tiles
    Given I am on the "contact-us" page
    Then the "page heading" should be displayed
    And the "Technical enquiry tile" should be displayed
    And the "General enquiry tile" should be displayed
    And the "Sales enquiry tile" should be displayed
    And the "Training enquiry tile" should be displayed


  Scenario: Contact details are displayed
    Given I am on the "contact-us" page
    Then the "Opening hours heading" should be displayed
    And the "Telephone heading" should be displayed
    And the "contact phone number" should be displayed
