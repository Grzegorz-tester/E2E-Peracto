import path from 'path';

// Every env file is named <PROJECT>_<STAGING|RELEASE|PROD>.env (see CLAUDE.md's
// naming convention), and that suffix must agree with the file's own
// UI_AUTOMATION_HOST. Production safety used to hang off UI_AUTOMATION_HOST
// alone, so a wrong host value (or a copied env file nobody updated) was
// enough to point "staging-only" writes at a live site. Checking BOTH the
// host and the filename means either one saying "production" is enough to
// lock the run down.
const HOST_SUFFIX: Record<string, string> = {
    staging: 'STAGING',
    release_branch: 'RELEASE',
    production: 'PROD',
};

// Tags whose scenarios write real data or place real orders; never allowed
// to run against production, however the run was started.
export const PRODUCTION_UNSAFE_TAGS = [
    '@places-real-order',
    '@completes-registration',
    '@mutates-admin-data',
    '@requires-order-history',
    '@submits-real-form',
    '@not-on-production',
];

export const envFileName = (): string =>
    path.basename(process.env.COMMON_CONFIG_FILE ?? 'env/common.env', '.env');

export const isProductionRun = (): boolean =>
    process.env.UI_AUTOMATION_HOST === 'production' || /_PROD$/.test(envFileName());

// Fails the whole run up front when an env file's name and its
// UI_AUTOMATION_HOST disagree (e.g. KOOLTECH_STAGING.env with
// UI_AUTOMATION_HOST=production), rather than letting it run against
// whichever of the two happens to win.
export const assertEnvNameMatchesHost = (): void => {
    const name = envFileName();
    if (name === 'common') return;
    const host = process.env.UI_AUTOMATION_HOST ?? '';
    const expected = HOST_SUFFIX[host];
    if (!expected || !name.endsWith(`_${expected}`)) {
        throw new Error(
            `env/${name}.env has UI_AUTOMATION_HOST="${host}", which doesn't match its filename. ` +
            `Env files must end in _STAGING (staging), _RELEASE (release_branch) or _PROD (production). ` +
            `Fix the host or rename the file before running.`
        );
    }
};
