import { chromium } from "@playwright/test";

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  await page.goto("https://staging.hib.pub/login", { waitUntil: "domcontentloaded" });
  const closeButton = page.frameLocator('iframe[src*="mailerlite"]').getByRole("button", { name: "Close" });
  const appeared = await closeButton.waitFor({ state: "visible", timeout: 8000 }).then(() => true).catch(() => false);
  if (appeared) await closeButton.click();

  await page.waitForSelector("[id='email']", { state: "visible" });
  await page.fill("[id='email']", "grzegorz.hajduk@velstar.co.uk");
  await page.fill("[id='password']", "Testing123!");
  await page.click("[data-testid='login-form__sign-in-button']");
  await page.waitForFunction(() => !location.pathname.includes("/login"), { timeout: 60000 });

  await page.goto("https://staging.hib.pub/place-order", { waitUntil: "domcontentloaded" });
  await page.fill("[id='searchQuery']", "Vanquish");
  await page.waitForSelector("[data-testid='search__hits__hit']", { state: "visible", timeout: 15000 });
  await page.click(":nth-match([data-testid='search__hits__hit'], 1)");
  await page.waitForTimeout(2000);

  const buttons = await page.locator("button").allTextContents();
  console.log("BUTTONS:", JSON.stringify(buttons.map(b => b.trim()).filter(Boolean)));

  await page.screenshot({ path: "/private/tmp/claude-502/-Users-ghajduk-Downloads-Tests-e2e/98e3e6cc-4bdb-4694-a03c-e087ec58a3b0/scratchpad/after-select-result.png", fullPage: true });

  await browser.close();
})();
