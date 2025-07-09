// Unique identifier for a page (e.g., 'login', 'dashboard')
export type PageId = string;

// Unique key for an element on a page (e.g., 'submitButton', 'usernameField')
export type ElementKey = string;

// Locator string for an element (e.g., CSS selector, XPath)
export type ElementLocator = string;

// Mapping from PageId to a mapping of ElementKey to ElementLocator
export type PageElementMappings = Record<PageId, Record<ElementKey, ElementLocator>>;

// Mapping from PageId to a mapping of config keys to values (e.g., URLs, titles)
export type PagesConfig = Record<PageId, Record<string, string>>;

// Mapping from environment/host name to URL
export type HostsConfig = Record<string, string>;

// Generic key-value store for global variables
export type GlobalVariables = { [key: string]: string };

// User credentials structure
export type UserCredentials = {
    email?: string;
    password?: string;
    // Add more fields as needed (e.g., role, displayName)
};

// Mapping from user type (e.g., 'admin', 'user', 'guest') to credentials
export type UsersConfig = Record<string, UserCredentials>;

// Aggregated global configuration object
export type GlobalConfig = {
    pageElementMappings: PageElementMappings;
    hostsConfig: HostsConfig;
    pagesConfig: PagesConfig;
    usersConfig: UsersConfig; // Now included!
    // You can add more properties here as needed
};

