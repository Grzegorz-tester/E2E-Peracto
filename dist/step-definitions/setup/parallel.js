"use strict";

var _cucumber = require("@cucumber/cucumber");
var _loadGlobalConfig = require("../../env/loadGlobalConfig");
// Decides which scenarios may run side by side when a project's env file sets
// PARALLEL above 1 (no effect at PARALLEL=1). Runs in cucumber's coordinator
// process, before each scenario is handed to a worker.
//
// Every project's logged-in scenarios share ONE real test account per user
// type, and with it one server-side basket, address book, wishlist and so on.
// Two scenarios on the same account at once trample each other's state (one
// empties the basket while the other asserts a quantity) and produce failures
// that look exactly like site bugs - e.g. MIPA's "quantity picker revert"
// that turned out to be contention from concurrent runs on the same account.
// So: scenarios logging in as the same account never overlap; guest
// scenarios (own browser context, own basket) and scenarios on different
// accounts run freely in parallel.
//
// Keyed by the resolved email rather than the user type, because two user
// types can resolve to the same real login (KOOL's "logged in" and another
// type once both pointed at the same account).
//
// A scenario that touches shared state WITHOUT going through the
// `I am navigating the page as a "X" user` step (logging in by hand via the
// Sign In form, editing global admin settings, etc.) can be tagged @serial:
// it then only runs with nothing else in flight.
const LOGIN_STEP = /^I am navigating the page as an? "([^"]+)" user$/;
let emailsByUserType;
const accountFor = userType => {
  if (!emailsByUserType) {
    emailsByUserType = {};
    try {
      for (const [type, user] of Object.entries((0, _loadGlobalConfig.loadGlobalConfig)().usersConfig)) {
        if (user?.email) emailsByUserType[type] = user.email.toLowerCase();
      }
    } catch {
      // Config not loadable here - fall back to keying by user type alone.
    }
  }
  const type = userType.trim().toLowerCase();
  return emailsByUserType[type] ?? `user-type:${type}`;
};
const isSerial = pickle => pickle.tags.some(tag => tag.name === '@serial');
const accountsUsedBy = pickle => pickle.steps.map(step => LOGIN_STEP.exec(step.text)?.[1]).filter(type => !!type && type.trim().toLowerCase() !== 'guest').map(accountFor);
(0, _cucumber.setParallelCanAssign)((candidate, inProgress) => {
  if (inProgress.length === 0) return true;
  if (isSerial(candidate) || inProgress.some(isSerial)) return false;
  const accounts = accountsUsedBy(candidate);
  if (accounts.length === 0) return true;
  return inProgress.every(running => !accountsUsedBy(running).some(account => accounts.includes(account)));
});