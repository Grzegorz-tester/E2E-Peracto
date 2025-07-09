@MIPA_regression

Feature: Verify that specific users can see only the products allowed for their User Group

  Scenario Outline: Verify products restrictions for specific users on PLP
    Given I am navigating the page as a "<user type>" user
    When I fill in the "header search box" input field with "product name"
    Then I should be presented with a "<string>" "<string>"

    Examples:
      | user type | product name | full restriction | restricted to my acc. |  |
      | guest     |              |                  |                       |  |
      | guest     |              |                  |                       |  |
      | guest     |              |                  |                       |  |
      | logged in |              |                  |                       |  |
      | logged in |              |                  |                       |  |
      | logged in |              |                  |                       |  |
      | logged in |              |                  |                       |  |

  Scenario Outline: Verify products restrictions for specific users on PDP
    Given I am navigating the page as a "<user type>" user
    Examples: 