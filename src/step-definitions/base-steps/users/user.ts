import { Given } from "@cucumber/cucumber";
import { ScenarioWorld } from "../../setup/world";
import { env } from "../../../env/parseEnv";

Given(/^I am navigating the page as a "([^"]*)" user$/, async function (this: ScenarioWorld, userType: string) {
    const {
        screen: { page },
        globalConfig,
    } = this;

    // Get host and environment
    const hostsConfig = globalConfig.hostsConfig;
    const environment = env("UI_AUTOMATION_HOST", "staging");
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
        await page.goto(hostUrl);
        return;
    }

    if (!user.email || !user.password) {
        throw new Error(
            `Missing credentials for user type "${userType}". Check your users.json.`
        );
    }

    // Get selectors from login.json mapping
    const loginSelectors = globalConfig.pageElementMappings.login;
    const emailSelector = loginSelectors["Email address"];
    const passwordSelector = loginSelectors["Password"];
    const signInButtonSelector = loginSelectors["Sign In"];

    // Build login URL
    const loginUrl = hostUrl.endsWith("/") ? `${hostUrl}login` : `${hostUrl}/login`;
    await page.goto(loginUrl);

    // Use selectors from login.json for login actions
    await page.fill(emailSelector, user.email);
    await page.fill(passwordSelector, user.password);
    await page.click(signInButtonSelector);

    // Optionally, wait for a post-login redirect (e.g., to /account)
    const postLoginPath = "/account";
    await page.waitForURL(new RegExp(`${hostUrl.replace(/\/$/, "")}${postLoginPath}`));
});
