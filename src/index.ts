import dotenv from 'dotenv'
import { env, getJsonFromFile } from './env/parseEnv'
import {
    GlobalConfig,
    HostsConfig,
    PagesConfig,
    PageElementMappings,
} from './env/global';
import fs from "fs";

dotenv.config({path: env('COMMON_CONFIG_FILE')})
dotenv.config() // optional local .env (gitignored) for real login credentials

const hostsConfig: HostsConfig = getJsonFromFile(env('HOSTS_URL_PATH'));
const pagesConfig: PagesConfig = getJsonFromFile(env('PAGES_URL_PATH'));
const mappingFiles = fs.readdirSync(`${process.cwd()}${env('PAGE_ELEMENTS_PATH')}`);
const usersConfig = getJsonFromFile<{ [key: string]: { email?: string; password?: string } }>(env('USERS_CONFIG_PATH'));

// users.json only defines which user types exist; real credentials come from env vars
// (see .env.example) so they never end up committed to config/*/users.json.
// Project-specific vars (PROJECT=insinkerator_eu -> INSINKERATOR_EU_..._EMAIL) win over
// the generic ..._EMAIL fallback, since each storefront's real test account is a
// distinct plus-aliased address rather than one identity shared across every client.
const projectPrefix = env('PROJECT', '')
    ? env('PROJECT').toUpperCase().replace(/[^A-Z0-9]+/g, '_') + '_'
    : '';
for (const userType of Object.keys(usersConfig)) {
    const typePrefix = userType.toUpperCase().replace(/[^A-Z0-9]+/g, '_');
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

const worldParameters: GlobalConfig = {
    hostsConfig,
    pagesConfig,
    pageElementMappings,
    usersConfig,
};

const common = `./src/features/**/*.feature \
                --require-module ts-node/register \
                --require ./src/step-definitions/**/**/*.ts \
                -f json:./reports/report.json \
                --world-parameters ${JSON.stringify(worldParameters)} \
                --format progress-bar \
                --parallel ${env('PARALLEL')} \
                --retry ${env('RETRY')}`;

const dev = `${common} --tags '@dev'`;
const smoke = `${common} --tags '@smoke'`;
const regression = `${common} --tags '@regression'`;
const Panelco_regression = `${common} --tags '@Panelco_regression'`;
const Andy_Thornton_regression = `${common} --tags '@Andy_Thornton_regression'`;
const MIPA_regression = `${common} --tags '@MIPA_regression'`;
const carbon_regression = `${common} --tags '@carbon_regression'`;


console.log('\n🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 \n');

export {dev, smoke, regression, Panelco_regression, Andy_Thornton_regression, MIPA_regression, carbon_regression};