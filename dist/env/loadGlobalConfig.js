"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.loadGlobalConfig = void 0;
var _fs = _interopRequireDefault(require("fs"));
var _parseEnv = require("./parseEnv");
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
/**
 * Builds the GlobalConfig from the env vars set by the project's env/<Project>.env
 * file (COMMON_CONFIG_FILE). Loaded directly by the cucumber World rather than
 * passed in via --world-parameters, since embedding the full JSON in a cucumber
 * profile string gets re-tokenized by string-argv - which doesn't understand
 * JSON's `\"` escaping and mis-splits values containing an escaped quote followed
 * by a space (e.g. Insinkerator's `:text-is(\"Reset Password\")` selectors).
 */
const loadGlobalConfig = () => {
  const hostsConfig = (0, _parseEnv.getJsonFromFile)((0, _parseEnv.env)('HOSTS_URL_PATH'));
  const pagesConfig = (0, _parseEnv.getJsonFromFile)((0, _parseEnv.env)('PAGES_URL_PATH'));
  const mappingFiles = _fs.default.readdirSync(`${process.cwd()}${(0, _parseEnv.env)('PAGE_ELEMENTS_PATH')}`);
  const usersConfig = (0, _parseEnv.getJsonFromFile)((0, _parseEnv.env)('USERS_CONFIG_PATH'));

  // users.json only defines which user types exist; real credentials come from env vars
  // (see .env.example) so they never end up committed to config/*/users.json.
  // Project-specific vars (PROJECT=insinkerator_eu -> INSINKERATOR_EU_..._EMAIL) win over
  // the generic ..._EMAIL fallback, since each storefront's real test account is a
  // distinct plus-aliased address rather than one identity shared across every client.
  const projectPrefix = (0, _parseEnv.env)('PROJECT', '') ? (0, _parseEnv.env)('PROJECT').toUpperCase().replace(/[^A-Z0-9]+/g, '_') + '_' : '';
  for (const userType of Object.keys(usersConfig)) {
    const typePrefix = userType.toUpperCase().replace(/[^A-Z0-9]+/g, '_');
    const emailOverride = process.env[`${projectPrefix}${typePrefix}_EMAIL`] || process.env[`${typePrefix}_EMAIL`];
    const passwordOverride = process.env[`${projectPrefix}${typePrefix}_PASSWORD`] || process.env[`${typePrefix}_PASSWORD`];
    if (emailOverride) usersConfig[userType].email = emailOverride;
    if (passwordOverride) usersConfig[userType].password = passwordOverride;
  }
  const pageElementMappings = mappingFiles.reduce((pageElementConfigAcc, file) => {
    const key = file.replace('.json', '');
    const elementMappings = (0, _parseEnv.getJsonFromFile)(`${(0, _parseEnv.env)('PAGE_ELEMENTS_PATH')}${file}`);
    return {
      ...pageElementConfigAcc,
      [key]: elementMappings
    };
  }, {});
  return {
    hostsConfig,
    pagesConfig,
    pageElementMappings,
    usersConfig
  };
};
exports.loadGlobalConfig = loadGlobalConfig;