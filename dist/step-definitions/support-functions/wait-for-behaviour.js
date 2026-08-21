"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.waitFor = void 0;
const waitFor = async (predicate, options) => {
  const {
    timeout = 15000,
    wait = 2000
  } = options || {};
  const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));
  const startDate = new Date();
  let lastError;
  while (new Date().getTime() - startDate.getTime() < timeout) {
    // A predicate can THROW rather than return falsy - e.g. page.$()
    // rejecting with "Execution context was destroyed" when a click
    // triggers a real navigation right as this poll fires (confirmed
    // live on Watco's checkout-delivery "accordion continue" step).
    // That's a transient state, not a real failure: treat it the same
    // as a falsy result and keep polling, since the page settling on
    // its next load is exactly the sort of thing this loop exists to
    // wait out. Only fixed to fail loud if it NEVER settles.
    try {
      const result = await predicate();
      if (result) return result;
    } catch (error) {
      lastError = error;
    }
    await sleep(wait);
  }
  if (lastError) {
    throw new Error(`Wait time of ${timeout}ms exceeded (last error: ${lastError instanceof Error ? lastError.message : String(lastError)})`);
  }
  throw new Error(`Wait time of ${timeout}ms exceeded`);
};
exports.waitFor = waitFor;