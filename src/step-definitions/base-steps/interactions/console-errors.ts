import { Then, When } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { expect } from "@playwright/test";

// Registers listeners ONCE per scenario, so errors accumulate across
// however many "I navigate to ..." steps follow (e.g. a full page-by-page
// sweep), not just the page active when this step ran. globalVariables is
// string-only, so the running list is kept JSON-encoded rather than as a
// real array.
//
// Deliberately does NOT catch failed sub-resource loads (e.g. a 404'd
// iframe height-polling request) - Chromium doesn't surface those via
// page.on("console"), only via the Network panel/page.on("requestfailed"),
// so a known-noisy 404 like "/nothing?height=..." (Spektrix iframe height
// polling, seen on basket/account) never reaches this listener at all and
// needs no special-casing here.
When(/^I start monitoring console errors, ignoring messages matching "([^"]*)"$/, async function (this: ScenarioWorld, ignorePattern: string) {
    const { screen: { page } } = this;
    const ignoreRegex = new RegExp(ignorePattern);

    this.globalVariables["__consoleErrors"] = "[]";
    const record = (text: string) => {
        if (ignoreRegex.test(text)) return;
        const errors = JSON.parse(this.globalVariables["__consoleErrors"] || "[]");
        errors.push(text);
        this.globalVariables["__consoleErrors"] = JSON.stringify(errors);
    };

    page.on("console", (msg) => {
        if (msg.type() === "error") record(msg.text());
    });
    page.on("pageerror", (err) => record(err.message));
});

Then(/^there should be no unexpected console errors$/, async function (this: ScenarioWorld) {
    const errors = JSON.parse(this.globalVariables["__consoleErrors"] || "[]");
    expect(errors, `Unexpected console errors:\n${errors.join("\n")}`).toEqual([]);
});
