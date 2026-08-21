import {Then} from "@cucumber/cucumber";
import {ScenarioWorld} from "../../setup/world";
import {PageId} from "../../../env/global";
import {currentPathMatchesPageId} from "../../support-functions/navigation-behaviour";
import {waitFor} from "../../support-functions/wait-for-behaviour";
import {getElementLocator} from "../../support-functions/web-element-helper";
import {ElementKey} from "../../../env/global";

Then(/^I should be redirected to the "([^"]*)" page$/, async function (this: ScenarioWorld, pageId: PageId) {
    const {
        screen: {page},
        globalConfig,
    } = this;

    await waitFor(() => currentPathMatchesPageId(page, pageId, globalConfig));
});

// For state that lives in the URL itself rather than a distinct page (e.g.
// an Algolia InstantSearch refinement like ?refinementList[...]=Soft+Close),
// where pagesConfig's page-identity matching doesn't apply.
Then(/^the current URL should contain "([^"]*)"$/, async function (this: ScenarioWorld, expectedText: string) {
    const {
        screen: {page},
    } = this;

    await waitFor(() => page.url().includes(expectedText));
});

// For a "click the first item in the list" flow reused across a project
// whose sections don't all have data (e.g. Indespension's Redirects is
// genuinely empty right now, while KOOL's has real rows): if there was
// nothing to click, the URL never changes, so this accepts that as a valid
// outcome too - as long as the site's own confirmed-genuine empty message
// is what's actually showing, not a silently broken click.
Then(/^the current URL should contain "([^"]*)" or the "([^"]*)" should be displayed$/, async function (this: ScenarioWorld, expectedText: string, elementKey: ElementKey) {
    const {
        screen: {page},
        globalConfig,
    } = this;
    const elementIdentifier = getElementLocator(page, elementKey, globalConfig);

    await waitFor(async () => {
        const urlMatches = page.url().includes(expectedText);
        const elementVisible = (await page.$(elementIdentifier)) != null;
        return urlMatches || elementVisible;
    });
});
