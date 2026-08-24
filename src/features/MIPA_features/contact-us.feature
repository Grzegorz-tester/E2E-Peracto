@MIPA_regression
Feature: Contact Us page

  # New coverage. Confirmed live: no "Country dropdown" and no separate
  # "GET DIRECTIONS" button exist here (the original QA export's steps for
  # those came from a different client's site, same contamination as the
  # "Butterflies Eyecare" wording seen elsewhere in the export) - the map
  # is a plain embedded iframe with no extra controls.
  #
  # Note: submitting the form posts to the site's own staging API
  # (form-submissions endpoint, same one basket/checkout use) rather than
  # sending a real email directly - consistent with this repo's "staging:
  # free rein" rule - but there's no visible on-page confirmation after
  # submitting (confirmed live: the page just reloads back to the same
  # empty form), so that isn't asserted here.

  Scenario: Contact form and page elements are present
    Given I am on the "contact-us" page
    Then the "Name field" should be displayed
    And the "Email address field" should be displayed
    And the "Telephone number field" should be displayed
    And the "Message field" should be displayed
    And the "Send button" should be displayed
    And the "map" should be displayed


  Scenario: Contact details are displayed and email links work
    Given I am on the "contact-us" page
    Then the "Sales email link" should be displayed
    And the "Technical email link" should be displayed
    And the "contact phone number" should be displayed
