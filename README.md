# E2E-Peracto

regression suite for peracto 3 projects
never create orders for HIB project
for all the projects make a reference that it's a velstar test either in the notes section during checkout or as a user name and surname put Velstar Test

## Writing step definitions

Prefer the existing generic steps over writing a new one. Most interactions
are already covered: `I click on the "X" button/link/element`, `I fill in
the "X" input field with "Y"`, `I check the "X"`, the assertion steps, and
the ordinal `I click on the "1st" "X" element` for positional clicks -
reach for that last one instead of writing custom index-handling logic.

Two generic steps exist as escape hatches for common special cases, and are
reusable by any project:
- `I click on the "X" button/link/element if present` - for an optional
  element (a modal, an interstitial) that only sometimes appears.
- `I check the "X", retrying until it is checked` - for a checkbox that
  doesn't reliably register as checked on the first click.

Only add a new bespoke step definition when the action genuinely can't be
expressed with the above - e.g. generating and stashing a dynamic value for
later reuse in the same scenario, a multi-step retry loop (address
autocomplete, etc.), or reaching into an iframe (`frameLocator`, which a
plain CSS selector string cannot do). When you do add one, make it reusable
by other projects, not just the one you're building it for:
- Resolve every element through `getElementLocator(page, elementKey,
  globalConfig)`, the same way every other step does - never hardcode a raw
  CSS selector as a constant inside the step-definition file. The selector
  belongs in that project's `config/<Project>_config/mappings/*.json`, not
  in TypeScript. This is what actually makes a bespoke step reusable:
  another project just needs matching keys in its own mapping file, no
  TypeScript changes.
- Parametrize whatever varies (element keys, search terms, card details,
  etc.) as step arguments instead of hardcoding them.
