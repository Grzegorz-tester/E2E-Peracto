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
        this.globalConfig = options.parameters as GlobalConfig;
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
        const context = await browser.newContext(contextOptions);
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
