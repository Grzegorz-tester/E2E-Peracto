"use strict";

var _cucumber = require("@cucumber/cucumber");
var _webElementHelper = require("../../support-functions/web-element-helper");
var _waitForBehaviour = require("../../support-functions/wait-for-behaviour");
// A unique, clearly-ours name with a caller-chosen prefix, so a matching
// prefix-based cleanup (below) can find exactly what this suite created and
// nothing else. Confirmed need on Andy Thornton (2026-09-30): the shared test
// account holds other people's moodboards, so test data needs an unmistakable
// prefix rather than a generic "qa-<timestamp>".
(0, _cucumber.When)(/^I fill in the "([^"]*)" input field with a unique value starting with "([^"]*)", remembering it as "([^"]*)"$/, async function (elementKey, prefix, variableName) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const value = `${prefix} ${Date.now()}`;
  await page.fill((0, _webElementHelper.getElementLocator)(page, elementKey, globalConfig), value);
  this.globalVariables[variableName] = value;
});

// Sweeps up rows a previous, failed run left behind (a scenario that dies
// between "create" and "delete" otherwise leaves its data on a shared
// account forever). Only deletes rows whose name cell STARTS WITH the prefix,
// re-reading the list after every delete. All four are mapping keys: the row,
// the row's name cell, the row's delete control, and the confirmation button.
(0, _cucumber.Given)(/^I delete every "([^"]*)" whose "([^"]*)" starts with "([^"]*)", using the "([^"]*)" and "([^"]*)"$/, {
  timeout: 120000
}, async function (rowKey, nameKey, prefix, deleteKey, confirmKey) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;
  const rowSelector = (0, _webElementHelper.getElementLocator)(page, rowKey, globalConfig);
  const nameSelector = (0, _webElementHelper.getElementLocator)(page, nameKey, globalConfig);
  const deleteSelector = (0, _webElementHelper.getElementLocator)(page, deleteKey, globalConfig);
  const confirmSelector = (0, _webElementHelper.getElementLocator)(page, confirmKey, globalConfig);
  const matchingRows = async () => {
    const rows = page.locator(rowSelector);
    const count = await rows.count();
    const matches = [];
    for (let i = 0; i < count; i++) {
      const name = ((await rows.nth(i).locator(nameSelector).first().textContent()) ?? "").trim();
      if (name.startsWith(prefix)) matches.push(name);
    }
    return matches;
  };
  for (let attempt = 0; attempt < 20; attempt++) {
    const [name] = await matchingRows();
    if (!name) return;
    const row = page.locator(rowSelector).filter({
      has: page.locator(nameSelector, {
        hasText: name
      })
    }).first();
    // Retry the delete click until its confirmation shows: straight
    // after a page load the icon can render before it's hydrated, and
    // an early click silently does nothing (confirmed live on Andy
    // Thornton's moodboards list, 2026-09-30). The confirm button can
    // also exist more than once in the DOM, so click the visible one.
    const visibleConfirm = async () => {
      const candidates = page.locator(confirmSelector);
      for (let i = 0; i < (await candidates.count()); i++) {
        if (await candidates.nth(i).isVisible()) return candidates.nth(i);
      }
      return null;
    };
    let confirm = null;
    for (let click = 0; click < 4 && !confirm; click++) {
      await row.locator(deleteSelector).first().click();
      const deadline = Date.now() + 3000;
      while (Date.now() < deadline && !(confirm = await visibleConfirm())) {
        await page.waitForTimeout(250);
      }
    }
    if (!confirm) throw new Error(`Clicking "${deleteKey}" never showed a visible "${confirmKey}" (${confirmSelector}) for "${name}"`);
    await confirm.click();
    await (0, _waitForBehaviour.waitFor)(async () => !(await matchingRows()).includes(name), {
      timeout: 20000,
      expected: `leftover "${name}" to be deleted`
    });
  }
  throw new Error(`Still found rows starting with "${prefix}" after 20 deletions - stopping rather than looping.`);
});