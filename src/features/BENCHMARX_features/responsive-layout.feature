@regression
Feature: Responsive layout

  # BEN-379 (Next.js 15 upgrade) RES-01 (automatable part). Built
  # 2026-11-11. Every template is loaded at phone width (390 x 844, the
  # plan's iPhone viewport) and must not scroll sideways; the plan's visual
  # comparison against staging at 820 and 1440 px stays a manual check.
  # XB-01: run this folder with UI_AUTOMATION_BROWSER=webkit (or firefox)
  # for the cross-browser pass, see NOTES.md.

  Scenario Outline: The <page> template fits a phone screen without sideways scrolling
    Given I am on the "home" page
    And I resize the browser to a "mobile" viewport
    When I navigate directly to the path "<path>"
    And I wait for the page to settle
    Then the "page heading" should be displayed
    And the page should not scroll horizontally

    Examples:
      | page          | path                                     |
      | home          | /                                        |
      | all kitchens  | /kitchen-ranges/all-kitchens             |
      | pdp           | /kitchens/nordica-blue-true-handleless   |
      | search        | /search?q=oak                            |
      | branch finder | /branches                                |
      | branch        | /branches/leeds                          |
      | booking       | /book-a-consultation                     |
      | contact       | /contact-us                              |
      | blog          | /articles/blog                           |
      | article       | /article/new-benchmarx-design-bude-range |
      | accessories   | /accessories-and-appliances              |
