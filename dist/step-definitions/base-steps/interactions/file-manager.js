"use strict";

var _cucumber = require("@cucumber/cucumber");
var _path = _interopRequireDefault(require("path"));
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
// The File Manager nav item (by the account name in Peracto Admin's left
// nav) opens a classic CKFinder file browser. An earlier live check found
// it absent on Carbon Admin and concluded it wasn't part of the common
// Peracto Admin boilerplate - that finding turned out to be stale:
// re-verified live 2026-09-10 and found it genuinely present and working
// on Carbon Admin too (as well as MIPA and Andy Thornton), so the feature
// file using these steps now lives in the shared Carbon_admin suite, not
// a project-specific path.
//
// CKFinder renders inside a real <iframe> - Playwright can drive it via
// frameLocator - but that iframe's own src attribute stays empty the
// whole time (confirmed live: CKFinder writes its UI into the frame's
// document via JS rather than ever navigating it to a URL). Every step
// below goes through page.frameLocator("iframe") for that reason; none of
// this repo's generic mapping-driven steps can reach inside an iframe, so
// only the nav button that OPENS the widget (still on the real page) goes
// through the normal getElementLocator/mapping route.
(0, _cucumber.When)(/^I open the File Manager$/, async function () {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, "File Manager", globalConfig);
  await page.click(elementIdentifier);

  // Toolbar readiness is the real "it's usable" signal - CKFinder's own
  // async Init/GetFolders/GetFiles connector calls (confirmed live) mean
  // the iframe exists well before its UI is actually interactive.
  await page.frameLocator("iframe").locator("[data-ckf-name='Upload']").waitFor({
    state: "visible",
    timeout: 15000
  });
});

// Fixture files live once under src/features/fixtures/, same convention as
// the page-level "I upload the ... file to the ... input" step
// (file-upload.ts) - reusable test data rather than duplicated per project.
(0, _cucumber.When)(/^I upload the "([^"]*)" file to the File Manager$/, async function (fixtureFile) {
  const {
    screen: {
      page
    }
  } = this;
  const filePath = _path.default.join(process.cwd(), "src/features/fixtures", fixtureFile);
  const fl = page.frameLocator("iframe");
  await fl.locator("[data-ckf-name='Upload']").click();
  const fileInput = fl.locator("input[type='file']");
  await fileInput.waitFor({
    state: "attached",
    timeout: 10000
  });
  await fileInput.setInputFiles(filePath);

  // The real completion signal is the uploaded file's own name appearing
  // in the listing, not CKFinder's "Upload finished!" toast text -
  // confirmed live that wording is exactly what a future re-skin or
  // translation would change first, and it disappears on its own shortly
  // after, unlike the listing entry.
  const fileName = _path.default.basename(fixtureFile);
  await fl.getByText(fileName, {
    exact: true
  }).first().waitFor({
    state: "visible",
    timeout: 15000
  });

  // Close the upload panel so later steps (selecting a row, deleting)
  // aren't blocked by it - confirmed live it stays open until dismissed.
  // Best-effort and picks the first VISIBLE match rather than just the
  // first match: confirmed live there can be more than one "Close" text
  // node in this widget with only one of them actually visible/
  // clickable, and dismissing this panel isn't itself part of what any
  // scenario asserts on, so a failure here shouldn't fail the whole
  // upload.
  const closeCandidates = fl.locator("[data-ckf-name='Close']").or(fl.getByText("Close", {
    exact: true
  }));
  const closeCandidateCount = await closeCandidates.count();
  for (let i = 0; i < closeCandidateCount; i++) {
    const candidate = closeCandidates.nth(i);
    if (await candidate.isVisible().catch(() => false)) {
      await candidate.click({
        timeout: 5000
      }).catch(() => {});
      break;
    }
  }
});
(0, _cucumber.Then)(/^the File Manager should\s*(not)?\s*list a file named "([^"]*)"$/, async function (negate, fileName) {
  const {
    screen: {
      page
    }
  } = this;
  const fl = page.frameLocator("iframe");
  await (0, _waitForBehaviour.waitFor)(async () => {
    const count = await fl.getByText(fileName, {
      exact: true
    }).count();
    return count > 0 === !negate;
  }, {
    expected: `File Manager to ${negate ? "not " : ""}list a file named "${fileName}"`
  });
});

// Generic counterpart to "I open the File Manager" - for the SAME
// CKFinder widget opened from a form field's own "Browse" button (its
// real-world use as an image picker) rather than the standalone top-nav
// File Manager button. Parameterised on the trigger's mapping key since
// this shape is reusable anywhere a form embeds one of these (confirmed
// live at least on Category's "Main Image"/"Secondary Image" fields and
// a Page's "Content Image" field) - not fixed to one project/field.
(0, _cucumber.When)(/^I click on the "([^"]*)" button, opening an image picker$/, async function (elementKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const elementIdentifier = (0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig);
  await page.click(elementIdentifier);
  await page.frameLocator("iframe").locator("[data-ckf-name='Upload']").waitFor({
    state: "visible",
    timeout: 15000
  });
});

// Selects an existing file already in the File Manager and confirms the
// selection via CKFinder's own "Choose" toolbar button (appears once a
// file is selected - confirmed live distinct from "DeleteFiles"/etc.,
// the button this picker mode specifically adds to hand the selection
// back to whatever host field opened it).
(0, _cucumber.When)(/^I choose the "([^"]*)" file in the image picker$/, async function (fileName) {
  const {
    screen: {
      page
    }
  } = this;
  const fl = page.frameLocator("iframe");
  await fl.getByText(fileName, {
    exact: true
  }).first().click();
  await fl.locator("[data-ckf-name='Choose']").click();
});

// Confirmed live: scoping the confirm click to the dialog's own
// role="dialog" container matters - a page-wide text/button locator for
// "OK" can resolve to the still-open, overlay-blocked toolbar Delete
// button instead of the actual confirm button, which then hangs retrying
// against an element a CKFinder popup screen is intercepting.
(0, _cucumber.When)(/^I delete the "([^"]*)" file from the File Manager$/, async function (fileName) {
  const {
    screen: {
      page
    }
  } = this;
  const fl = page.frameLocator("iframe");
  await fl.getByText(fileName, {
    exact: true
  }).first().click();
  await fl.locator("[data-ckf-name='DeleteFiles']").click();
  const dialog = fl.locator("[role='dialog']");
  await dialog.waitFor({
    state: "visible",
    timeout: 10000
  });
  await dialog.locator("button", {
    hasText: "OK"
  }).click();
});