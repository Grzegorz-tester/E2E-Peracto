# InSinkErator Service Portal - E2E test plan

Internal only. Source: SoW VS1366 "InSinkErator Service Portal (v1)", V1.0 (in progress, last updated
20 Mar 2026), user stories ISE-SP.1 to ISE-SP.34. Re-check against the SoW if it moves past V1.0.

## 0. Live findings (staging.insinkerator-ws.work, 2026-10-06)

The built app has moved on from the SoW in places. Where they differ, the suite tests what's built and
flags the difference.

- **Roles in the app:** Owner, Admin, Service Manager, Service Engineer, Developer. Our `+manager` and
  `+developer` accounts are parked for now. All five test accounts currently have **Company: None**.
- **Job steps as built:** Diagnosis, Replacement product, Service info, (Authorisation), Service date,
  Current setup, New setup, Signature, Invoicing, Notes, Complete. Statuses: New, Assigned, Awaiting
  authorisation, Awaiting part, Booked, Complete.
- **Admin can open Users, Companies, Engineers, Fault codes and Tasks** (Tasks has the manual product
  sync and Aquatherm export). Only Settings returns 403 for Admin. The SoW puts user management and the
  manual sync/export inside the Owner-only Settings area. This is an open question, not a confirmed bug.
- **Engineer:** 403 on every admin page and on other companies' jobs. Sees "No jobs to show." because
  the account has no company.
- **Search:** name, job reference (without `#`) and postcode work. **Customer email returns nothing**,
  although SP.10 lists email (the test is left red deliberately). Searching for the reference exactly as
  the card shows it (`#JOB-…`) also returns nothing.
- **Login throttling:** about 3 failed attempts locks an account for ~15 minutes. Negative login tests use
  an address with no account.
- **Password reset:** 1-hour link lifetime and a 5-minute cooldown between requests (both set in Settings).
- **Settings as built:** call-out charge, mileage rate and call-out radius (each with per-company
  overrides), email recipients, file-share link expiry, password reset, and the user permission flags
  "Can authorise mileage" and "Receives stock emails". Fault codes are their own page.

- **Installation journey (job-installation-journey.feature), CONFIRMED live:**
  - The full flow works up to the Complete screen. The final Submit is never clicked by the suite,
    because it sends real job-complete emails. Completing a job is still untested.
  - Status goes Assigned -> Booked as soon as Service info is saved (inside the radius). This looks like
    automatic order placement. Not verified on the ISE website side.
  - SP.27 anti-fraud works: one photo is rejected with "Upload a photo of the finished installation below
    the sink."
  - Server-side invoice totals are correct (£85 call-out + £20 parts + £20 labour = £125, VAT £25, total
    £150).
  - Signature is photo upload only. There's no on-screen signature pad, though the SoW has one with a
    photo fallback.
  - The product picker is a plain checkbox list with no search, though SP.22 says searchable lookup.
  - Invoicing appears for Installation jobs too (an open question in SP.31).
  - **Defects, left red deliberately:**
    - Signature accepts only one guarantee ticked (SP.28). The checkboxes have no `name`, so nothing
      reaches the server.
    - "Continue job" always points at New setup, not the next step that isn't done (SP.19).
    - VAT and total don't update while typing (SP.31).
- The `+engineer` account was assigned to "Test Company" on staging (2026-10-06) so it can create jobs.

- **Warranty journey (job-warranty-journey.feature), CONFIRMED live:**
  - Diagnosis offers separate Complaint and Fault code lists (SP.21). Current setup requires the
    on-arrival photo (SP.26). Signature has no guarantee checkboxes, which is correct.
  - Status goes Assigned -> Awaiting part after Service info.
  - Open question: Diagnosis accepts a completely empty form and marks the step complete.
  - Step 1 has a single address for Warranty too, though SP.20 says billing plus delivery with an
    override.
- **Mileage authorisation (job-mileage-authorisation.feature), CONFIRMED live:**
  - Outside radius -> Awaiting authorisation.
  - The code field is disabled for the Engineer. Admin (with the permission) and Owner get
    "Authorise & Continue".
  - Authorising -> Awaiting part.
  - Excess mileage carries to the invoice (10 miles = £4.50 at 45p).
  - An Admin without the permission isn't covered, since there's no second Admin account.
- **Fault codes (fault-codes.feature), CONFIRMED live:** add, edit and hide work. Hidden codes stop being
  offered at Diagnosis. **There's no complaint code management screen** (SP.17 gap). Admin can manage
  fault codes too.
- New-job step 1 needs the customer email (or phone) to move on, though only the names are marked
  required.

### Round 3 (2026-10-07): full coverage

Approved by the user for staging: completing jobs, running the Aquatherm export, running the product
sync, editing global Settings (always restored), and covering the Service Manager and Developer roles
(Manager assigned to Test Company).

**Confirmed defects (each has a deliberately red scenario):**

| # | Area | Defect | SoW |
|---|---|---|---|
| 1 | Dashboard | Search by customer email returns nothing | SP.10 |
| 2 | Signature | Installation guarantees not enforced (checkboxes have no `name`) | SP.28 |
| 3 | Job detail | "Continue job" always points at an early step, not the next one that isn't done | SP.19 |
| 4 | Invoicing | VAT/total don't update while typing (correct after saving) | SP.31 |
| 5 | Invoicing | "Add part" does nothing (no `collection` controller on the page), so only one part per invoice | SP.31 |
| 6 | Mileage | "Can authorise mileage" not enforced: an Admin without it authorised a job | SP.24 |
| 7 | Users | Active / Inactive / Delete silently fail for real users (CSRF: row forms lack the JS CSRF controller that the login form uses) | SP.16 |
| 8 | Tasks | Product sync fails every run since 2026-09-29, log says only "Task failed." | SP.2 |
| 9 | Engineers | Manager's "+ Engineer" button does nothing (submit button outside a form) | SP.13 |
| 10 | Jobs | A job with no engineer is "Assigned", never "New", so the New filter is always empty (likely, confirm) | - |

**Differences from the SoW and open questions (asserted as built, not red):**
- Aquatherm export has 6 columns, not Aquatherm's 25. It includes Installation jobs.
- Notification recipient lists in Settings are all empty, so exports email only the person who ran them.
- Export files show "Expires: Never", although token links are set to expire after 72 hours.
- No complaint code management screen (SP.17). Company has no billing or shipping addresses (SP.13).
  Warranty jobs take one address at creation (SP.20). No on-screen signature pad (SP.28). No product
  search (SP.22).
- Admin can open Users, Companies, Engineers, Fault codes and Tasks (the SoW puts these in Owner-only
  Settings).
- Diagnosis accepts an empty form. Warranty Service is pre-selected as the Service Type.
- "Change engineer" and "Edit job" are still offered on completed jobs.
- Manager gets 404 on another company's job, Engineer gets 403 (both deny).

**Feature files (18, 104 scenarios):** `health-check`, `logging-in`, `reset-password`,
`access-control`, `dashboard`, `job-installation-journey`, `job-warranty-journey`,
`job-mileage-authorisation`, `job-invoicing`, `job-step-validation`, `job-management`, `fault-codes`,
`users`, `engineers`, `companies`, `settings`, `tasks`, `mobile`.

**Still not automated:**
- Password reset link and expiry (needs a test inbox).
- Email delivery generally (triggers covered, delivery not).
- Real iOS/Android devices and Safari (Chromium mobile viewport only).
- An Admin who *does* have the mileage permission is checked only through Settings, since enforcement
  is broken anyway.

## 1. Scope

The portal is a standalone, mobile-first Symfony app (not Peracto, not Shopify). There are two journeys,
Warranty Service (In-home) and Installation, which share one job flow and branch at Service Type.

The E2E suite covers what a user can see and do in the browser, plus API-level access control where the
SoW explicitly calls it security-critical (ISE-SP.11, .12, .16, .18). Backend-only stories (cron sync,
Oracle, S3/SFTP, email delivery) can't be fully tested E2E. Section 6 covers how far we can go with them.

Out of scope for this suite (and also out of scope in the SoW's own QA section): load and performance
testing, penetration testing, and design fidelity comparison.

## 2. Roles and test accounts

Credentials go in `.env` (gitignored) only, never in `users.json` or anything committed.

| Account alias | SoW role | Assumed behaviour | Status |
|---|---|---|---|
| `+owner` | Owner | Everything, including Settings (the only role that can see it) | Confirm live |
| `+admin` | Admin | All jobs, no Settings. Can authorise mileage only when flagged | Confirm live, including which flags are set |
| `+engineer` | Service Engineer (company login) | Only their own company's jobs (hard filter), plus Company account management | Confirm live |
| `+manager` | Not in SoW | Unknown | **Open question** |
| `+developer` | Not in SoW | Unknown, possibly a superuser/debug role | **Open question** |

We probably need at least one more engineer login from a **second service company**. Without it, the
cross-company isolation tests (ISE-SP.11/.12) can't be written.

We also need **two Admin variants** for mileage authorisation: one with "can authorise mileage" and one
without. The `+admin` account's flag decides which variant it is, and the other one is missing.

## 3. Environment rules

- **Staging only for anything that writes data.** Production, if we ever get access, is read-only:
  login, dashboard and job detail viewing only.
- **The Auth step "Place order" (ISE-SP.24) sends a real warranty order to the ISE UK website and on to
  Oracle.** Before any scenario runs that step on staging, we must confirm with the solutions team that
  staging points at a non-production website and Oracle. Until then, tag that scenario
  `@places-real-order` and use `I click on the "X" button as the final real submission`.
- **Completing a job sends real emails** to the customer, the company and InSinkErator (ISE-SP.30/.34).
  Always use a Velstar-controlled customer email (a `+ise-sp-customer` alias). Confirm where
  InSinkErator's copy goes on staging.
- **Mark all job data as a Velstar test.** Customer name "Velstar Test", "Velstar Test" in the Notes
  step, and PO numbers prefixed `VELSTAR-TEST-`.
- **Hide, don't delete.** The SoW says engineers, fault codes and complaint codes are hidden rather than
  deleted, so tests will pile up hidden records. Give every created record a `qa-<timestamp>` name so
  they're easy to recognise.

## 4. Story-to-test mapping

E2E column: **Full** = fully testable in the browser. **Partial** = only the UI trigger or visible outcome
can be tested. **None** = backend only, covered indirectly or not at all.

| Story | Title | E2E | Feature file | What we assert |
|---|---|---|---|---|
| SP.1 | Hosting + config | Partial | `health-check.feature` | Staging host responds, login page renders, no 5xx |
| SP.2 | Product data sync | Partial | `settings-sync-and-export.feature`, `job-new-product.feature` | Owner's "Sync now" succeeds. Product lookup returns synced products by name and SKU, including inactive/out-of-stock ones |
| SP.3 | Import order endpoint | None | n/a | Covered indirectly by the SP.24 place-order outcome. Open decision in SoW, may move phase |
| SP.4 | Warranty order to Oracle | None | n/a | Not E2E. Confirm via Oracle or website admin manually, if at all |
| SP.5 | Month-end file | Partial | `settings-sync-and-export.feature` | Owner's manual export trigger succeeds. If the file is downloadable, check it's XLSX/CSV with the agreed columns (the 4 excluded columns are absent) |
| SP.6 | File storage + notify | None | n/a | Delivery method not confirmed yet. Revisit once S3/SFTP/email is chosen |
| SP.7 | Login screen | Full | `logging-in.feature` | Each role logs in and lands on the right view. Invalid credentials show an error. Empty-field validation works |
| SP.8 | Forgotten password | Partial | `reset-password.feature` | Reset request shows confirmation. Unknown email doesn't leak whether the account exists. Link expiry is manual, as there's no mailbox access |
| SP.9 | Auth data/session | Partial | `logging-in.feature` | Logging out ends the session (back button / direct URL goes to login). Session timeout is manual |
| SP.10 | Dashboard table | Full | `dashboard.feature` | Job list renders. Search by customer name, email and postcode. Status and Service Type filter chips. Pagination. "New job" button |
| SP.11 | Engineer hard filter | Full | `access-control.feature` | Engineer sees only own-company jobs. No UI control to widen the filter |
| SP.12 | API-level scoping | Full | `access-control.feature` | Engineer A opening company B's job by direct URL (and via the job API, if exposed) gets denied/404, not data |
| SP.13 | Company management | Full | `company-account.feature` | Engineer login edits billing address, adds and edits shipping addresses, adds an engineer, hides an engineer |
| SP.14 | Engineer mgmt backend | Full | `company-account.feature` | A hidden engineer disappears from the Engineer step's dropdown but still shows on historic jobs |
| SP.15 | Owner/Admin account view | Full | `owner-admin-account.feature` | Shows name and email for Owner and Admin |
| SP.16 | Settings (Owner only) | Full | `settings-users.feature`, `access-control.feature` | Owner adds a user with the "receives stock emails" / "can authorise mileage" flags, and manages service companies. Admin and Engineer can't see the Settings nav and get blocked on a **direct URL** |
| SP.17 | Fault/complaint codes | Full | `settings-fault-codes.feature` | Add, edit and hide fault codes and complaint codes. Hidden codes drop out of the Installed Product step's lists |
| SP.18 | Settings backend | Full | `access-control.feature` | Non-Owner calls to Settings endpoints are rejected (if the API is reachable from the browser) |
| SP.19 | Review previous job | Full | `job-detail-and-resume.feature` | Detail view is read-only, shows status and step progress. "Continue" resumes at the correct step |
| SP.20 | Initial job step | Full | `job-warranty-journey.feature`, `job-installation-journey.feature` | Service Type branch. Installation shows one installed address. Warranty shows billing + delivery with an override |
| SP.21 | Installed product | Full | `job-warranty-journey.feature`, `job-step-validation.feature` | Complaint and Fault code are separate lists. Serial number, install date and water pressure. **Step absent on Installation** |
| SP.22 | New product lookup | Full | `job-new-product.feature` | Search by name and by SKU. Out-of-stock product still selectable, and the job proceeds |
| SP.23 | Engineer/service info | Full | `job-mileage-authorisation.feature` | Company pre-filled, engineer select, PO number. Radius toggle reveals excess mileage / flat amount + comments, on both journeys |
| SP.24 | Auth step + place order | Full (UI) / gated (order) | `job-mileage-authorisation.feature` | Step only shown outside radius. Auth code field locked for Engineer and for an unflagged Admin. Unlocked for Owner and a flagged Admin. Place order is gated (see section 3) |
| SP.25 | Booking step | Full | both journey features | Date/time picker sets the visit, and it persists on the job detail |
| SP.26 | Current setup (photo) | Full | `job-warranty-journey.feature` | Upload "before" photo, confirm serial number, readings. **Skipped on Installation** |
| SP.27 | Installed setup (photos) | Full | both journey features, `job-step-validation.feature` | New serial number. Above-sink **and** below-sink photo both required (anti-fraud): can't continue with only one |
| SP.28 | Sign off | Full | both journey features | On-screen signature, or upload a photo of the paper copy. **Installation only**: both guarantee confirmations required, wording matches the Installation Approval Form |
| SP.29 | Notes | Full | both journey features | Free text saved and visible on job detail |
| SP.30 | Completion | Partial | both journey features | Completion screen. Warranty mentions inclusion in the next Aquatherm export. Status changes to complete on the dashboard. Emails are manual unless we add mailbox tooling |
| SP.31 | Invoice UI (Warranty) | Full | `job-invoice-charges.feature` | Add/edit/remove parts rows. Labour. Pre-filled call-out charge. Mileage carried over from SP.23/24. **VAT 20% and total recalculate live** |
| SP.32 | Invoice backend | Full | `job-invoice-charges.feature` | Reload/reopen the job and figures match what was entered. Server total matches the displayed total (catches a client/server mismatch) |
| SP.33 | Job data model | Full | `job-detail-and-resume.feature` | Every step's data persists across logout and login, and status transitions show on the dashboard |
| SP.34 | Emails | None (E2E) | n/a | Triggers covered via SP.22/.24/.30 outcomes. Actual delivery is manual, or later via a test inbox |

## 5. Feature files and core scenarios

Project: separate from the Insinkerator storefront and admin, e.g. `env/ISE_SERVICE_PORTAL.env`,
`config/ISE_SERVICE_PORTAL_config/`, `src/features/ISE_SERVICE_PORTAL_features/`. File names follow the
Insinkerator storefront convention (kebab-case, by area).

Smoke (`@smoke`), the red routes the SoW's own smoke testing definition names:

- `health-check.feature`: login page loads.
- `logging-in.feature`: Owner logs in, Engineer logs in.
- `job-warranty-journey.feature`: create a warranty job up to the first saved step.

Regression (`@regression`):

| Feature file | Key scenarios |
|---|---|
| `health-check.feature` | Host up, login renders |
| `logging-in.feature` | Each role logs in and lands correctly. Invalid password. Empty fields. Logout ends session |
| `reset-password.feature` | Request reset, confirmation copy, unknown email handled neutrally |
| `dashboard.feature` | Search by name, email, postcode. Status filter. Service Type filter. Pagination. New job button |
| `access-control.feature` | Engineer own-company only. Cross-company direct URL denied. Settings hidden and blocked by direct URL for Admin and Engineer. Non-Owner Settings API rejected |
| `company-account.feature` | Edit billing address. Add/edit shipping address. Add engineer. Hide engineer |
| `owner-admin-account.feature` | Owner and Admin see their name and email |
| `settings-users.feature` | Owner adds a user with each permission flag. Manages service companies |
| `settings-fault-codes.feature` | Add/edit/hide fault code. Add/edit/hide complaint code. Hidden code absent in the job step |
| `settings-sync-and-export.feature` | Manual product sync. Manual Aquatherm export (gated until we know where the file goes) |
| `job-warranty-journey.feature` | Full warranty job inside radius: customer, installed product, new product, engineer, booking, current setup, installed setup, sign-off, notes, invoice, completion |
| `job-installation-journey.feature` | Full installation job: Installed Product and Current Setup steps are absent, guarantees required at sign-off |
| `job-mileage-authorisation.feature` | Outside-radius warranty job and outside-radius installation job. Auth field locked/unlocked per role. Owner authorises and the job proceeds |
| `job-new-product.feature` | Lookup by name, by SKU. Out-of-stock product still selectable |
| `job-invoice-charges.feature` | Parts table edits. VAT/total live calculation. Mileage carry-over. Persisted figures after reopening |
| `job-detail-and-resume.feature` | Leave a job mid-flow and resume at the correct step. Read-only detail. Data survives re-login |
| `job-step-validation.feature` | Required fields per step. Single photo rejected at Installed Setup. Missing guarantee blocks Installation sign-off |

Multi-role scenarios (the mileage authorisation hand-off, and engineer creates then Owner views) need a
switch-user step in the middle of a scenario. Check whether `I am navigating the page as a "X" user` copes
with being called twice in one scenario, and if not, add a logout-then-login step.

## 6. Backend-only stories (SP.2-6, SP.34)

- **Product sync (SP.2):** use the Owner's manual "Sync now" plus a lookup assertion. The cron schedule
  itself isn't E2E.
- **Oracle/website order (SP.3/4):** no E2E assertion. If the website side writes an order we can see in
  ISE UK admin (INSINKERATOR_ADMIN project), a later cross-project check is possible, but only once the
  staging integration targets are confirmed.
- **Aquatherm export (SP.5/6):** manual trigger only. Column-level checks need the agreed sample file
  (the SoW says it's still to be provided).
- **Emails (SP.34):** six triggers (replacement dispatch, out-of-stock, mileage auth request, and three
  job-complete emails). Manual for now. Automating would mean adding a test mailbox (for example, a
  Mailosaur-style service or Gmail API access to a dedicated inbox), which needs approval first.

## 7. Devices

The SoW tests the admin panel on desktop only, and engineer-facing screens across desktop and mobile
(iOS 18 Safari, Android 15 Chrome). For the automated suite:

- Engineer journeys (`job-*`, `company-account`, `dashboard` as Engineer): run in a **mobile viewport**
  (Playwright iPhone and Pixel device emulation, using WebKit for the iOS approximation). The repo already
  has a viewport step (`navigation.ts`), but a per-project default device in the env would be cleaner.
- Owner/Admin and Settings: desktop Chromium only.
- Real-device and cross-browser coverage stays manual, as in the SoW.

## 8. Framework gaps to build (generic, reusable)

| Need | Existing support | Gap |
|---|---|---|
| Photo upload (SP.26/27/28) | `I upload the ...` (`file-upload.ts`) | Add small JPG fixtures under `src/fixtures/` |
| Signature capture (SP.28) | None | New step: draw a stroke on a canvas via `page.mouse`, selector from mappings |
| Date/time picker (SP.25) | Fill-input steps | Depends on the widget. May need a picker-specific step |
| Direct URL denied (SP.12/16) | `I navigate directly to the path`, `the current URL should( not)? contain` | Probably enough. Add an "access denied / 403 / 404 shown" assertion if needed |
| API scoping (SP.12/18) | None | New step using `page.request` with the logged-in session, asserting the status code for a given path |
| Live VAT/total maths (SP.31) | None | New step reading numeric values from 2-3 mapped elements and asserting total = subtotal x 1.2 |
| Switch user mid-scenario | Login step | Check, and add a logout step if needed |

## 9. Open questions (blockers in bold)

1. ~~Staging URL~~: https://staging.insinkerator-ws.work/
2. ~~`manager` / `developer` roles~~: they exist as Service Manager and Developer. Parked for now.
3. ~~Engineer company~~: assigned to Test Company. The isolation test now runs against a real
   company engineer.
10. **Completing a job:** who should receive the job-complete emails on staging, and can the suite
    click the final Submit? The SoW's QA section counts completing a job as a red route.
9. Is email search (SP.10) descoped or a defect? Should Admin have Users/Tasks access?
4. **Does staging place real orders through the ISE UK site to Oracle?** (SP.24)
5. Admin account flags: which test account has "can authorise mileage"?
6. Staging recipient for InSinkErator and sales admin emails, and for the Aquatherm export file.
7. Are fault codes seeded on staging yet? (The SoW says the list is still to be confirmed.)
8. Water pressure format (value vs Low/Normal/High) and Installation invoicing are still open in the
   SoW. Tests for these wait until they're decided.
