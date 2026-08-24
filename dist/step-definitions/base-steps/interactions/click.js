"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _htmlBehaviour = require("../../support-functions/html-behaviour");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
var _navigationBehaviour = require("../../support-functions/navigation-behaviour");
// page.click() (via clickElement) already auto-waits for the element to
// become visible/actionable, so an extra page.waitForSelector before it is
// pure duplication, not extra safety - it just burns time twice. Each
// explicit timeout below is chosen to leave headroom under Cucumber's own
// step timeout (SCRIPT_TIMEOUT, 20000ms), so a slow page fails with a clear
// Playwright error instead of racing Cucumber's generic "function timed out".
//
// force: true skips only Playwright's "receives events"/"stable" checks -
// it still requires the element to be attached and visible first, so a
// genuinely-missing element still fails loudly. Added after the "Find a
// Retailer" map widget's live re-centering intermittently failed the
// "receives events" check on a result link that was, confirmed via direct
// inspection, perfectly clickable (elementFromPoint resolved to its own
// child text, not an overlapping element).
(0, _cucumber.When)(/^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await new Promise(resolve => setTimeout(resolve, 300));
  await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
    timeout: 15000,
    force: true
  });
});
(0, _cucumber.When)(/^I slowly click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 10000
  });
  await new Promise(resolve => setTimeout(resolve, 6000));
  await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
    timeout: 2000,
    force: true
  });
});

// The inverse problem from force's own justification above: force clicks
// blindly at the target's bounding-box CENTER, which is wrong for a large
// element whose actual clickable content doesn't fill that box evenly -
// confirmed live on Watco's marketing-agreement <label>, which wraps a
// multi-line paragraph of explanatory text plus embedded links. A plain,
// non-forced click (Playwright's own actionability checks intact) toggled
// the checkbox correctly; the identical click with force: true landed on
// dead space within the label's box and silently did nothing - no error,
// just never checked. Reusable for any similarly oversized clickable
// wrapper (a label, a card, a banner) where force's own center-point
// assumption breaks down, without touching the force default every other
// call site here relies on.
(0, _cucumber.When)(/^I click precisely on the "([^"]*)" (?:button|link|icon|element|dropdown|tab)$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
    timeout: 15000
  });
});

// The non-forced ("precisely") counterpart to "if present" above - for a
// list's first-row link on a project/tenant where that particular section
// is genuinely empty (e.g. Indespension's Redirects has no rows right now,
// while KOOL's does) rather than one specific element sometimes rendering.
// A no-op here (nothing to click) is the CORRECT outcome, not a failure -
// pair with "the 'X' should not be displayed" afterwards to confirm nothing
// navigated when the list was empty.
(0, _cucumber.When)(/^I click precisely on the "([^"]*)" (?:button|link|icon|element|dropdown|tab) if present$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const appeared = await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 8000
  }).then(() => true).catch(() => false);
  if (appeared) {
    await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
      timeout: 15000
    });
  }
});

// Combines "precisely" (above - no force, since force breaks this exact
// class of large-wrapper click) with a retry against an overlay that can
// intercept the click and REAPPEAR after being dismissed once - confirmed
// live on Watco (PL market): a single "dismiss the cookie preference
// centre if present, then click" still failed, because the overlay
// re-rendered in the gap between the dismiss and the click. Re-dismisses
// before every retry attempt, not just the first, mirroring the source
// Playwright suite's own retry-loop pattern for this exact site quirk
// (WatcoPDPage.addToBasket's stray-preference-centre handling).
(0, _cucumber.When)(/^I click precisely on the "([^"]*)" (?:button|link|icon|element|dropdown|tab), dismissing the "([^"]*)" if it interferes$/, {
  timeout: 45000
}, async function (elementKey, dismissButtonKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const dismissButtonIdentifier = (0, _webElementHelper.getElementLocator)(page, dismissButtonKey, globalConfig);
  let lastError;
  for (let attempt = 0; attempt < 5; attempt++) {
    const dismissButtonVisible = await page.locator(dismissButtonIdentifier).isVisible().catch(() => false);
    if (dismissButtonVisible) {
      await page.locator(dismissButtonIdentifier).click({
        force: true
      }).catch(() => {});
      await page.locator(dismissButtonIdentifier).waitFor({
        state: "hidden",
        timeout: 4000
      }).catch(() => {});
    }
    try {
      await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
        timeout: 8000
      });
      return;
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
});

// Force variant of the above, for an ordinary small button/link rather
// than an oversized wrapper - force is the right default here (see the
// plain "I click on the ... button" step's own reasoning at the top of
// this file), but still needs the dismiss-and-retry loop: an overlay
// sitting on top of the target still wins the browser's native hit-
// testing during event dispatch even with force: true - force only skips
// PLAYWRIGHT's own pre-click checks, not the browser deciding which
// element actually receives the click at that screen position. Confirmed
// live: Watco's "Register" submit button, several fields into the
// registration form, intermittently swallowed a forced click the exact
// same way the marketing-agreement label did - consistent with the
// preference-centre overlay reappearing mid-form, not a reCAPTCHA-timing
// issue as first suspected.
(0, _cucumber.When)(/^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab), dismissing the "([^"]*)" if it interferes$/, {
  timeout: 45000
}, async function (elementKey, dismissButtonKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const dismissButtonIdentifier = (0, _webElementHelper.getElementLocator)(page, dismissButtonKey, globalConfig);
  let lastError;
  for (let attempt = 0; attempt < 5; attempt++) {
    const dismissButtonVisible = await page.locator(dismissButtonIdentifier).isVisible().catch(() => false);
    if (dismissButtonVisible) {
      await page.locator(dismissButtonIdentifier).click({
        force: true
      }).catch(() => {});
      await page.locator(dismissButtonIdentifier).waitFor({
        state: "hidden",
        timeout: 4000
      }).catch(() => {});
    }
    try {
      await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
        timeout: 8000,
        force: true
      });
      return;
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
});

// A DIFFERENT overlay-interference shape from the two steps above: those
// assume a visible dismiss BUTTON to click. Confirmed live on Watco's
// logged-in checkout - the OneTrust preference-centre's dark backdrop
// (".onetrust-pc-dark-filter") can persist in the DOM and keep
// intercepting pointer events on the real target even after the panel
// itself has already closed, at a point where its own close button
// (`#close-pc-btn-handler`) is no longer visible - so there is nothing to
// click to dismiss it "properly". Both plain click() and force:true fail
// identically here, since force only skips Playwright's own actionability
// checks, not the browser's native hit-testing that still resolves to the
// backdrop. Removing the stray element directly via page.evaluate is the
// only thing that actually unblocks the click - verified live: the target
// button did nothing until the backdrop was removed, then worked
// immediately afterward.
(0, _cucumber.When)(/^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab), removing the "([^"]*)" overlay if it interferes$/, {
  timeout: 45000
}, async function (elementKey, overlayKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const overlayIdentifier = (0, _webElementHelper.getElementLocator)(page, overlayKey, globalConfig);
  let lastError;
  for (let attempt = 0; attempt < 5; attempt++) {
    const overlayVisible = await page.locator(overlayIdentifier).isVisible().catch(() => false);
    if (overlayVisible) {
      await page.evaluate(sel => {
        document.querySelectorAll(sel).forEach(el => el.remove());
      }, overlayIdentifier).catch(() => {});
    }
    try {
      await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
        timeout: 8000
      });
      return;
    } catch (error) {
      lastError = error;
    }
  }
  throw lastError;
});

// For a link/button whose own click handler is confirmed live to
// sometimes not be bound yet the instant it becomes interactable (a
// lazy-binding quirk, not a missing-element problem) - e.g. Watco's
// "Enter address manually" link, whose first click can do nothing.
// Clicks once, checks whether the expected REVEALED element appeared
// within a short window, and clicks again (once) only if it didn't -
// deliberately not force, and deliberately not an unconditional double-
// click, since this link TOGGLES its target open/closed: blindly
// clicking twice would reopen-then-close it right back, undoing the
// very thing this step exists to make reliable.
(0, _cucumber.When)(/^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab), retrying until the "([^"]*)" appears$/, async function (elementKey, revealedElementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const revealedIdentifier = (0, _webElementHelper.getElementLocator)(page, revealedElementKey, globalConfig);
  await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
    timeout: 15000
  });
  const appeared = await page.waitForSelector(revealedIdentifier, {
    state: "visible",
    timeout: 5000
  }).then(() => true).catch(() => false);
  if (!appeared) {
    await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
      timeout: 15000
    });
    await page.waitForSelector(revealedIdentifier, {
      state: "visible",
      timeout: 15000
    });
  }
});

// For an element that only sometimes appears (an optional interstitial, a
// modal shown only on a fresh page load, etc.) - clicks it if it shows up
// within a short window, otherwise moves on without failing the scenario.
(0, _cucumber.When)(/^I click on the "([^"]*)" (?:button|link|icon|element|dropdown|tab) if present$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const appeared = await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 8000
  }).then(() => true).catch(() => false);
  if (appeared) {
    // Confirms the click actually dismissed it, rather than firing once
    // and hoping - a click that doesn't register (or an element that
    // reappears, e.g. a cookie-consent banner re-triggered by a later
    // async request on the same page, confirmed live on one project)
    // would otherwise silently leave it blocking every subsequent
    // interaction in the scenario. Retries the click itself, not just
    // the wait, for exactly that reappearing case.
    await (0, _waitForBehaviour.waitFor)(async () => {
      await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
        force: true
      });
      return page.waitForSelector(elementIdentifier, {
        state: "hidden",
        timeout: 4000
      }).then(() => true).catch(() => false);
    }, {
      timeout: 20000,
      wait: 500
    });
  }
});

// For a listing whose items are individually unpredictable (e.g. a "What's
// On" event list where some events are sold out/expired and simply don't
// render the section this scenario needs), rather than a fixed "1st item"
// click that's only as reliable as whichever item happens to be first
// right now. Navigates to each item's own href in turn (not a click, so a
// dead end doesn't need a "go back") until confirmKey appears on the
// destination, or throws if none of them ever show it. Reusable by any
// project with a similarly unpredictable listing->detail relationship.
(0, _cucumber.When)(/^I open the first "([^"]*)" element whose "([^"]*)" is present on the destination page$/, {
  timeout: 45000
}, async function (listItemKey, confirmKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const listSelector = (0, _webElementHelper.getElementLocator)(page, listItemKey, globalConfig);

  // The calling "I am on the ... page" step only waits for
  // domcontentloaded, not for a client-fetched listing (e.g. What's On's
  // events) to actually render - without this wait, $$eval below can run
  // before a single item exists yet and collect zero hrefs.
  await page.waitForSelector(listSelector, {
    state: "attached",
    timeout: 15000
  });
  const hrefs = await page.$$eval(listSelector, els => els.map(el => el.getAttribute("href")).filter(href => !!href));
  const uniqueHrefs = [...new Set(hrefs)];
  for (const href of uniqueHrefs) {
    const url = new URL(href, page.url()).toString();
    await page.goto(url, {
      waitUntil: "domcontentloaded",
      timeout: 30000
    });
    const confirmSelector = (0, _webElementHelper.getElementLocator)(page, confirmKey, globalConfig);
    const found = await page.waitForSelector(confirmSelector, {
      state: "attached",
      timeout: 8000
    }).then(() => true).catch(() => false);
    if (found) return;
  }
  throw new Error(`None of the "${listItemKey}" links led to a page where "${confirmKey}" appears.`);
});
(0, _cucumber.When)(/^I click on the "(\d+(?:st|nd|rd|th))" "([^"]+)" (?:button|link|element)$/, async function (elementPosition, elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);

  // Extract number from "2nd", "3rd", "10th", etc.
  const index = Number(elementPosition.match(/\d+/)?.[0]) - 1;
  await page.waitForSelector(elementIdentifier, {
    state: "visible",
    timeout: 15000
  });
  await (0, _htmlBehaviour.clickElementAtIndex)(page, elementIdentifier, index, {
    force: true
  });
});

// For an overlay that isn't just present once (the "removing the X
// overlay if it interferes" click variants already handle that) but gets
// RE-INSERTED on every page load / re-render throughout a scenario - a
// one-shot removal right before a single click can still lose a race
// against it reappearing, confirmed live (PizzaExpressLive's undismissable
// "outdated browser" banner): removing it, then clicking, still
// intermittently got intercepted, since the removal and the click are two
// separate steps with a gap between them for it to come back. addInitScript
// runs on every subsequent navigation on this page for the rest of the
// scenario (unlike a one-off page.evaluate removal), and the MutationObserver
// catches a re-render on the CURRENT document too, not just a fresh
// navigation - so call this once, early in a scenario, rather than
// per-click. Reusable by any project with a similar persistent nuisance
// element (a chat widget, a survey prompt) that keeps re-inserting itself.
(0, _cucumber.Given)(/^I permanently remove the "([^"]*)" overlay for this scenario$/, async function (overlayKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const overlaySelector = (0, _webElementHelper.getElementLocator)(page, overlayKey, globalConfig);
  const stripAndObserve = selector => {
    const strip = () => document.querySelectorAll(selector).forEach(el => el.remove());
    strip();
    new MutationObserver(strip).observe(document.documentElement, {
      childList: true,
      subtree: true
    });
  };

  // addInitScript only attaches its own observer to documents created by
  // a FUTURE navigation - it does nothing for the document already
  // loaded right now, so that one needs the exact same observer wired up
  // directly via evaluate() too, not just a one-off removal (confirmed
  // live: a one-off strip() here still occasionally lost the race
  // against the banner reinserting itself before the very next click).
  await page.addInitScript(stripAndObserve, overlaySelector);
  await page.evaluate(stripAndObserve, overlaySelector).catch(() => {});
});

// For a set of otherwise-identical options where some are legitimately
// disabled (a fully-booked appointment slot, a sold-out size) and which
// ONE is available can change between runs - confirmed live need on
// Indespension's towbar fitting-date picker: a hardcoded specific
// day/time slot kept failing on repeat runs because that exact slot
// becomes unavailable after being booked once (this is a REAL booking,
// not a mock), so a fixed testid is a one-shot selector, not a reusable
// one. The mapping key should resolve to ALL the candidate elements (e.g.
// a wildcard/shared-prefix selector matching every slot button), not a
// single specific one - this step then picks whichever of them is
// actually enabled right now. Reusable by any project with a similar
// "several options, availability varies" shape.
(0, _cucumber.When)(/^I click on the first enabled "([^"]*)" (?:button|link|element)$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const candidates = page.locator(elementIdentifier);
  await candidates.first().waitFor({
    state: "visible",
    timeout: 15000
  });
  const count = await candidates.count();
  for (let i = 0; i < count; i++) {
    const candidate = candidates.nth(i);
    if (await candidate.isEnabled()) {
      await candidate.click();
      return;
    }
  }
  throw new Error(`None of the ${count} "${elementKey}" candidates are currently enabled.`);
});

// For a click-triggered client-side route change that silently no-ops
// sometimes - confirmed live on MIPA's PLP "View Product" links: the
// click itself always succeeds (Playwright never sees an error), but the
// site's own Next.js router occasionally throws "TypeError: Failed to
// fetch" internally fetching the route's data and just stays on the same
// page, with no visible error and nothing for a plain click step to
// catch. Re-clicking when that happens (rather than failing the whole
// scenario) matches the same "retry the action itself, not just the
// wait" pattern the checkbox retry step above already uses. Reusable by
// any project with a similarly flaky client-side navigation.
(0, _cucumber.When)(/^I click on the "([^"]*)" (?:button|link|element), retrying until redirected to the "([^"]*)" page$/, async function (elementKey, pageId) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    if ((0, _navigationBehaviour.currentPathMatchesPageId)(page, pageId, globalConfig)) return true;
    await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
      timeout: 15000,
      force: true
    });
    await page.waitForTimeout(1000);
    return (0, _navigationBehaviour.currentPathMatchesPageId)(page, pageId, globalConfig);
  }, {
    timeout: 20000,
    wait: 500
  });
});

// Same flaky-click problem as above, but for a click whose expected
// outcome is a resulting element appearing (a toast, a modal) rather than
// a page redirect - confirmed live on MIPA's Register form: the SEND
// button click occasionally no-ops the same way (no error, nothing
// happens) with no navigation involved to detect it by.
(0, _cucumber.When)(/^I click on the "([^"]*)" (?:button|link|element), retrying until the "([^"]*)" is displayed$/, async function (elementKey, targetKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  const targetIdentifier = (0, _webElementHelper.getElementLocator)(page, targetKey, globalConfig);
  await (0, _waitForBehaviour.waitFor)(async () => {
    if ((await page.$(targetIdentifier)) !== null) return true;
    await (0, _htmlBehaviour.clickElement)(page, elementIdentifier, {
      timeout: 15000,
      force: true
    });
    await page.waitForTimeout(1000);
    return (await page.$(targetIdentifier)) !== null;
  }, {
    timeout: 20000,
    wait: 500
  });
});