export const waitFor = async <T>(
    predicate: () => T | Promise<T>,
    options?: {
        timeout?: number;
        wait?: number;
        state?: string;
        // Plain-English statement of the condition being polled for, e.g.
        // `"Submit button" to be displayed` - paired with describeActual
        // below to build an Expected/Found failure message instead of the
        // generic "wait time exceeded", which never said what was actually
        // on the page. Only used once, on final failure - not on every
        // poll, since most polls succeed and this is purely diagnostic.
        expected?: string;
        describeActual?: () => Promise<string>;
    }
): Promise<T> => {
    const {timeout = 15000, wait = 2000} = options || {};
    const sleep = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

    const startDate = new Date();
    let lastError: unknown;

    while (new Date().getTime() - startDate.getTime() < timeout) {
        // A predicate can THROW rather than return falsy - e.g. page.$()
        // rejecting with "Execution context was destroyed" when a click
        // triggers a real navigation right as this poll fires (confirmed
        // live on Watco's checkout-delivery "accordion continue" step).
        // That's a transient state, not a real failure: treat it the same
        // as a falsy result and keep polling, since the page settling on
        // its next load is exactly the sort of thing this loop exists to
        // wait out. Only fixed to fail loud if it NEVER settles.
        try {
            const result = await predicate();
            if (result) return result;
        } catch (error) {
            lastError = error;
        }

        await sleep(wait);
    }

    if (options?.expected && options?.describeActual) {
        const actual = await options.describeActual().catch((error) =>
            `could not determine (${error instanceof Error ? error.message : String(error)})`
        );
        throw new Error(`Expected: ${options.expected}\nFound: ${actual}`);
    }

    if (lastError) {
        throw new Error(`Wait time of ${timeout}ms exceeded (last error: ${lastError instanceof Error ? lastError.message : String(lastError)})`);
    }
    throw new Error(`Wait time of ${timeout}ms exceeded`);
};