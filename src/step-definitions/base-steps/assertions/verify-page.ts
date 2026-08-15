import {Then} from "@cucumber/cucumber";
import {ScenarioWorld} from "../../setup/world";
import {PageId} from "../../../env/global";
import {currentPathMatchesPageId} from "../../support-functions/navigation-behaviour";
import {waitFor} from "../../support-functions/wait-for-behaviour";

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
