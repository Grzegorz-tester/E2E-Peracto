"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.getJsonFromFile = exports.envNumber = exports.env = void 0;
var _path = _interopRequireDefault(require("path"));
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
/**
 * Loads and parses a JSON file from a given relative path.
 * Throws a descriptive error if the file cannot be loaded.
 */
const getJsonFromFile = relativePath => {
  try {
    const fullPath = _path.default.join(process.cwd(), relativePath);
    return require(fullPath);
  } catch (e) {
    throw new Error(`Failed to load JSON from ${relativePath}: ${e instanceof Error ? e.message : e}`);
  }
};

/**
 * Retrieves the value of an environment variable.
 * If not found, returns the provided default value or throws an error.
 */
exports.getJsonFromFile = getJsonFromFile;
const env = (key, defaultValue) => {
  const value = process.env[key];
  if (value === undefined || value === null) {
    if (defaultValue !== undefined) return defaultValue;
    throw new Error(`No environment variable found for ${key}`);
  }
  return value;
};

/**
 * Retrieves the value of an environment variable as a number.
 * If not found or not a valid number, throws an error or returns the default value.
 */
exports.env = env;
const envNumber = (key, defaultValue) => {
  const strValue = env(key, defaultValue !== undefined ? defaultValue.toString() : undefined);
  const num = Number(strValue);
  if (isNaN(num)) {
    throw new Error(`Environment variable ${key} is not a valid number`);
  }
  return num;
};
exports.envNumber = envNumber;