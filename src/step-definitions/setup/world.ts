import playwright, {
    BrowserContextOptions,
    Page,
    Browser,
    BrowserContext,
    BrowserType
} from "playwright";
import { env } from '../../env/parseEnv';
import { World, IWorldOptions, setWorldConstructor } from "@cucumber/cucumber";
import { GlobalConfig, GlobalVariables } from '../../env/global';
import { loadGlobalConfig } from '../../env/loadGlobalConfig';

export type Screen = {
    browser: Browser;
    context: BrowserContext;
    page: Page;
};

export class ScenarioWorld extends World {
    globalConfig: GlobalConfig;
    globalVariables: GlobalVariables;
    screen!: Screen;

    constructor(options: IWorldOptions) {
        super(options);
        this.globalConfig = loadGlobalConfig();
        this.globalVariables = {};
    }

    /**
     * Initializes a new browser, context, and page for each scenario.
     * Closes any existing resources before starting a new session.
     */
    async init(contextOptions?: BrowserContextOptions): Promise<Screen> {
        // Gracefully close any previously opened resources
        await this.closeScreen();

        const browser = await this.newBrowser();
        // Explicitly deny permissions (geolocation, etc.) rather than
        // leaving them unset - Chromium shows a real native prompt for an
        // undecided permission, which auto-denies invisibly in headless
        // mode but blocks indefinitely in headed mode waiting for a human
        // to click it (found via the "Find a Retailer" page, which
        // requests geolocation and already handles a denial gracefully).
        const context = await browser.newContext({ permissions: [], ...contextOptions });
        const page = await context.newPage();


        this.screen = { browser, context, page };
        return this.screen;
    }

    /**
     * Helper to close any open browser, context, or page.
     */
    private async closeScreen() {
        if (this.screen) {
            try { await this.screen.page.close(); } catch (e) { /* ignore */ }
            try { await this.screen.context.close(); } catch (e) { /* ignore */ }
            try { await this.screen.browser.close(); } catch (e) { /* ignore */ }
        }
    }

    /**
     * Launches a new browser instance based on the environment variable.
     */
    private async newBrowser(): Promise<Browser> {
        const automationBrowsers = ['chromium', 'firefox', 'webkit'] as const;
        type AutomationBrowser = typeof automationBrowsers[number];
        const automationBrowser = env('UI_AUTOMATION_BROWSER') as AutomationBrowser;

        if (!automationBrowsers.includes(automationBrowser)) {
            throw new Error(
                `Invalid UI_AUTOMATION_BROWSER: "${automationBrowser}". Valid options are: ${automationBrowsers.join(', ')}`
            );
        }

        const browserType: BrowserType = playwright[automationBrowser];
        return browserType.launch({
            headless: env('HEADLESS').toLowerCase() === 'true',
            args: ['--disable-web-security', '--disable-features=IsolateOrigins,site-per-process'],
        });
    }
}

setWorldConstructor(ScenarioWorld);
