import { Page } from "playwright";

// For a virtualised list (e.g. react-sortable-tree on Peracto Admin's
// navigation menus), only the rows inside the scroll box's viewport exist in
// the DOM, so a row below the fold can't be found until the box is scrolled.
// Confirmed live 2026-11-25 on the Peracto Admin v13 (React 19) release:
// the Orphaned Pages tree moved from full height (page scroll) into its own
// 576px scroll box, leaving only 13 of 16 rows rendered.
//
// Call this once per poll while waiting for a row: it scrolls the nearest
// scrollable ancestor of the first element matching `selector` down by one
// box height, wrapping back to the top once it hits the bottom, so repeated
// polls sweep the whole list. A no-op when nothing matches or nothing scrolls
// (a plain, non-virtualised list).
export const scrollNearestScrollContainer = async (page: Page, selector: string): Promise<void> => {
    const first = page.locator(selector).first();
    if (!(await first.count())) return;
    await first.evaluate((el) => {
        let node: HTMLElement | null = el.parentElement;
        while (node) {
            const style = getComputedStyle(node);
            if (/(auto|scroll)/.test(style.overflowY) && node.scrollHeight > node.clientHeight + 5) {
                const atBottom = node.scrollTop + node.clientHeight >= node.scrollHeight - 5;
                node.scrollTop = atBottom ? 0 : node.scrollTop + node.clientHeight;
                return;
            }
            node = node.parentElement;
        }
    }).catch(() => undefined);
};
