import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({ permissions: [] });
  const page = await context.newPage();

  await page.goto('https://staging.hib.pub/', { waitUntil: 'domcontentloaded', timeout: 60000 });
  await page.waitForTimeout(2000);
  const closeBtn = page.locator("div#closeButton");
  if (await closeBtn.count() > 0) { try { await closeBtn.first().click({ timeout: 3000 }); } catch {} }
  await page.waitForTimeout(500);

  await page.fill("#searchQuery", "Solas");

  // Sample the results every second for up to 10s to see how they evolve
  for (let i = 1; i <= 10; i++) {
    await page.waitForTimeout(1000);
    const hits = page.locator("[data-testid='search__hits__hit']");
    const count = await hits.count();
    const first = count > 0 ? await hits.nth(0).innerText().catch(() => '(err)') : '(none)';
    console.log(`t=${i}s: hit count=${count}, first="${first}"`);
  }

  await browser.close();
})();
