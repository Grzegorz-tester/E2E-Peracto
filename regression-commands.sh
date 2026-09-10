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
# Andy_Thornton_RELEASE targets the AT-171 Peracto rework release branch
# (config/Andy_Thornton_config/hosts.json's own release_branch host) -
# treated as staging, real orders OK.
# COMMON_CONFIG_FILE=env/Andy_Thornton.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/Andy_Thornton_RELEASE.env ./run_tests.sh regression
# COMMON_CONFIG_FILE=env/ANDY_THORNTON_ADMIN.env ./run_tests.sh regression

# ---- MIPA ----
# Was tagged @MIPA_regression with its own cucumber profile; retagged
# @regression and the MIPA_regression profile removed from src/index.ts,
# in line with the rest of the projects. MIPA_RELEASE/MIPA_ADMIN_RELEASE
# target the Next.js-upgrade release branch (config/MIPA_config/hosts.json
# and config/MIPA_ADMIN_config/hosts.json's own release_branch host, URL
# bumped each sprint) - treated as staging, real orders OK.
#
# MIPA_ADMIN (2026-09-08+): now covers a lot more than the shared
# Carbon_admin sweep - File Manager (CKFinder upload/delete), Products
# Export (all 9 export buttons), all 8 Test Harnesses (real Business
# Central ERP calls, including a real Send Order write), Product
# Restrictions, editing an existing Category/Promotion, and adding/
# deleting a Redirect. The full regression run now takes a while (~2-3
# hours observed) mostly because of the Test Harness ERP round-trips and
# the tabs/redirect sweeps - don't be surprised if it's much slower than
# the other admin projects.
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
