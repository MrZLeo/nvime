#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tag_pattern="${NVIME_RELEASE_TAG_PATTERN:-v*.*.*.*}"
release_branch="${NVIME_RELEASE_BRANCH:-master}"

write_output() {
    local key="$1"
    local value="$2"

    if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
        printf '%s=%s\n' "$key" "$value" >> "$GITHUB_OUTPUT"
    else
        printf '%s=%s\n' "$key" "$value"
    fi
}

extract_upstream_version() {
    local release_version="${1#v}"
    local major minor patch revision extra

    IFS=. read -r major minor patch revision extra <<< "$release_version"

    if [[ -z "$major" || -z "$minor" || -z "$patch" || -z "$revision" || -n "${extra:-}" ]]; then
        return 1
    fi

    printf '%s.%s.%s\n' "$major" "$minor" "$patch"
}

emit_release() {
    local version="$1"
    local upstream_version="$2"

    write_output "should_release" "true"
    write_output "version" "$version"
    write_output "release_ref" "$version"
    write_output "nvim_version" "$upstream_version"
}

emit_skip() {
    write_output "should_release" "false"
    write_output "version" ""
    write_output "release_ref" ""
    write_output "nvim_version" ""
}

event_name="${GITHUB_EVENT_NAME:-}"
ref_type="${GITHUB_REF_TYPE:-}"
ref_name="${GITHUB_REF_NAME:-}"

if [[ "$event_name" == "push" && "$ref_type" == "tag" ]]; then
    upstream_version="$(extract_upstream_version "$ref_name")" || {
        echo "Release tag must match v<neovim-major>.<neovim-minor>.<neovim-patch>.<nvime-revision>." >&2
        exit 1
    }
    emit_release "$ref_name" "$upstream_version"
    exit 0
fi

if [[ "$event_name" != "schedule" ]]; then
    emit_skip
    exit 0
fi

latest_tag="$(git tag --list "$tag_pattern" --sort=-v:refname | head -n 1 || true)"

if [[ -n "$latest_tag" ]]; then
    commits_since_last_tag="$(git rev-list --count "${latest_tag}..HEAD")"
    if [[ "$commits_since_last_tag" == "0" ]]; then
        echo "No commits on ${release_branch} since ${latest_tag}; skipping scheduled release."
        emit_skip
        exit 0
    fi
fi

upstream_version="${NVIME_RELEASE_UPSTREAM_VERSION:-}"
if [[ -z "$upstream_version" ]]; then
    bin_dir="$(bash "$repo_root/scripts/ci-install-nvim.sh" --print-bin-dir)"
    export PATH="$bin_dir:$PATH"
    upstream_version="$(nvim --version | sed -n '1s/^NVIM v//p' | tr -d '\r')"
fi

if [[ -z "$upstream_version" ]]; then
    echo "Failed to determine the Neovim version for release tagging." >&2
    exit 1
fi

series_latest_tag="$(git tag --list "v${upstream_version}.*" --sort=-v:refname | head -n 1 || true)"
if [[ -n "$series_latest_tag" ]]; then
    next_revision=$(( ${series_latest_tag##*.} + 1 ))
else
    next_revision=0
fi

version="v${upstream_version}.${next_revision}"

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git tag -a "$version" -m "Release $version"
git push origin "refs/tags/$version"

emit_release "$version" "$upstream_version"
