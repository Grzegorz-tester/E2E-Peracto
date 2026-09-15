#!/usr/bin/env bash
# Regression run commands, one per project - copy/paste the line you need.
# Everything below is commented out on purpose: this file is a reference,
# not something to execute end to end (running every project back to back
# would place real staging orders across ~20 storefronts).
#
# Each project uses "regression" as its --profile UNLESS noted otherwise -
# a few projects tag their scenarios with a project-specific regression tag
# instead of the shared @regression tag (see src/index.ts), so they need
# their own profile name.
#
# Admin projects (2026-08-25): every Peracto Admin instance we've verified
# live shares the same suite - src/features/Carbon_admin/**/*.feature - via
# each tenant's own env/<Project>_ADMIN.env, per CLAUDE.md's "Peracto Admin:
# shared boilerplate across tenants". All admin credentials read from
# ADMIN_EMAIL/ADMIN_PASSWORD (or a <PROJECT>_ADMIN_EMAIL override - see
# .env.example) - set the real ones in your local .env before running any
# of the *_ADMIN commands below, they're blank in config/*/users.json on
# purpose. Watco was intentionally skipped (different platform, per the
# user) - all its markets are storefront-only below.
#
# File layout (2026-09-15): commands and per-project context notes used to
# be interleaved, which made the file slow to skim for a quick copy/paste
# and slow to read for the history. Split into two sections below, each
# sorted alphabetically by project name:
#   1. COMMANDS - just the run lines, nothing else.
#   2. NOTES - the per-project context/history that used to sit directly
#      above each project's commands. Only projects with something worth
#      noting appear here.

# ============================================================
# 1. COMMANDS
# ============================================================

# ---- Andy Thornton ----
# COMMON_CONFIG_FILE=env/Andy_Thornton.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Andy_Thornton_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/ANDY_THORNTON_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/ANDY_THORNTON_ADMIN_RELEASE.env ./run_tests.sh regression

# ---- Carbon Admin (the shared admin suite's boilerplate source project) ----
# COMMON_CONFIG_FILE=env/CARBON_ADMIN.env ./run_tests.sh regression

# ---- HIB ----
# COMMON_CONFIG_FILE=env/HIB.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/HIB_RELEASE.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/HIB_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/HIB_ADMIN_RELEASE.env ./run_tests.sh regression

# ---- Indespension ----
# COMMON_CONFIG_FILE=env/Indespension.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/INDESPENSION_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Indespension_RELEASE.env ./run_tests.sh regression

# ---- Insinkerator ----
# COMMON_CONFIG_FILE=env/Insinkerator.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/INSINKERATOR_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Insinkerator_EU.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/INSINKERATOR_EU_ADMIN.env ./run_tests.sh regression

# ---- JTDove ----
# COMMON_CONFIG_FILE=env/JTDove.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/JTDOVE_ADMIN.env ./run_tests.sh regression

# ---- Keylite ----
# COMMON_CONFIG_FILE=env/Keylite.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Keylite_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Keylite_RELEASE.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Keylite_ADMIN_RELEASE.env ./run_tests.sh regression

# ---- KOOL ----
# COMMON_CONFIG_FILE=env/KOOL.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/KOOL_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/KOOL_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/KOOL_ADMIN_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/KOOL_ADMIN_RELEASE.env ./run_tests.sh regression

# ---- MIPA ----
# COMMON_CONFIG_FILE=env/MIPA.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/MIPA_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/MIPA_RELEASE.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/MIPA_ADMIN_RELEASE.env ./run_tests.sh regression

# ---- Pizza Express Live ----
# COMMON_CONFIG_FILE=env/PizzaExpressLive.env ./run_tests.sh PizzaExpressLive_regression
# COMMON_CONFIG_FILE=env/PIZZAEXPRESSLIVE_ADMIN.env ./run_tests.sh regression

# ---- Russells ----
# COMMON_CONFIG_FILE=env/Russells.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/RUSSELLS_ADMIN.env ./run_tests.sh regression

# ---- Watco (UK + regional variants) ----
# COMMON_CONFIG_FILE=env/Watco.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_BEFR.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_BENL.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_DE.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_FR.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_IE.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_NL.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_PL.env ./run_tests.sh regression

# ---- Watco PROD (UK + regional variants) ----
# COMMON_CONFIG_FILE=env/Watco_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_BEFR_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_BENL_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_DE_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_FR_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_IE_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_NL_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_PL_PROD.env ./run_tests.sh regression

# ============================================================
# 2. NOTES
# ============================================================

# ---- Andy Thornton ----
# Old project, due for a rework. env/Andy_Thornton_Peracto.env was removed
# (2026-08-25) - it pointed at config/Peracto_Andy_Thornton_config/, which
# never existed, so it errored on every run; its LOGIN_URL/GUEST_URL also
# turned out to be https://staging-peracto.andythornton.pub, which is the
# Peracto Admin login (confirmed live), not a storefront - already correctly
# covered by ANDY_THORNTON_ADMIN.env below. Revisit both when the rework
# happens, in case the storefront itself is moving onto Peracto too.
# Was tagged @Andy_Thornton_regression with its own cucumber profile;
# retagged @regression and the Andy_Thornton_regression profile removed
# from src/index.ts (2026-09-10), in line with the rest of the projects.
# CONFIRMED (live, 2026-09-10): https://at-171-peracto.andythornton.pub/ is
# the AT-171 Peracto rework's ADMIN login, not a storefront - an
# Andy_Thornton_RELEASE.env pointed at it as the storefront was tried
# first and every scenario failed identically (same Peracto sign-in
# screenshot regardless of target route); removed in favour of
# ANDY_THORNTON_ADMIN_RELEASE.env below, which targets it correctly via
# config/ANDY_THORNTON_ADMIN_config/hosts.json's own release_branch host -
# treated as staging (admin is not read-only there).
#
# CONFIRMED (2026-09-10): "User Groups" is genuinely not part of this
# tenant's project (per the user directly), unlike every other Peracto
# Admin tenant using the shared suite, which already has it mapped and
# passing - so it wasn't removed from the shared Examples table, just
# split into its own @user-groups-tagged Examples block and excluded here
# via the new EXCLUDE_TAGS env var (space-separated tags, appended as
# "and not <tag>" to every profile in src/index.ts) - both
# ANDY_THORNTON_ADMIN.env and ANDY_THORNTON_ADMIN_RELEASE.env set
# EXCLUDE_TAGS=@user-groups. Reuse this same mechanism for any future
# tenant missing a different shared tab - see src/index.ts's own comment.
#
# CONFIRMED REAL BUG (live, AT-171 release branch, 2026-09-10): saving a
# Category or Shipping Service (and by the same pattern, almost certainly
# Attribute Group/Attribute Set too) shows no toast at all and the edit is
# silently discarded - reproduced live outside the test suite (filled a
# unique value, saved, waited 10s, reloaded, value was unchanged).
# Attribute/Location/Promotion saves on the same tenant work fine. Per this
# suite's "assert reality" convention, these scenarios are expected to
# stay red until the real bug is fixed.
#
# CONFIRMED TENANT DIVERGENCE (live, AT-171 release branch, 2026-09-10):
# Andy Thornton's Content module (Pages/Articles/Elements) uses a visual
# page-builder/canvas editor, not the simple form-based editor MIPA/Carbon
# Admin have - the shared editing-content.feature's selectors genuinely
# don't apply here. Not yet resolved - needs either real selectors for the
# visual builder or a tag exclusion, same EXCLUDE_TAGS mechanism as above.
#
# Andy_Thornton_PROD.env added 2026-09-14 - storefront only, targets the
# real live site (https://www.andythornton.com/, config/Andy_Thornton_
# config/hosts.json's own production host). UI_AUTOMATION_HOST=production
# means src/index.ts's productionExclusion auto-strips @places-real-order
# ("Successful guest checkout purchase" in customer-flow.feature, tagged
# 2026-09-14 - it had been missing this tag, which would otherwise have
# let a real payment attempt run against the live site).
#
# CONFIRMED (live, production, 2026-09-14): a fresh browsing context that's
# never given cookie consent shows an undismissed Cookiebot banner covering
# the lower half of the viewport, intercepting clicks/reads on anything
# under it (Add to basket, Sign In, Submit, page title) - every affected
# scenario now dismisses it via "I click on the 'Allow all cookies' button
# if present" (a no-op on staging, or any context with a stored consent
# cookie). Also hit the same add-to-basket/navigate-too-fast race already
# confirmed on MIPA's basket - fixed the same way, "I wait for the page to
# settle" before navigating to "basket".
#
# Real production login now exists (ANDY_THORNTON_PROD_LOGGED_IN_EMAIL/
# PASSWORD, grzegorz.hajduk@velstar.co.uk, password reset 2026-09-14) -
# "Successful log in" and all of my-account.feature are no longer blocked.
# logging-in.feature's "wrong password" example was fixed to use this real
# registered address instead of the "+andythornton" alias, which isn't
# actually registered (production correctly returned "Username could not
# be found" instead of "Invalid credentials" for it).
#
# my-account.feature, first live check of its account.json tab selectors
# (2026-09-14): Dashboard/Address Book/Orders confirmed genuinely correct.
# Profile is a CONFIRMED SITE BUG (raised with the site owner 2026-09-14) -
# clicking the tab never navigates to /account/profile, stays on /account -
# expected to stay red until fixed. Moodboards isn't available to the
# admin-type "logged in" account at all - it's non-admin-only, so that one
# scenario uses a dedicated "non admin" user instead (ANDY_THORNTON_
# NON_ADMIN_EMAIL/PASSWORD staging, ANDY_THORNTON_PROD_NON_ADMIN_EMAIL/
# PASSWORD production - same real account confirmed to exist on both).
#
# home.feature no longer checks "page title" (//h1) at all, not just its
# copy - confirmed live (after a first attempt to just add a settle wait
# didn't help, ruling out timing) that the visible hero banner text is a
# styled marketing/CMS block, not a real <h1> - the selector matches
# nothing on this template. "header logo" alone is the reliable check.
#
# checkout.feature: confirmed live that clicking "Checkout" doesn't
# redirect to /checkout instantly - moved "I should be redirected to the
# checkout page" into the Background so every scenario confirms it before
# acting, not just the one that happened to assert it already.
#
# reset-password-page.feature's "registered email" scenario is BLOCKED
# UNDER AUTOMATION, not broken: submitting it via Playwright surfaces
# reCAPTCHA's own "Invalid domain for site key" badge and never shows the
# success message, but the user confirmed the identical real-browser
# submission succeeds normally - same class of limitation already noted
# for /register. Expected to stay red under automation.
#
# URL bumped 2026-09-15: AT-171 -> AT-172
# (https://at-172-peracto.andythornton.pub/). Updated release_branch in
# config/ANDY_THORNTON_ADMIN_config/hosts.json and LOGIN_URL/GUEST_URL/
# LOGIN_SUCCESS_URL in env/ANDY_THORNTON_ADMIN_RELEASE.env accordingly. Not
# yet live-verified against AT-172 - the AT-171 Category/Shipping Service
# save-toast bug documented above needs rechecking there before assuming
# it's still present.

# ---- HIB ----
# NEVER place a real order for HIB (see CLAUDE.md). HIB's staging site also
# has known intermittent flakiness - don't over-invest chasing it.
# HIB_RELEASE/HIB_ADMIN_RELEASE (added 2026-09-12) target HIB's release
# branch (config/HIB_config/hosts.json and config/HIB_ADMIN_config/hosts.json's
# own release_branch host) - treated as staging (admin is not read-only
# there). HIB_ADMIN_RELEASE excludes @requires-shipping-services (per the
# user, 2026-09-12): HIB's own Shipping Services list is genuinely empty on
# this environment, out of scope for HIB's suite - see EXCLUDE_TAGS in that
# env file and the tag's own comment in editing-attributes-and-config.feature.
# A test promotion ("Automation QA Test Promo", Active, code PROMO10) was
# created live on the release branch admin (2026-09-12) so the shared
# Promotions-editing scenario has an Active row to edit - previously zero
# active promotions existed there.

# ---- JTDove ----
# Feature files were previously untagged for regression; now tagged @regression
# in line with the rest of the projects. NOTE: env/JTDove.env is missing
# USERS_CONFIG_PATH and config/JTDove_config/users.json doesn't exist yet, so
# any scenario needing a logged-in user will fail World setup until that's
# added - unrelated to tagging, flagging separately.

# ---- Keylite ----
# Storefront+admin scaffolded 2026-09-06 but never added to this reference
# file until now (2026-09-14). Keylite_ADMIN_RELEASE.env added 2026-09-14 to
# target the release branch (config/Keylite_ADMIN_config/hosts.json's own
# release_branch host, https://2-0-1-peracto.keyliteroofwindows.pub/) -
# treated as staging like MIPA/Indespension's release envs, so admin CRUD is
# fine there.

# ---- KOOL ----
# KOOL_ADMIN_RELEASE.env added 2026-09-15, targets the 2.19.0 release branch
# (config/KOOL_ADMIN_config/hosts.json's own release_branch host,
# https://2-19-0-peracto.kooltech.pub/) - treated as staging like MIPA/
# Indespension/Keylite's release envs, so admin CRUD is fine there. Not yet
# live-verified (no login/dry-run smoke test done yet) - given the KOOL
# production-orders incident (see CLAUDE.md/memory), double-check
# UI_AUTOMATION_HOST actually resolves to release_branch before any run.

# ---- MIPA ----
# Was tagged @MIPA_regression with its own cucumber profile; retagged
# @regression and the MIPA_regression profile removed from src/index.ts,
# in line with the rest of the projects. MIPA_RELEASE/MIPA_ADMIN_RELEASE
# target the Next.js-upgrade release branch (config/MIPA_config/hosts.json
# and config/MIPA_ADMIN_config/hosts.json's own release_branch host, URL
# bumped each sprint) - treated as staging, real orders OK.
#
# MIPA_ADMIN (2026-09-08+): built up a lot of scenarios beyond the shared
# Carbon_admin sweep. Most of the "editing an existing entity" ones turned
# out to be standard Peracto Admin functionality, not MIPA-specific -
# promoted to the shared Carbon_admin boilerplate (2026-09-10): Redirects
# (add/delete), Category/Promotion editing, Page/Article/Element editing,
# and Attribute/Attribute Group/Attribute Set/Location/Shipping Service
# editing. Their detail-page selectors (previously only in MIPA's config)
# were copied to every other admin tenant's config on promotion - not yet
# live-verified against every tenant individually, so watch for gaps on
# their first real runs.
#
# A second round (2026-09-10) promoted content-creation.feature (Page/
# Article create+delete via the Orphaned Pages menu) and
# product-management.feature (Product create/edit/delete) too, once the
# @mutates-admin-data tag + staging guard were added to each - both are
# real writes, verified live end-to-end on Andy Thornton (create, verify
# persistence, edit, delete, all passing, no leftover data). Also added
# BRAND NEW coverage, product-variant-management.feature (adding a Product
# Option + a Variant to a disposable product, then deleting both) - there's
# no standalone "Add Variant" button; a Product Option must be added and
# saved first, which reveals a "Manage Variants" link. Cross-verified live
# on a second tenant (MIPA) before rolling the new mapping files out
# everywhere, same as product-detail.json's earlier double-tenant check.
# Two real redirect-timing gotchas found and fixed along the way: saving a
# NEW variant doesn't redirect away from its own "/add" URL as fast as a
# new Product/Page/Article does (a loose "current URL should contain
# '.../variants/'" check matches the stale "/add" URL and passes without
# ever waiting for the real redirect - fixed with a new negated "current
# URL should not contain" step instead), and deleting a variant has the
# same delay on its way back to the list (fixed with the existing "I wait
# for the page to settle" step, since getElementLocator resolves the
# current page ID once up front and can't self-heal mid-poll).
#
# A third round (2026-09-10, same day) promoted tasks.feature too - per
# the user directly, task-triggering can't run in production but must be
# tested on release branches and staging, so the same @mutates-admin-data
# tag + staging guard pattern applies rather than keeping it MIPA-only.
# CONFIRMED (live, Andy Thornton, 2026-09-10) MIPA's own systemic
# Active-succeeds/Inactive-fails bug is NOT universal - all 16 of Andy
# Thornton's tasks are Inactive, and triggering one returned a genuine 200
# with the expected toast, so the scenario asserts the ideal (every task
# succeeds) rather than baking in MIPA's bug as expected everywhere.
# "hello_world" (excluded from scope) is standard Peracto Admin scaffolding
# confirmed present on both tenants, not a MIPA-only artifact. A fresh
# regression run the same day also caught a real reload-timing race in
# editing-content.feature's Page/Element scenarios (Save completes in
# ~0.09s with no toast to force a wait, so a reload fired while the save's
# own redirect was still in flight) - fixed with "I wait for the page to
# settle" before every reload in that file; the file's own comment
# claiming Page/Article/Element saves show no toast anywhere was also
# corrected - that's MIPA-specific, Andy Thornton does show one.
#
# A fourth round (2026-09-10, same day) promoted products-export.feature,
# file-manager.feature, and navigation-menu-items.feature after the user
# flagged Products Export directly as another example of the same "should
# be shared" pattern. Two of the three overturned earlier "MIPA-specific"
# findings that turned out to be stale, not permanent: File Manager's
# "confirmed absent on Carbon Admin" was re-checked live and found
# present and fully working there now (and on Andy Thornton) - three
# independent tenants confirmed, so the earlier finding was simply
# out of date, not wrong when made. Products Export's 9 CSV buttons were
# verified byte-for-byte (filenames + header prefixes) against Andy
# Thornton's real exports before promoting - no @mutates-admin-data
# needed, exporting is read-only. navigation-menu-items.feature (the
# Direct Link menu item) already had the @mutates-admin-data tag but was
# missing its matching "I require a staging admin" runtime guard - added
# on promotion, same double-layer pattern as everywhere else.
# image-picker.feature was promoted too, once properly investigated (a
# quick first check had grabbed the wrong button - Andy Thornton's Main
# Image field has separate "Upload"/"Browse" buttons that share the exact
# same testid, distinguished only by visible text). Once targeting the
# real "Browse" button, the scenario's confirmed bug (Category's Main
# Image field not populating after choosing a file) reproduced
# identically on Andy Thornton - genuinely universal, not MIPA-specific,
# so this is a legitimate shared "assert reality" scenario like tasks.
# feature's Inactive-task assertion, not a repeat of the Template mistake
# (which baked in a MIPA-only bug as expected everywhere). The ambiguous
# "Browse Main Image" selector was fixed with a `:has-text('Browse')`
# scope in every tenant's category-detail.json, not just where the
# ambiguity was found - a strict improvement with no downside even on a
# tenant where only one element ever matched.
#
# MIPA_ADMIN_features now only holds what's genuinely MIPA-specific:
# Product Restrictions (confirmed absent on Andy Thornton - no heading
# renders on a direct visit to that route), a couple of known-current-bug
# scenarios split out of the promoted files (a broken Page save, a broken
# Template save), and all 8 Test Harnesses (real Business Central ERP
# calls, including a real Send Order write).
# The full regression run now takes a while (~2-3 hours observed) mostly
# because of the Test Harness ERP round-trips and the tabs/redirect
# sweeps - don't be surprised if it's much slower than the other admin
# projects.

# ---- Pizza Express Live ----
# Storefront is production only (admin is read-only there per CLAUDE.md) -
# the admin project below runs against Peracto Admin on STAGING instead
# (staging-peracto.pizzaexpresslive.pub, confirmed live), so it's free to
# run like any other admin project rather than being read-only-constrained.

# ---- Russells ----
# Was tagged @Russells_regression with no matching cucumber profile defined;
# retagged @regression in line with the rest of the projects.

# ---- Watco PROD ----
# LIVE/PRODUCTION - each env file below carries its own header comment
# repeating this, but worth saying here too: never place a real order on
# production. The one Watco scenario that completes an order
# (logged-in-checkout-vat-persistence) is tagged @places-real-order, which
# is auto-excluded from every profile whenever UI_AUTOMATION_HOST is
# exactly "production" (see productionExclusion in src/index.ts) - this
# only holds as long as any future order-placing scenario is tagged the
# same way.
