"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.detectBlockPage = exports.blockPageMessage = void 0;
// Text a site's WAF/bot protection serves in place of the real page.
// CONFIRMED (live, 2026-10-13): Insinkerator staging AND production both
// intermittently serve "Your request has been blocked for security reasons"
// to the runner - 5 different scenarios across 3 runs, a different one each
// time. Without detection, the block page "loads" instantly, every
// "if present" step quietly passes, and the scenario only fails 15-20s later
// on a selector timeout that reads like a real selector/site bug. Add other
// sites' block-page wording here once it's been seen live.
const BLOCK_PAGE_PATTERNS = [/Your request has been blocked for security reasons/i];

// A block page is a tiny stub; only its text is checked, so a real page that
// happens to quote one of these phrases (e.g. an FAQ) isn't misreported.
const MAX_BLOCK_PAGE_TEXT_LENGTH = 2000;

/**
 * Returns the matched block-page text if the current page is a WAF/bot block
 * page, otherwise null. Never throws - a page mid-navigation or already
 * closed just reads as "not blocked".
 */
const detectBlockPage = async page => {
  if (!page || page.isClosed()) return null;
  try {
    // textContent (not innerText) so this doesn't force a layout on
    // every step of every scenario.
    const text = await page.evaluate(maxLength => {
      const content = document.body?.textContent ?? '';
      return content.length <= maxLength ? content : '';
    }, MAX_BLOCK_PAGE_TEXT_LENGTH);
    const match = BLOCK_PAGE_PATTERNS.map(pattern => text.match(pattern)).find(Boolean);
    return match ? match[0] : null;
  } catch {
    return null;
  }
};

// Expected/Found shape so pdf-report.ts renders it like every other failure.
exports.detectBlockPage = detectBlockPage;
const blockPageMessage = (url, matchedText) => `Expected: the real page at ${url}\n` + `Found: BLOCKED BY SITE FIREWALL - a WAF/bot-protection block page ("${matchedText}")\n\n` + `Not a selector or site bug. Rerun; if it keeps happening, the runner needs allowlisting on this host.`;
exports.blockPageMessage = blockPageMessage;