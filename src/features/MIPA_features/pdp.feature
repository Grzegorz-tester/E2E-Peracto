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


  Scenario: PDP - Create a wishlist and add a product to it
    Given I am navigating the page as a "logged in" user
    And I am on the "test-product" page
    When I click on the "Add to List" button
    Then the "added to list modal" should be displayed


  Scenario: PDP - Guest user cannot see prices and can submit an enquiry
    Given I am navigating the page as a "guest" user
    And I am on the "test-product" page
    Then the "guest sign in prompt" should be displayed
    And the "Add to Enquiry" should be displayed
