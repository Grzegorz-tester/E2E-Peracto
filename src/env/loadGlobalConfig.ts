import fs from 'fs';
import { env, getJsonFromFile } from './parseEnv';
import { GlobalConfig, HostsConfig, PagesConfig, PageElementMappings } from './global';

/**
 * Builds the GlobalConfig from the env vars set by the project's env/<Project>.env
 * file (COMMON_CONFIG_FILE). Loaded directly by the cucumber World rather than
 * passed in via --world-parameters, since embedding the full JSON in a cucumber
 * profile string gets re-tokenized by string-argv - which doesn't understand
 * JSON's `\"` escaping and mis-splits values containing an escaped quote followed
 * by a space (e.g. Insinkerator's `:text-is(\"Reset Password\")` selectors).
 */
export const loadGlobalConfig = (): GlobalConfig => {
    const hostsConfig: HostsConfig = getJsonFromFile(env('HOSTS_URL_PATH'));
    const pagesConfig: PagesConfig = getJsonFromFile(env('PAGES_URL_PATH'));
    const mappingFiles = fs.readdirSync(`${process.cwd()}${env('PAGE_ELEMENTS_PATH')}`);
    const usersConfig = getJsonFromFile<{ [key: string]: { email?: string; password?: string; credentialsEnvPrefix?: string } }>(env('USERS_CONFIG_PATH'));

    // users.json only defines which user types exist; real credentials come from env vars
    // (see .env.example) so they never end up committed to config/*/users.json.
    // Project-specific vars (PROJECT=insinkerator_eu -> INSINKERATOR_EU_..._EMAIL) win over
    // the generic ..._EMAIL fallback, since each storefront's real test account is a
    // distinct plus-aliased address rather than one identity shared across every client.
    const projectPrefix = env('PROJECT', '')
        ? env('PROJECT').toUpperCase().replace(/[^A-Z0-9]+/g, '_') + '_'
        : '';
    for (const userType of Object.keys(usersConfig)) {
        // A user type can borrow another project's credentials by naming that
        // project's var prefix (e.g. a storefront's "admin" user ->
        // "JTDOVE_ADMIN_ADMIN" -> JTDOVE_ADMIN_ADMIN_EMAIL/_PASSWORD), so a
        // storefront scenario can check the admin API with the admin project's
        // account rather than a duplicated copy of it in .env.
        // An env file can repoint the borrowed prefix with
        // <USER_TYPE>_CREDENTIALS_ENV_PREFIX, e.g. a _PROD env whose admin
        // account differs from staging's (HIB_PROD: HIB_ADMIN_PROD_ADMIN).
        const typePrefix = userType.toUpperCase().replace(/[^A-Z0-9]+/g, '_');
        const borrowed = usersConfig[userType].credentialsEnvPrefix
            ? process.env[`${typePrefix}_CREDENTIALS_ENV_PREFIX`] || usersConfig[userType].credentialsEnvPrefix
            : undefined;
        if (borrowed) {
            usersConfig[userType].email = process.env[`${borrowed}_EMAIL`] || usersConfig[userType].email;
            usersConfig[userType].password = process.env[`${borrowed}_PASSWORD`] || usersConfig[userType].password;
            continue;
        }
        const emailOverride = process.env[`${projectPrefix}${typePrefix}_EMAIL`] || process.env[`${typePrefix}_EMAIL`];
        const passwordOverride = process.env[`${projectPrefix}${typePrefix}_PASSWORD`] || process.env[`${typePrefix}_PASSWORD`];
        if (emailOverride) usersConfig[userType].email = emailOverride;
        if (passwordOverride) usersConfig[userType].password = passwordOverride;
    }

    const pageElementMappings: PageElementMappings = mappingFiles.reduce(
        (pageElementConfigAcc, file) => {
            const key = file.replace('.json', '');
            const elementMappings = getJsonFromFile(`${env('PAGE_ELEMENTS_PATH')}${file}`);
            return { ...pageElementConfigAcc, [key]: elementMappings };
        },
        {}
    );

    return {
        hostsConfig,
        pagesConfig,
        pageElementMappings,
        usersConfig,
    };
};
