@regression @mutates-admin-data
Feature: Selecting An Image Via The File Manager From A Form Field

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - File Manager/CKFinder is now confirmed universal (see
  # file-manager.feature's own promotion), and this is that same widget's
  # real-world use case: picking an image FOR a form field (a Category's
  # "Main Image"), not just browsing files standalone. Reuses
  # file-manager.ts's frame-aware steps, already generalised (the trigger
  # button and the "Choose" confirm step are both parameterised, not fixed
  # to one project).
  #
  # Tagged @mutates-admin-data + "I require a staging admin" (2026-09-29):
  # this uploads and then deletes a real file through CKFinder, exactly like
  # file-manager.feature, so it must never run against a read-only
  # production admin. It was missing both guards until a dry run of the new
  # INDESPENSION_ADMIN_PROD env listed it among the production scenarios.
  #
  # CONFIRMED BUG on TWO independent tenants (live, MIPA_ADMIN staging,
  # 2026-09-09, verified twice via two different navigation paths to rule
  # out a one-off fluke; RE-CONFIRMED live, Andy Thornton, 2026-09-10):
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
  # tasks.feature's Inactive-task scenario, so this starts failing loudly
  # - a useful signal - the moment the integration is fixed and this needs
  # rewriting to expect the field to actually update.
  #
  # CONFIRMED SELECTOR GAP, fixed on promotion (live, Andy Thornton,
  # 2026-09-10): the "Browse Main Image" mapping (`[data-testid=
  # 'button-resources_Main-Image']`) is ambiguous on this tenant - both
  # the "Upload" and "Browse" buttons for the same Main Images field share
  # that exact testid (2 elements, distinguished only by their visible
  # text). The original plain selector happened to work on MIPA (a single
  # match there) but silently clicked "Upload" instead of "Browse" on
  # Andy Thornton with no error, which would have made this scenario test
  # the wrong control entirely. Fixed by scoping the selector to
  # `:has-text('Browse')` (resolves to exactly 1 match on every tenant
  # checked) - updated in every tenant's category-detail.json on
  # promotion, not just where the ambiguity was found, since it's a
  # strict improvement with no downside even where only one element ever
  # matched.
  #
  # Originally picked a pre-existing file, "duck.jpg", by name rather than
  # uploading a fresh disposable one first - confirmed present in the File
  # Manager on MIPA and Andy Thornton, but CONFIRMED ABSENT (live, HIB_ADMIN
  # release branch, 2026-09-11: "I choose the 'duck.jpg' file in the image
  # picker" timed out, file not found) - exactly the signal this comment
  # already anticipated, so switched to uploading the same disposable fixture
  # file-manager.feature itself already uses ("Choose" doesn't care how the
  # file got into the listing) and deleting it again afterward, rather than
  # assuming every tenant's real File Manager contents match MIPA's. Doesn't
  # need re-verifying per tenant any more, since it no longer depends on
  # pre-existing tenant content.

  Scenario: Choosing an image via Category's Main Image Browse button does not currently populate the field
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    When I click precisely on the "Products" element
    And I click precisely on the "Categories" element
    And I click precisely on the "first item link" element if present
    And I remember the value of the "Main Image" input field as "original main image"
    And I click on the "Browse Main Image" button, opening an image picker
    And I upload the "velstar-test-file-manager-upload.png" file to the File Manager
    And I choose the "velstar-test-file-manager-upload.png" file in the image picker
    Then the "Main Image" input field should have the remembered "original main image"

    When I click on the "Browse Main Image" button, opening an image picker
    And I delete the "velstar-test-file-manager-upload.png" file from the File Manager
