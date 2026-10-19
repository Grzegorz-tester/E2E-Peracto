@regression
Feature: Replace My Window

  # "Replace My Window" in the header is a content page (no configurator or
  # finder of its own); its commercial job is to send the visitor to the
  # replacement enquiry form or Find Installer. The enquiry form is checked
  # for presence only here - real form submission is covered once, by
  # contact-us.feature's @submits-real-form scenario, rather than sending
  # Keylite staff a second test enquiry per run from this form too.

  Background:
    Given I am navigating the page as a "guest" user
    And I am on the "replace-my-window" page
    And I dismiss the newsletter popup if present

  Scenario: "Request a Quote" opens the replacement enquiry form
    Then the "page heading" should contain the text "Replace Your Old Roof Window"
    When I click on the "1st" "Request a Quote" element via JavaScript
    Then I should be redirected to the "replacement-enquiry-form" page
    And the "enquiry form" should be displayed

  Scenario: "Find Installer" leads to the installer finder
    When I click on the "1st" "Find Installer link" element via JavaScript
    Then I should be redirected to the "branches" page
