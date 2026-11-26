@regression
Feature: Global layout - header, USP bar, footer and console baseline

  # BEN-379 (Next.js 15 upgrade) GL-01, GL-02, GL-04, GL-05. Built
  # 2026-11-11 from a live inspection of staging (Next 14) and the
  # next-15.benchmarx.pub feature branch. Every expected value is staging's
  # behaviour: a difference on the feature branch is a regression.
  #
  # Known on BOTH environments (not a regression): the footer "privacy
  # notice" link (/privacy-notice) is a 404, so the footer link check
  # excludes the stripped footer's Privacy Notice and the main footer list
  # is checked with that one known failure in mind (see GL-02 below).

  # GL-01
  Scenario: The header shows the logo, search, brochure, branch, booking and trade links
    Given I am on the "home" page
    Then the "header logo" should be displayed
    And the "header search input" should be displayed
    And the "Request a brochure link" should be displayed
    And the "Find a branch" should be displayed
    And the "header consultation button" should be displayed
    And the "Contact Us link" should be displayed
    And the "Trade customer link" should be displayed
    And the "Contract kitchen solutions link" should be displayed
    And all "header links" links should resolve without an error

  # GL-01: each header link goes where staging's does.
  Scenario Outline: The header "<link>" opens the <page> page
    Given I am on the "home" page
    And I wait for the page to settle
    When I click on the "<link>" link
    Then I should be redirected to the "<page>" page

    Examples:
      | link                            | page                       |
      | Request a brochure link         | request-a-brochure         |
      | Find a branch                   | branches                   |
      | header consultation button      | book-a-consultation        |
      | Contact Us link                 | contact-us                 |
      | Trade customer link             | trade-customers            |
      | Contract kitchen solutions link | contract-kitchen-solutions |

  # GL-04. Only the first-party USP links are requested: Trustpilot answers
  # automated requests with 403 whether or not the page exists.
  Scenario Outline: The USP bar's "<link>" goes to <destination>
    Given I am on the "home" page
    Then the "<link>" should have attribute "href" containing "<destination>"
    And all "usp bar links" links should resolve without an error

    Examples:
      | link                    | destination                               |
      | Finance options link    | /kitchen-finance                          |
      | Quality guaranteed link | /help-advice/warranty-information         |
      | Rated Excellent link    | trustpilot.com/review/www.benchmarxkitchens.co.uk |
      | Why choose us link      | /help-advice/why-choose-us                |

  # GL-02. The main footer's "privacy notice" link (/privacy-notice) is a 404
  # on staging AND live (pre-existing, not part of BEN-379), so the "main
  # footer links" mapping leaves it out; every other footer link is checked.
  Scenario: The footer's links resolve
    Given I am on the "home" page
    Then the "main footer" should be displayed
    And all "main footer links" links should resolve without an error
    And the "newsletter form" should be displayed
    And the "footer social links" should be displayed
    And the "footer sitemap link" should be displayed

  # GL-05: no console errors beyond staging's own baseline. Staging itself
  # logs: denied geolocation, a 400 from a tracking request, the Google
  # Places "script not loaded" race on map pages, and the Exponea "ga"
  # warning, so those are ignored, as is staging's PDP error "Cannot read
  # properties of undefined (reading 'pointtype')" (confirmed on staging
  # 2026-11-11, pre-existing). A failing Next.js server action logs
  # "An unexpected response was received from the server", which is NOT
  # ignored: it's the signature of R2 (branch pages) on the feature branch.
  Scenario Outline: The <page> template loads without unexpected console errors
    Given I start monitoring console errors, ignoring messages matching "Failed to load resource|GeolocationPositionError|Google script not loaded|exponea|Exponea|\bga\b|googletagmanager|google-analytics|doubleclick|trustpilot|stackadapt|Third-party cookie|Permissions policy|pointtype"
    And I navigate directly to the path "<path>"
    And I wait for the page to settle
    Then there should be no unexpected console errors

    Examples:
      | page              | path                                      |
      | home              | /                                         |
      | all kitchens      | /kitchen-ranges/all-kitchens              |
      | kitchen range     | /kitchen-ranges/shaker                    |
      | pdp               | /kitchens/nordica-blue-true-handleless    |
      | search            | /search?q=oak                             |
      | branch finder     | /branches                                 |
      | branch            | /branches/leeds                           |
      | booking           | /book-a-consultation                      |
      | contact           | /contact-us                               |
      | brochure          | /request-a-brochure                       |
      | blog              | /articles/blog                            |
      | article           | /article/new-benchmarx-design-bude-range  |
      | accessories       | /accessories-and-appliances               |
      | customer kitchens | /customer-kitchens                        |
      | 404               | /kitchens/does-not-exist                  |
