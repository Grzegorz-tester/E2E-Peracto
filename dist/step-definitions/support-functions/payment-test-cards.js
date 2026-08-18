"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.VERIFONE_TEST_CARDS = exports.CYBERSOURCE_TEST_CARDS = void 0;
// CyberSource Unified Checkout sandbox test cards, shared across any
// project using the same payment provider (these are CyberSource's own
// published test values, not tied to a specific merchant/project). Add
// more named cards here as scenarios need them (e.g. a decline card, a
// 3DS-required card) - the step definition just looks one up by name, so
// adding a card never requires touching step-definition code.
const CYBERSOURCE_TEST_CARDS = exports.CYBERSOURCE_TEST_CARDS = {
  default: {
    number: "4111111111111111",
    expiryMonth: "12",
    expiryYear: "30",
    securityCode: "123"
  },
  mastercard: {
    number: "5200000000002235",
    expiryMonth: "12",
    expiryYear: "30",
    securityCode: "123"
  }
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
const VERIFONE_TEST_CARDS = exports.VERIFONE_TEST_CARDS = {
  visa: {
    number: "4000000000001000",
    expiry: "12/28",
    securityCode: "123"
  },
  mastercard: {
    number: "5200000000001005",
    expiry: "12/28",
    securityCode: "123"
  },
  amex: {
    number: "340000000001007",
    expiry: "12/28",
    securityCode: "1234"
  },
  declined: {
    number: "4000000000000002",
    expiry: "12/28",
    securityCode: "123"
  },
  expired: {
    number: "4111111111111111",
    expiry: "01/20",
    securityCode: "123"
  }
};