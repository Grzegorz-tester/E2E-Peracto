export type TestCard = {
    number: string;
    expiryMonth: string;
    expiryYear: string;
    securityCode: string;
};

// CyberSource Unified Checkout sandbox test cards, shared across any
// project using the same payment provider (these are CyberSource's own
// published test values, not tied to a specific merchant/project). Add
// more named cards here as scenarios need them (e.g. a decline card, a
// 3DS-required card) - the step definition just looks one up by name, so
// adding a card never requires touching step-definition code.
export const CYBERSOURCE_TEST_CARDS: Record<string, TestCard> = {
    default: {
        number: "4111111111111111",
        expiryMonth: "12",
        expiryYear: "30",
        securityCode: "123",
    },
    mastercard: {
        number: "5200000000002235",
        expiryMonth: "12",
        expiryYear: "30",
        securityCode: "123",
    },
};

export type VerifoneTestCard = {
    number: string;
    // Verifone's hosted card form (cst.checkout.vficloud.net) takes expiry
    // as a single combined "MM/YY" field, unlike CyberSource's separate
    // month/year selects above - hence a distinct shape here rather than
    // reusing TestCard.
    expiry: string;
    securityCode: string;
};

// Barclays/Verifone test cards. "declined" and "expired" are from
// KOOL-2026-08-17.json's Barclays Verifone Payment Integration suite
// (KOOL-553/554/565/570's failure-path scenarios) - ordinary test numbers,
// no 3DS involved since the payment is expected to fail before that point.
//
// "visa"/"mastercard"/"amex" are NOT the source suite's documented numbers
// (4111111111111111 etc.) - those trigger real 3D Secure via Cardinal
// Commerce on this integration, which stalls indefinitely in headless
// automation after the ThreatMetrix device-fingerprinting step (confirmed
// live: 40+s with no resolution, no error). These three are Cardinal's own
// published "successful frictionless" 3DS test numbers instead - confirmed
// live to complete the full flow (payment-transactions -> lookupThreeDS ->
// complete -> /payment-return/checkout -> /checkout/thank-you) in ~15-20s.
export type GlobalPaymentsTestCard = {
    number: string;
    // GlobalPayments' hosted fields (js.globalpay.com) take expiry as a
    // single "MM / YYYY" field, unlike CyberSource's separate selects.
    expiry: string;
    securityCode: string;
};

// GlobalPayments (js.globalpay.com v4.1.3) hosted card fields - Indespension's
// checkout provider, confirmed live 2026-08-21. This card set is the
// generic Visa test number commonly used across GlobalPayments/Realex
// integrations; note the important caveat below before assuming a failure
// here is this card's fault.
//
// CONFIRMED LIVE (2026-08-21): the hosted fields themselves work correctly
// - all four (card number, expiration, CVV, cardholder name) accept input
// and format/validate normally (Visa is correctly detected from the
// number, no client-side validation errors) regardless of which card is
// used. BUT submitting always currently fails with a backend
// "Payment Error: no gateway available" - this happens before the card is
// even evaluated, so it is NOT a card-specific decline and no test card
// value will produce a different outcome. This looks like Indespension's
// staging environment not having a payment gateway connected/configured
// for this integration, not a test-authoring problem - flag to whoever
// manages this project's staging config rather than treating a red run
// here as a step-definition bug.
export const GLOBALPAYMENTS_TEST_CARDS: Record<string, GlobalPaymentsTestCard> = {
    default: {
        number: "4263970000005262",
        expiry: "12/28",
        securityCode: "123",
    },
};

export const VERIFONE_TEST_CARDS: Record<string, VerifoneTestCard> = {
    visa: {
        number: "4000000000001000",
        expiry: "12/28",
        securityCode: "123",
    },
    mastercard: {
        number: "5200000000001005",
        expiry: "12/28",
        securityCode: "123",
    },
    amex: {
        number: "340000000001007",
        expiry: "12/28",
        securityCode: "1234",
    },
    declined: {
        number: "4000000000000002",
        expiry: "12/28",
        securityCode: "123",
    },
    expired: {
        number: "4111111111111111",
        expiry: "01/20",
        securityCode: "123",
    },
};
