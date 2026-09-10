#!/bin/bash
# Detects filename collisions between the shared Carbon_admin boilerplate
# suite and any tenant's own bespoke <PROJECT>_ADMIN_features folder.
#
# Why this exists: every Peracto Admin tenant runs the same underlying
# product (per CLAUDE.md), so it's common for someone to independently
# build a tenant-specific version of a scenario (e.g. content-creation.
# feature) before that scenario has been promoted to the shared suite.
# Once it IS promoted under the same filename, a tenant whose own
# FEATURE_PATH includes both globs silently runs BOTH copies of the same
# scenario every regression run - no error, no warning, just duplicated
# real-world actions (creating/deleting content, triggering real backend
# jobs) and double-counted scenarios in every report.
#
# CONFIRMED (live investigation, 2026-09-10): found this affecting 6
# tenants (HIB/Insinkerator/Indespension/JTDove/KOOL/Russells all actively
# double-running content-creation.feature/tasks.feature/product-management.
# feature) plus 2 more with dead/orphaned copies (Andy Thornton,
# PizzaExpressLive) - discovered only by manual inspection prompted by a
# direct user question, not by any automated check. This script exists so
# the same class of gap doesn't require another manual audit next time.
#
# Run this after promoting ANY file to src/features/Carbon_admin/, or
# periodically as a sanity check. A collision found here means: read both
# files, merge any unique CONFIRMED findings from the tenant-specific copy
# into the shared file's comments (don't lose real live-verified
# knowledge), then delete the tenant-specific copy.

set -euo pipefail
cd "$(dirname "$0")/.."

SHARED_DIR="src/features/Carbon_admin"
FOUND=0

for shared_file in "$SHARED_DIR"/*.feature; do
  name=$(basename "$shared_file")
  for tenant_dir in src/features/*_ADMIN_features src/features/*_admin_features; do
    [ -d "$tenant_dir" ] || continue
    candidate="$tenant_dir/$name"
    if [ -f "$candidate" ]; then
      echo "COLLISION: $candidate duplicates $shared_file"
      FOUND=1
    fi
  done
done

if [ "$FOUND" -eq 0 ]; then
  echo "No filename collisions found between Carbon_admin and any tenant's bespoke features folder."
else
  echo
  echo "Found collisions above - each one is a scenario silently running twice for that tenant."
  echo "Fix: merge any unique findings from the tenant copy into the shared file's comments, then delete the tenant copy."
fi
