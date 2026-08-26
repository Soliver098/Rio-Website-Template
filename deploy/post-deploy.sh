#!/bin/bash
set -e
set -u

# Deploy script for rio-website-template's `development`/`production` Plesk vhosts
# (rio-website-template.development.rio-ecosystem.nl / rio-website-template.production.rio-ecosystem.nl
# — repo-first hostname ordering, matching rio-web-app-template's own convention).
#
# NOT YET USABLE: as of 2026-08-26 neither vhost has been provisioned in Plesk — no deploymentPath
# entry exists in git_db.db and no vhost directory exists on disk (confirmed via SSH). This repo's
# own CLAUDE.md previously said it is "not itself deployed" (it's a scaffold that other plain-PHP
# Rio websites are cloned from, analogous to rio-web-app-template) — this script is written ahead
# of any such vhost existing, for consistency with the rest of the ecosystem's submodule-deploy
# fix, in case a live demo vhost is ever provisioned for it the way rio-web-app-template has one.
# Do not attempt to run this until that vhost exists.
#
# Root cause this fixes (once a vhost exists): Plesk's git "pull" deploy mode is a file-copy-style
# deploy — no `.git` ever exists in the deployed webspace. A git submodule is just a commit
# reference, not files, so every `submodules/<name>/` directory in the deployed webspace arrives
# completely empty. This script re-populates each submodule as its own independent, standalone git
# clone — NOT `git submodule update` at the parent level, which structurally can't work here
# (there's no parent `.git` to read). Same proven pattern as
# rio-web-app-template/deploy/development-post-deploy.sh.
#
# NOT wired up to Plesk's own "Additional deployment actions" git-extension feature — run this by
# hand over SSH, as the vhost's own system user, after every push to `development`/`production`,
# once the vhost exists:
#   sudo -u rio-ecosystem.nl bash /var/www/vhosts/rio-ecosystem.nl/rio-website-template.development.rio-ecosystem.nl/deploy/post-deploy.sh development
#   sudo -u rio-ecosystem.nl bash /var/www/vhosts/rio-ecosystem.nl/rio-website-template.production.rio-ecosystem.nl/deploy/post-deploy.sh production
#
# Uses the shared, subscription-level deploy SSH key (not per-repo — nothing to provision).
# `git config --global safe.directory '*'` is already set for the rio-ecosystem.nl system user.
#
# Tracks each submodule's configured branch tip (see populate() calls below), not the
# superproject's exact pinned commit — simpler to get at from a plain checked-out working tree
# with no access back to the bare repo that recorded that exact pin.
#
# No npm/build step — this repo has no package.json/build step at all (see CLAUDE.md).

ENV="${1:-}"
case "$ENV" in
  development|production) ;;
  *)
    echo "Usage: $0 <development|production>" >&2
    exit 1
    ;;
esac

WORK_TREE="/var/www/vhosts/rio-ecosystem.nl/rio-website-template.${ENV}.rio-ecosystem.nl"
export GIT_SSH_COMMAND="ssh -i /var/www/vhosts/rio-ecosystem.nl/.ssh/id_rsa -o UserKnownHostsFile=/var/www/vhosts/rio-ecosystem.nl/.ssh/git_known_hosts -o BatchMode=yes"

cd "$WORK_TREE"

# Plesk's own auto-checkout-on-push occasionally leaves this directory at mode 750 (owner-only
# traversal) instead of Plesk's usual 755 - Apache's own worker (user `apache`, not in this
# vhost's group) then can't even read .htaccess-checking metadata and 403s everything. Cheap to
# re-assert every run.
chmod 755 "$WORK_TREE"

populate() {
  path="$1"; url="$2"; branch="$3"
  if [ -d "$path/.git" ]; then
    git -C "$path" fetch --quiet origin "$branch"
  else
    rm -rf "$path"
    git clone --quiet --branch "$branch" --single-branch "$url" "$path"
  fi
  git -C "$path" checkout --quiet --force "$branch"
  git -C "$path" reset --quiet --hard "origin/$branch"
  git -C "$path" submodule sync --recursive --quiet
  git -C "$path" submodule update --init --recursive --quiet
}

populate submodules/rio-website        git@github.com:Soliver098/rio-website.git         production
populate submodules/rio-style          git@github.com:Soliver098/rio-style.git           production
populate submodules/rio-monitor-sdk    git@github.com:Soliver098/rio-monitor-sdk.git     production
populate submodules/rio-translation-sdk git@github.com:Soliver098/rio-translation-sdk.git production
