# ISE_SERVICE_PORTAL automation notes

InSinkErator Service Portal: a standalone Symfony web app (not Peracto/Shopify) where service companies and engineers raise and complete warranty/installation jobs. Built from SoW VS1366 (requirement ids ISE-SP.n). Runs `src/features/ISE_SERVICE_PORTAL_features/` (19 features, ~107 scenarios as of 2026-10-14). Test plan: `docs/test-plans/ise-service-portal-e2e-test-plan.md` (has the IWS ticket -> suite impact table).

## Environments
- `env/ISE_SERVICE_PORTAL_STAGING.env` -> https://staging.insinkerator-ws.work. The only env. `PARALLEL=1`, `RETRY=1`, `SCRIPT_TIMEOUT=20000`.
- Staging, but writes have real side effects: job journeys send emails (customer, company, ISE) and order placement may hit Oracle. User approved (2026-10-07) completing jobs, Aquatherm export, product sync, global Settings edits and Manager/Developer roles on staging.
- No production env. Never point this suite at production without a full review of `@creates-jobs`, `@changes-global-settings`, `@runs-tasks`, `@creates-users` scenarios.

## Test accounts and data
- `users.json` roles -> `.env` vars `ISE_SERVICE_PORTAL_<ROLE>_EMAIL`/`_PASSWORD` for OWNER, ADMIN, MANAGER, ENGINEER, DEVELOPER; plus `guest`.
- Staging user ids: admin 79, developer 80, owner 81, engineer 82, manager 83. Engineer and Manager are assigned to "Test Company".
- LOGIN THROTTLING: ~3 failed logins lock that account for ~15 min. Never use real role accounts for negative login tests (use a non-existent address).
- `settings.feature` edits GLOBAL settings and restores them. If a run dies mid-scenario, check by hand: call-out 8500, mileage 45, radius 0, token link expiry 72, every notification recipient list empty, admin 79's "Can authorise mileage" unticked.
- Data leaks every run (accepted by the test plan): jobs have no delete (Edit only allows status Cancelled, not automated since it may email); companies, fault codes and engineers are hide-not-delete by SoW design.
- `company-addresses.feature` self-cleans addresses prefixed "Velstar Test" (Remove has no confirm).
- Reset password uses an address with no account, so no real email is sent.

## Known site defects (expected red)
All confirmed live 2026-10-06/07, all still open at the 2026-10-14 QA review (93/104). Not raised as Jira bugs (Jira project IWS) as of 2026-10-14.
- Dashboard email search returns nothing (SP.10); `#JOB-...` with the `#` also returns nothing. `dashboard.feature`.
- Installation Signature accepts only one guarantee confirmation (SP.28). `job-installation-journey.feature`.
- "Continue job" always goes to `/new-setup` instead of resuming (SP.19).
- No live VAT/total on Invoicing (SP.31).
- Invoicing "Add part" does nothing. `job-invoicing.feature`.
- Mileage authorisation permission not enforced (code field enabled for users without it). `job-mileage-authorisation.feature`.
- Users page Active/Inactive/Delete silently do nothing: row-action forms lack the JS CSRF controller, so Symfony's same-origin check rejects them with a bare 302. `users.feature`.
- Product sync task failing since 2026-09-29. `tasks.feature`.
- Manager's "+ Engineer" button is dead (a submit doing nothing). `engineers.feature`.
- A job raised with no engineer is shown as "Assigned". `job-management.feature`.

## Quirks and gotchas
- RETRACTED-style trap: quick Playwright scripts that submit before JS loads skip the Stimulus CSRF controller and make the Users row actions look like they work. When a script and the framework disagree, add request logging inside the framework first.
- "Continue job" needs "click precisely": a forced click lands on the sticky footer's "Change engineer" link (`/assign`).
- "Still on page X" after a submit passes falsely; assert the validation error instead.
- Search false-pass: the remembered customer is usually first on the unfiltered list, so wait for `q=` in the URL before asserting.
- "should be displayed" only checks DOM presence; use "should (not) be visible" for real visibility.
- Our own jobs float to the top of the dashboard; the cross-company check uses the first Complete job.
- No job is ever "New" on staging.
- Step 1 of a new job needs the customer's email (and first/last name) to advance; Diagnosis accepts an empty form (open question, not asserted).
- Staging can be slow: a 45-min run had login timeouts (2026-10-06); a rerun was clean.
- Tasks run via "Run now" are queued ("Pending") and picked up by a worker: use the reload-until steps.

## Coverage and gaps
- Covered: login/roles/landing, access control (incl. 403 rows), dashboard search/filters, job management, installation and warranty journeys end to end (incl. Complete), step validation, invoicing, mileage authorisation, fault codes, companies, company addresses (Manager-only `/company/addresses`, IWS-56), engineers, users, settings, tasks (Aquatherm export, product sync), mobile (engineer screens at 390x844 in Chromium; real-device Safari stays manual), health check, reset password.
- Open questions asserted as built (not red): Admin can open Users/Tasks (IWS-55 says intended); company has only name + Active (SoW SP.13 differs); single installed address for Warranty; Aquatherm export has 6 columns, not Aquatherm's 29.
- Not built: complaint-code management (doesn't exist yet, SP.17 / IWS-49).
- Pending scope changes (not deployed on staging as of 2026-10-14): IWS-62 (fault code removed from Diagnosis; the "F-134" selects in journeys/tasks will break and `fault-codes.feature` becomes obsolete), IWS-49, IWS-16 (Settings hub; sync/export move there), IWS-55, IWS-64 (Repaired/Replaced on Notes), IWS-65 (UK/ROI country select).

## Tips for extending
- Row actions on lists: reuse `I click on the "X" inside the "Y" containing the remembered "Z"`.
- Server-side totals reference: £85 call-out + 2 x £10 parts + £20 labour; mileage 45p/mile beyond the radius.
- Tag new scenarios with the matching side-effect tag (`@creates-jobs`, `@creates-users`, `@runs-tasks`, `@changes-global-settings`) and restore anything global.
- Ask the user before automating anything that emails real ISE/customer addresses beyond what is already approved.

_Last reviewed: 2026-10-24. Sources: memory notes + feature file comments._
