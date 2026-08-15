"use strict";

var _cucumber = require("@cucumber/cucumber");
var _parseEnv = require("../../../env/parseEnv");
(0, _cucumber.Given)(/^I am navigating the page as a "([^"]*)" user$/, async function (userType) {
  const {
    screen: {
      page
    },
    globalConfig
  } = this;

  // Get host and environment
  const hostsConfig = globalConfig.hostsConfig;
  const environment = (0, _parseEnv.env)("UI_AUTOMATION_HOST", "staging");
  const hostUrl = hostsConfig[environment];
  if (!hostUrl) {
    throw new Error(`Host URL for environment "${environment}" not found in hosts.json`);
  }

  // Normalize user type and get credentials
  const normalizedUserType = userType.trim().toLowerCase();
  const user = globalConfig.usersConfig[normalizedUserType];
  if (!user && normalizedUserType !== "guest") {
    throw new Error(`Unknown user type: "${userType}". Please check your users.json and step.`);
  }
  if (normalizedUserType === "guest") {
    await page.goto(hostUrl, {
      waitUntil: "domcontentloaded",
      timeout: 60000
    });
    return;
  }
  if (!user.email || !user.password) {
    throw new Error(`Missing credentials for user type "${userType}". Check your users.json.`);
  }

  // Get selectors from login.json mapping
  const loginSelectors = globalConfig.pageElementMappings.login;
  const emailSelector = loginSelectors["Email address"];
  const passwordSelector = loginSelectors["Password"];
  const signInButtonSelector = loginSelectors["Sign In"];

  // Build login URL
  const loginUrl = hostUrl.endsWith("/") ? `${hostUrl}login` : `${hostUrl}/login`;
  await page.goto(loginUrl, {
    waitUntil: "domcontentloaded",
    timeout: 60000
  });

  // Some projects (e.g. HIB) show a newsletter signup popup on a fresh
  // page load whose overlay blocks the Sign In click underneath it. The
  // separate "I dismiss the newsletter popup if present" Cucumber step
  // handles this for feature files that navigate manually, but this
  // compound step bypasses that - dismiss it here too, a no-op where the
  // popup never appears.
  const newsletterCloseButton = page.frameLocator('iframe[src*="mailerlite"]').getByRole("button", {
    name: "Close"
  });
  const newsletterPopupAppeared = await newsletterCloseButton.waitFor({
    state: "visible",
    timeout: 8000
  }).then(() => true).catch(() => false);
  if (newsletterPopupAppeared) {
    await newsletterCloseButton.click();
  }

  // Use selectors from login.json for login actions. Waits for the form
  // to actually be visible/interactive first - unlike the generic click
  // step, this doesn't go through that wait, and some projects' login
  // pages render a skeleton/placeholder form before hydrating the real
  // interactive one, silently swallowing a fill()/click() aimed too early.
  await page.waitForSelector(emailSelector, {
    state: "visible",
    timeout: 30000
  });
  await page.fill(emailSelector, user.email);
  await page.fill(passwordSelector, user.password);
  await page.waitForSelector(signInButtonSelector, {
    state: "visible",
    timeout: 30000
  });
  await page.click(signInButtonSelector);

  // Wait for the post-login redirect. Where it lands varies per project
  // (most redirect to /account, but this isn't universal - HIB redirects
  // to the homepage instead) - LOGIN_SUCCESS_URL is defined in every
  // client's env block for exactly this, but was previously unused here,
  // silently assuming /account for every project.
  const loginSuccessUrl = (0, _parseEnv.env)("LOGIN_SUCCESS_URL", `${hostUrl.replace(/\/$/, "")}/account`).replace(/\/$/, "");
  await page.waitForURL(new RegExp(`^${loginSuccessUrl.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}/?$`), {
    waitUntil: "domcontentloaded",
    timeout: 60000
  });
});