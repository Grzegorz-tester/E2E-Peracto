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
