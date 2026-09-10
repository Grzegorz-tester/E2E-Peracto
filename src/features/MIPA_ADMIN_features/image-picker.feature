@regression
Feature: Selecting An Image Via The File Manager From A Form Field

  # Bespoke to MIPA's own feature path for now - CKFinder/File Manager is
  # already confirmed MIPA-specific (see file-manager.feature), and this
  # is that same widget's real-world use case: picking an image FOR a
  # form field (a Category's "Main Image"), not just browsing files
  # standalone. Reuses file-manager.ts's frame-aware steps, generalised
  # (the trigger button and the "Choose" confirm step are both
  # parameterised, not fixed to one project) rather than duplicated.
  #
  # CONFIRMED BUG (live, MIPA_ADMIN staging, 2026-09-09, verified twice
  # via two different navigation paths to rule out a one-off fluke):
  # clicking Category's "Main Image" Browse button correctly opens the
  # same CKFinder widget file-manager.feature already covers, and
  # selecting a file there correctly reveals CKFinder's own "Choose"
  # toolbar button (confirmed present only once a file is selected) - but
  # clicking Choose closes the picker WITHOUT actually populating the
  # Main Image field. No value change, no thumbnail, nothing - confirmed
  # even after a generous wait and even with real in-app navigation to
  # rule out a direct-URL/hydration-timing explanation. This is a real
  # integration gap between the File Manager and this form field, not a
  # test issue: the field is genuinely left exactly as it was, so nothing
  # here needs restoring afterwards (no save is even attempted). Asserts
  # the CURRENT (buggy) behaviour, same "assert reality" approach as
  # tasks.feature's Inactive-task scenario and editing-content.feature's
  # Template scenario, so this starts failing loudly - a useful signal -
  # the moment the integration is fixed and this needs rewriting to
  # expect the field to actually update.

  Scenario: Choosing an image via Category's Main Image Browse button does not currently populate the field
    Given I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Categories" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Main Image" input field as "original main image"
    And I click on the "Browse Main Image" button, opening an image picker
    And I choose the "duck.jpg" file in the image picker
    Then the "Main Image" input field should have the remembered "original main image"
