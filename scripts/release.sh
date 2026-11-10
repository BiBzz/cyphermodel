#!/usr/bin/env bash
#
# Tag a release: the version is merged through a merge request first, then this
# script signs the tag; the GitLab mirror carries it to GitHub, whose Release
# workflow publishes to PyPI.
#
#   scripts/release.sh [--yes]
#
# It refuses to tag from another branch, a tree that differs from origin, an
# unsigned commit or a version already tagged.

set -euo pipefail

RELEASE_BRANCH="${RELEASE_BRANCH:-development}"
REMOTE=origin

die() { printf 'release: %s\n' "$1" >&2; exit 1; }
step() { printf '\n==> %s\n' "$1"; }

assume_yes=false
for arg in "$@"; do
    case "$arg" in
        -y | --yes) assume_yes=true ;;
        *) die "unknown argument ${arg}" ;;
    esac
done

cd "$(dirname "$0")/.."

step "Checking the working tree"
branch="$(git branch --show-current)"
[ "$branch" = "$RELEASE_BRANCH" ] || die "releases are tagged on ${RELEASE_BRANCH}, not ${branch}"
git diff-index --quiet HEAD -- || die "the tracked files have uncommitted changes"
version="$(sed -n 's/^version = "\(.*\)"$/\1/p' pyproject.toml)"
[ -n "$version" ] || die "cannot read the version from pyproject.toml"
tag="v${version}"
! git rev-parse -q --verify "refs/tags/${tag}" >/dev/null || die "tag ${tag} already exists locally"

step "Checking ${REMOTE}"
git fetch --quiet "$REMOTE" "$RELEASE_BRANCH"
[ "$(git rev-parse HEAD)" = "$(git rev-parse FETCH_HEAD)" ] ||
    die "${RELEASE_BRANCH} differs from ${REMOTE}/${RELEASE_BRANCH}, pull first"
[ -z "$(git ls-remote --tags "$REMOTE" "refs/tags/${tag}")" ] || die "tag ${tag} already exists on ${REMOTE}"
[ "$(git log -1 --format=%G?)" = "G" ] || die "the released commit is not signed with a trusted key"

step "Replaying the checks the Release workflow runs"
uv sync --frozen --quiet --group docs
uv run zensical build --clean >/dev/null
uv build --quiet --out-dir "$(mktemp -d)"

step "Signing ${tag}"
git tag --sign -m "Release ${version}" "$tag"
git tag -v "$tag" >/dev/null 2>&1 || die "the tag signature does not verify"

if ! $assume_yes; then
    printf '\nPush %s to %s? [y/N] ' "$tag" "$REMOTE"
    read -r answer
    case "$answer" in
        [yY] | [yY][eE][sS]) ;;
        *) die "nothing pushed. To undo: git tag -d ${tag}" ;;
    esac
fi

git push "$REMOTE" "$tag"
printf '\n%s is pushed. Once the mirror carries it to GitHub, approve the pypi environment:\n  %s\n' \
    "$tag" "https://github.com/BiBzz/cyphermodel/actions/workflows/release.yml"
