@MIPA_regression
Feature: Footer

  # New coverage. The original QA export's "Footer links redirections"
  # case referenced "the Butterflies Eyecare website" - leftover
  # contamination from a different client, not usable as written. Covered
  # here instead using the existing generic "all links should resolve"
  # step against the real footer navigation and social links.

  Scenario: Footer navigation links all resolve
    Given I am on the "home" page
    Then all "footer navigation links" links should resolve without an error


  Scenario: Footer social media icons all resolve
    Given I am on the "home" page
    Then all "footer social links" links should resolve without an error


  Scenario: Company details are displayed in the footer
    Given I am on the "home" page
    Then the "footer company details" should contain the text "Registered Office: Fulflood Rd, Leigh Park, Portsmouth, Havant PO9 5AX. Company Registration No. 02074363. VAT No. 459692980."
