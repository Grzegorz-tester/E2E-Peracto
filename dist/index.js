"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.smoke = exports.regression = exports.dev = exports.carbon_regression = exports.Panelco_regression = exports.MIPA_regression = exports.Andy_Thornton_regression = void 0;
var _dotenv = _interopRequireDefault(require("dotenv"));
var _parseEnv = require("./env/parseEnv");
var _fs = _interopRequireDefault(require("fs"));
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
_dotenv.default.config({
  path: (0, _parseEnv.env)('COMMON_CONFIG_FILE')
});
const hostsConfig = (0, _parseEnv.getJsonFromFile)((0, _parseEnv.env)('HOSTS_URL_PATH'));
const pagesConfig = (0, _parseEnv.getJsonFromFile)((0, _parseEnv.env)('PAGES_URL_PATH'));
const mappingFiles = _fs.default.readdirSync(`${process.cwd()}${(0, _parseEnv.env)('PAGE_ELEMENTS_PATH')}`);
const usersConfig = (0, _parseEnv.getJsonFromFile)((0, _parseEnv.env)('USERS_CONFIG_PATH'));
const pageElementMappings = mappingFiles.reduce((pageElementConfigAcc, file) => {
  const key = file.replace('.json', '');
  const elementMappings = (0, _parseEnv.getJsonFromFile)(`${(0, _parseEnv.env)('PAGE_ELEMENTS_PATH')}${file}`);
  return {
    ...pageElementConfigAcc,
    [key]: elementMappings
  };
}, {});
const worldParameters = {
  hostsConfig,
  pagesConfig,
  pageElementMappings,
  usersConfig
};
const common = `./src/features/**/*.feature \
                --require-module ts-node/register \
                --require ./src/step-definitions/**/**/*.ts \
                -f json:./reports/report.json \
                --world-parameters ${JSON.stringify(worldParameters)} \
                --format progress-bar \
                --parallel ${(0, _parseEnv.env)('PARALLEL')} \
                --retry ${(0, _parseEnv.env)('RETRY')}`;
const dev = exports.dev = `${common} --tags '@dev'`;
const smoke = exports.smoke = `${common} --tags '@smoke'`;
const regression = exports.regression = `${common} --tags '@regression'`;
const Panelco_regression = exports.Panelco_regression = `${common} --tags '@Panelco_regression'`;
const Andy_Thornton_regression = exports.Andy_Thornton_regression = `${common} --tags '@Andy_Thornton_regression'`;
const MIPA_regression = exports.MIPA_regression = `${common} --tags '@MIPA_regression'`;
const carbon_regression = exports.carbon_regression = `${common} --tags '@carbon_regression'`;
console.log('\n🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 ✨ 🥒 \n');