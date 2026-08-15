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

  const count = await page.locator("[id='searchQuery']").count();
  console.log("count of #searchQuery:", count);
  for (let i = 0; i < count; i++) {
    const el = page.locator("[id='searchQuery']").nth(i);
    console.log(i, "visible:", await el.isVisible(), "outerHTML:", await el.evaluate(e => e.outerHTML));
  }

  // Try the visible one specifically
  const visibleSearch = page.locator("[id='searchQuery']").locator("visible=true").first();
  await visibleSearch.fill("Vanquish");
  await page.waitForTimeout(1500);
  const hitCount = await page.locator("[data-testid='search__hits__hit']").count();
  console.log("hit count:", hitCount);
  for (let i = 0; i < Math.min(hitCount, 3); i++) {
    console.log(i, await page.locator("[data-testid='search__hits__hit']").nth(i).evaluate(e => e.outerHTML.slice(0, 300)));
  }

  await page.screenshot({ path: "/private/tmp/claude-502/-Users-ghajduk-Downloads-Tests-e2e/98e3e6cc-4bdb-4694-a03c-e087ec58a3b0/scratchpad/search-dropdown.png", fullPage: true });

  await browser.close();
})();
