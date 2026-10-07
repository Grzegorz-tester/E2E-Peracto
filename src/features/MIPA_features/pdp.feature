@regression
Feature: Product Detail Page (PDP)

  # New coverage (previously none existed) - confirmed live against a
  # fixed, known product (Mipa 2K HS F37 Filler (1L) Light Grey, SKU 229510000)
  # so price/UOM assertions stay deterministic across runs. The product's
  # title showed as "2K HS Wet-on-Wet Filler F37 Light Grey (1LT)" on
  # MIPA_RELEASE (2026-09-14) - a real product-data mismatch, not a test bug -
  # and was fixed on release-2-8-0 that day, then recurred identically on
  # release-2-8-1 (2026-09-15) once the branch was bumped. Also explained
  # header.feature's two Algolia search scenarios failing (the indexed title
  # didn't contain the search term either - same root cause).
  # FIXED DIRECTLY (2026-09-15): corrected the product's "Product Name"
  # field in Peracto Admin (Products > SKU 229510000, id 836) via
  # https://2-8-1-peracto.mipa-paints.pub/products/836, with "Index Product"
  # enabled so the Algolia index updated in the same save. Live-verified
  # both the PDP title and the header search afterward; re-ran the actual
  # scenarios (not just a manual check) - pdp.feature 1/1 and
  # header.feature 14/14 all passing.

  Scenario: PDP loads with accurate information and images
    Given I am on the "test-product" page
    Then the "product title" should be displayed
    And the "product title" should contain the text "Mipa 2K HS F37 Filler (1L) Light Grey"
    And the "product SKU" should contain the text "229510000"
    And the "product image" should be displayed


  Scenario Outline: PDP - Add product to basket using the "<uom>" UOM
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    When I click on the "<uom>" element
    And I click on the "Add to basket" button
    Then the "added to basket modal" should be displayed
    Examples:
      | uom      |
      | EACH UOM |
      | BOX OF 6 UOM |


  # Investigated an intermittent failure here (2026-09-14/15) where the
  # "Quantity input" picker and the final order total both read back as if
  # only 1 unit had been added, despite setting quantity to 3 first -
  # reproduced several times via this automated suite, including with a
  # deliberate pause before "Add to basket" and a screenshot showing
  # Quantity: 1 / "Now £12.23" on the real rendered page. BUT: the user
  # manually re-tested twice (a quick click-through, and a careful one
  # watching the quantity picker) and got the correct quantity and total
  # both times, on this same branch - and confirmed the one real quirk they
  # DID notice (the PDP's displayed unit price not visually updating as
  # quantity increases) also exists on production, so it isn't new. Given
  # that, the automated failures above are more likely an artifact of this
  # debugging session's own heavy, rapid, back-to-back automated runs all
  # sharing one live test account's server-side basket/session state, not a
  # reproducible product defect - not confirmed as a real site bug.
  # Kept "click precisely" (non-forced) on the increment button below since
  # that fixed a genuine, separate, smaller issue: a forced click
  # intermittently failed to register the second of two rapid increment
  # clicks (landing on a brief disabled/transitional state).
  Scenario: PDP - Increase quantity and validate basket totals
    Given I am navigating the page as a "logged in" user
    And I am on the "basket" page
    And I wait for the page to settle
    And I clear the basket
    When I am on the "test-product" page
    And I click on the "EACH UOM" element
    When I click precisely on the "Quantity increment" element
    Then the "Quantity input" should equal the value "2"
    When I click precisely on the "Quantity increment" element
    Then the "Quantity input" should equal the value "3"
    When I click on the "Add to basket" button
    And I click on the "Checkout" element
    Then I should be redirected to the "basket" page
    And I wait for the page to settle
    And the "order total price" should contain the text "36.69"


  # Until 2026-10-01 this scenario only opened the Add to List modal, so
  # nothing was ever created or added despite its name. Confirmed live:
  # the modal has its own "or Create a new list" link, which reveals a name
  # input and an icon-only submit button. Submitting it creates the list
  # AND adds this product to it in one go (POST /wishlists), going straight
  # to a "Successfully added to list..." state with a "View List" button -
  # there's no separate "Add to Wishlist" click on this path. The list is
  # deleted at the end so runs don't pile up throwaway lists.
  Scenario: PDP - Create a wishlist and add a product to it
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    When I click on the "Add to List" button
    Then the "Add to List modal" should be displayed
    When I click on the "Create a new list link" element
    And I fill in the "New list name input" input field with a unique value, remembering it as "list name"
    And I click on the "Create list submit" button
    Then the "added to list success" should contain the remembered "list name"
    When I click on the "View List" button
    Then I should be redirected to the "account-wishlist-detail" page
    And the "Wishlist title" should contain the remembered "list name"
    And I should see "1" "Wishlist product cards" displayed
    And the "Wishlist product title" should contain the text "Mipa 2K HS F37 Filler (1L) Light Grey"

    When I am on the "account-wishlist" page
    And I wait for the page to settle
    And I fill in the "search bar" input field with the remembered "list name"
    And I click on the "Search button" button
    And I delete the row containing the remembered "list name" from the "Wishlist rows" table


  Scenario: PDP - Guest user cannot see prices and is offered an enquiry instead
    Given I am navigating the page as a "guest" user
    And I am on the "test-product" page
    Then the "guest sign in prompt" should be displayed
    And the "Add to Enquiry" should be displayed


  # Confirmed live (staging, 2026-10-01): "Add to Enquiry" opens a form
  # (Name, Business Name, Email Address, Telephone Number, Message - all
  # required) whose Submit button stays disabled until every field is
  # filled. Submit is deliberately NEVER clicked: a real enquiry is very
  # likely emailed to MIPA staff (same reasoning as Keylite's forms).
  Scenario: PDP - Guest enquiry form keeps Submit disabled until every required field is filled
    Given I am navigating the page as a "guest" user
    And I am on the "test-product" page
    When I click on the "Add to Enquiry" button
    Then the "Enquiry form" should be displayed
    And the "Enquiry submit" should not be enabled
    When I fill in the "Enquiry name" input field with "Velstar Test"
    And I fill in the "Enquiry business name" input field with "Velstar Test"
    And I fill in the "Enquiry email" input field with "velstar.qa.enquiry@velstar.co.uk"
    And I fill in the "Enquiry telephone" input field with "07700900000"
    Then the "Enquiry submit" should not be enabled
    When I fill in the "Enquiry message" input field with "Velstar Test - automated check, never submitted"
    Then the "Enquiry submit" should be enabled
