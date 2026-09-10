@regression @mutates-admin-data
Feature: File Manager (CKFinder)

  # Promoted from MIPA_ADMIN_features to the shared Carbon_admin boilerplate
  # (2026-09-10) - the earlier "confirmed absent on Carbon Admin" finding
  # this file was originally scoped around turned out to be stale: live
  # re-verification found the "File Manager" nav item genuinely present and
  # fully working (real CKFinder browser, real files) on THREE independent
  # tenants checked - MIPA, Carbon Admin, and Andy Thornton - so this is
  # standard Peracto Admin functionality, not a MIPA-specific bespoke
  # feature. Tagged @mutates-admin-data with the same "I require a staging
  # admin" runtime guard as every other write scenario in this suite,
  # since this uploads/deletes a real file via CKFinder's connector and the
  # shared folder is reused by tenants with a production admin env.
  #
  # It opens a classic CKFinder file browser rendered inside a real
  # <iframe> - confirmed live that iframe's own src attribute stays empty
  # throughout (CKFinder writes its UI into the frame's document via JS
  # rather than navigating it to a URL), which is why this needs its own
  # frame-aware steps (file-manager.ts) rather than this repo's generic
  # mapping-driven ones - none of those can reach inside an iframe.
  #
  # Each scenario deletes whatever it uploads, so repeat runs don't
  # accumulate test files on any tenant's real site. Verified live
  # end-to-end on Andy Thornton (upload + list + delete, both a plain text
  # file and a real .png image) before promoting - all steps passed
  # unmodified, no tenant-specific branching needed.

  Scenario: Opening the File Manager loads a working CKFinder file browser
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    And I am on the "dashboard" page
    When I open the File Manager
    Then the File Manager should not list a file named "velstar-test-file-manager-upload.txt"


  Scenario: Uploading a file through the File Manager adds it to the listing, and it can be deleted again
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    And I am on the "dashboard" page
    When I open the File Manager
    And I upload the "velstar-test-file-manager-upload.txt" file to the File Manager
    Then the File Manager should list a file named "velstar-test-file-manager-upload.txt"
    When I delete the "velstar-test-file-manager-upload.txt" file from the File Manager
    Then the File Manager should not list a file named "velstar-test-file-manager-upload.txt"


  # Images are the File Manager's main real-world use (product/marketing
  # imagery) - covered as its own scenario with a real image fixture
  # rather than assumed to behave like the plain-text upload above, since
  # CKFinder could plausibly treat image mime-types differently (e.g.
  # thumbnail generation, a separate "Images" resource type). Confirmed
  # live: images go through the exact same Upload control/input[type=file]
  # and land in the same listing, so no image-specific steps were needed -
  # only a real .png fixture.
  Scenario: Uploading an image through the File Manager adds it to the listing, and it can be deleted again
    Given I require a staging admin for this scenario
    And I am navigating the page as a "admin" user
    And I am on the "dashboard" page
    When I open the File Manager
    And I upload the "velstar-test-file-manager-upload.png" file to the File Manager
    Then the File Manager should list a file named "velstar-test-file-manager-upload.png"
    When I delete the "velstar-test-file-manager-upload.png" file from the File Manager
    Then the File Manager should not list a file named "velstar-test-file-manager-upload.png"
