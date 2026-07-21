#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
release_branch="${NVIME_RELEASE_BRANCH:-master}"
release_remote="${NVIME_RELEASE_REMOTE:-origin}"
dry_run=false
push_tag=false
upstream_version=""

usage() {
    cat <<'EOF'
Usage: bash scripts/create-release-tag.sh [OPTIONS]

Create the next NVIME release tag for the current Neovim version.

Options:
  --dry-run          Print the next tag without creating it
  --push             Push the new tag to the release remote
  --version VERSION  Use a specific Neovim version, such as 0.12.5
  -h, --help         Show this help

Environment:
  NVIME_RELEASE_BRANCH  Branch that may be tagged (default: master)
  NVIME_RELEASE_REMOTE  Remote used for checks and pushes (default: origin)
EOF
}

die() {
    echo "Error: $*" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            dry_run=true
            ;;
        --push)
            push_tag=true
            ;;
        --version)
            [[ $# -ge 2 ]] || die "--version requires a value"
            upstream_version="${2#v}"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown option: $1"
            ;;
    esac
    shift
done

if [[ "$dry_run" == "true" && "$push_tag" == "true" ]]; then
    die "--dry-run and --push cannot be used together"
fi

git -C "$repo_root" rev-parse --git-dir >/dev/null 2>&1 || die "not inside a Git repository"

current_branch="$(git -C "$repo_root" symbolic-ref --quiet --short HEAD || true)"
if [[ -z "$current_branch" ]]; then
    die "cannot create a release tag from a detached HEAD"
fi
if [[ "$current_branch" != "$release_branch" ]]; then
    die "release tags must be created from '$release_branch' (current branch: '$current_branch')"
fi

if [[ -n "$(git -C "$repo_root" status --porcelain)" ]]; then
    die "the working tree is not clean"
fi

remote_ref="refs/remotes/${release_remote}/${release_branch}"
if ! git -C "$repo_root" show-ref --verify --quiet "$remote_ref"; then
    die "remote-tracking branch '${release_remote}/${release_branch}' does not exist; fetch it first"
fi

head_commit="$(git -C "$repo_root" rev-parse HEAD)"
remote_commit="$(git -C "$repo_root" rev-parse "$remote_ref")"
if [[ "$head_commit" != "$remote_commit" ]]; then
    die "HEAD must match '${release_remote}/${release_branch}'; push or update the branch first"
fi

if [[ -z "$upstream_version" ]]; then
    upstream_version="$(bash "$repo_root/scripts/ci-resolve-nvim-version.sh")"
    upstream_version="${upstream_version#v}"
fi

if [[ ! "$upstream_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    die "Neovim version must have the form <major>.<minor>.<patch>: $upstream_version"
fi

version_pattern="${upstream_version//./\\.}"
latest_revision=-1
latest_tag=""
while IFS= read -r tag; do
    if [[ "$tag" =~ ^v${version_pattern}\.([0-9]+)$ ]]; then
        revision=$((10#${BASH_REMATCH[1]}))
        if (( revision > latest_revision )); then
            latest_revision=$revision
            latest_tag="$tag"
        fi
    fi
done < <(git -C "$repo_root" tag --list "v${upstream_version}.*")

next_revision=$((latest_revision + 1))
version="v${upstream_version}.${next_revision}"

if [[ -n "$latest_tag" ]]; then
    if ! git -C "$repo_root" merge-base --is-ancestor "$latest_tag" HEAD; then
        die "latest series tag '$latest_tag' is not an ancestor of HEAD"
    fi
    latest_tag_commit="$(git -C "$repo_root" rev-parse "${latest_tag}^{commit}")"
    if [[ "$latest_tag_commit" == "$head_commit" ]]; then
        die "there are no commits since $latest_tag"
    fi
fi

if git -C "$repo_root" show-ref --tags --verify --quiet "refs/tags/$version"; then
    die "tag already exists: $version"
fi

echo "Release tag: $version"
echo "Target:      $head_commit"

if [[ "$dry_run" == "true" ]]; then
    echo "Dry run: no tag was created."
    exit 0
fi

git -C "$repo_root" tag -a "$version" -m "Release $version"
echo "Created annotated tag $version."

if [[ "$push_tag" == "true" ]]; then
    git -C "$repo_root" push "$release_remote" "refs/tags/$version"
    echo "Pushed $version to $release_remote."
else
    echo "Push it when ready with: git push $release_remote refs/tags/$version"
fi
