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

# ---- KOOL ----
# COMMON_CONFIG_FILE=env/KOOL.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/KOOL_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/KOOL_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/KOOL_ADMIN_PROD.env ./run_tests.sh regression

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
# LIVE/PRODUCTION - each env file below carries its own header comment
# repeating this, but worth saying here too: never place a real order on
# production. The one Watco scenario that completes an order
# (logged-in-checkout-vat-persistence) is tagged @places-real-order, which
# is auto-excluded from every profile whenever UI_AUTOMATION_HOST is
# exactly "production" (see productionExclusion in src/index.ts) - this
# only holds as long as any future order-placing scenario is tagged the
# same way.
# COMMON_CONFIG_FILE=env/Watco_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_BEFR_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_BENL_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_DE_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_FR_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_IE_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_NL_PROD.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Watco_PL_PROD.env ./run_tests.sh regression

# ---- Insinkerator ----
# COMMON_CONFIG_FILE=env/Insinkerator.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/INSINKERATOR_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Insinkerator_EU.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/INSINKERATOR_EU_ADMIN.env ./run_tests.sh regression

# ---- HIB ----
# NEVER place a real order for HIB (see CLAUDE.md). HIB's staging site also
# has known intermittent flakiness - don't over-invest chasing it.
# COMMON_CONFIG_FILE=env/HIB.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/HIB_ADMIN.env ./run_tests.sh regression

# ---- Indespension ----
# COMMON_CONFIG_FILE=env/Indespension.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/INDESPENSION_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Indespension_RELEASE.env ./run_tests.sh regression

# ---- Carbon Admin (the shared admin suite's boilerplate source project) ----
# COMMON_CONFIG_FILE=env/CARBON_ADMIN.env ./run_tests.sh regression

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
# COMMON_CONFIG_FILE=env/Andy_Thornton.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/ANDY_THORNTON_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/ANDY_THORNTON_ADMIN_RELEASE.env ./run_tests.sh regression

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
# their first real runs. MIPA_ADMIN_features now only holds what's
# genuinely MIPA-specific: File Manager (CKFinder upload/delete, confirmed
# absent on Carbon Admin), Product Restrictions (ditto), the Image Picker
# (depends on File Manager), Products Export (its selector isn't confirmed
# anywhere else yet), Tasks and Product/Content creation (real writes kept
# out of the shared folder since it's reused by tenants with a production
# admin env - see src/index.ts's @mutates-admin-data comment), a couple of
# known-current-bug scenarios split out of the promoted files (a broken
# Page save, a broken Template save), and all 8 Test Harnesses (real
# Business Central ERP calls, including a real Send Order write). The full
# regression run now takes a while (~2-3 hours observed) mostly because of
# the Test Harness ERP round-trips and the tabs/redirect sweeps - don't be
# surprised if it's much slower than the other admin projects.
# COMMON_CONFIG_FILE=env/MIPA.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/MIPA_ADMIN.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/MIPA_RELEASE.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/MIPA_ADMIN_RELEASE.env ./run_tests.sh regression

# ---- Pizza Express Live ----
# Storefront is production only (admin is read-only there per CLAUDE.md) -
# the admin project below runs against Peracto Admin on STAGING instead
# (staging-peracto.pizzaexpresslive.pub, confirmed live), so it's free to
# run like any other admin project rather than being read-only-constrained.
# COMMON_CONFIG_FILE=env/PizzaExpressLive.env ./run_tests.sh PizzaExpressLive_regression
# COMMON_CONFIG_FILE=env/PIZZAEXPRESSLIVE_ADMIN.env ./run_tests.sh regression

# ---- JTDove ----
# Feature files were previously untagged for regression; now tagged @regression
# in line with the rest of the projects. NOTE: env/JTDove.env is missing
# USERS_CONFIG_PATH and config/JTDove_config/users.json doesn't exist yet, so
# any scenario needing a logged-in user will fail World setup until that's
# added - unrelated to tagging, flagging separately.
# COMMON_CONFIG_FILE=env/JTDove.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/JTDOVE_ADMIN.env ./run_tests.sh regression

# ---- Russells ----
# Was tagged @Russells_regression with no matching cucumber profile defined;
# retagged @regression in line with the rest of the projects.
# COMMON_CONFIG_FILE=env/Russells.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/RUSSELLS_ADMIN.env ./run_tests.sh regression
