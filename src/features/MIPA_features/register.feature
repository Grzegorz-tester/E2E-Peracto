@MIPA_regression
# Feature: Register page

#   # New coverage. Confirmed live: registration is a "Request an Account"
#   # form (Company Name, First Name, Last Name, Email, Telephone, SEND) -
#   # submitting creates a sales enquiry for Mipa's team to action manually,
#   # not an instant self-serve account. Starts directly on "login" rather
#   # than clicking through from the homepage first, since the homepage's
#   # own "Register" text is just part of the combined "Sign In|Register"
#   # link that already goes to /login - the real, separate "Register" link
#   # only exists on the login page itself, inside the "Create an Online
#   # Account" panel.

#   Scenario: Requesting an account with valid details
#     Given I am on the "login" page
#     When I click on the "Register" element
#     Then I should be redirected to the "register" page
#     When I fill in the "Company Name" input field with "Velstar Test"
#     And I fill in the "First Name" input field with "Velstar"
#     And I fill in the "Last Name" input field with "Test"
#     And I fill in the "Register email" input field with a unique guest email
#     And I fill in the "Register phone" input field with "07377777777"
#     # The SEND button's disabled state re-validates asynchronously after
#     # the last field is filled - confirmed live, clicking immediately
#     # (before it flips to enabled) silently no-ops since a disabled
#     # button doesn't fire its click handler at all.
#     Then the "SEND" should be enabled
#     # Uses the retrying click variant - confirmed live, this submit
#     # occasionally no-ops the same way the PLP "View Product" click does
#     # (see products.feature): the click itself succeeds, but the site's
#     # own request/response cycle silently fails to show the toast, with
#     # nothing for a plain click to catch.
#     When I click on the "SEND" button, retrying until the "request success message" is displayed
