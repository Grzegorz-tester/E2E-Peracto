import path from 'path';

/**
 * Loads and parses a JSON file from a given relative path.
 * Throws a descriptive error if the file cannot be loaded.
 */
export const getJsonFromFile = <T = Record<string, string>>(relativePath: string): T => {
    try {
        const fullPath = path.join(process.cwd(), relativePath);
        return require(fullPath);
    } catch (e) {
        throw new Error(`Failed to load JSON from ${relativePath}: ${e instanceof Error ? e.message : e}`);
    }
};

/**
 * Retrieves the value of an environment variable.
 * If not found, returns the provided default value or throws an error.
 */
export const env = (key: string, defaultValue?: string): string => {
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
export const envNumber = (key: string, defaultValue?: number): number => {
    const strValue = env(key, defaultValue !== undefined ? defaultValue.toString() : undefined);
    const num = Number(strValue);
    if (isNaN(num)) {
        throw new Error(`Environment variable ${key} is not a valid number`);
    }
    return num;
};
