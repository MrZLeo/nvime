#!/usr/bin/env python3
"""Prepare/stage upstream Blink libraries for existing vim.pack release bundles.

Does not manage plugins or modify Lua configuration. Preparation requires the
plugin checkouts already bootstrapped by Neovim from nvim-pack-lock.json.
"""

import argparse
import hashlib
import json
import os
import platform
import re
import shutil
import subprocess
import sys
from pathlib import Path

PLATFORMS = {
    ("Darwin", "arm64"): ("aarch64-apple-darwin", ".dylib"),
    ("Linux", "aarch64"): ("aarch64-unknown-linux-gnu", ".so"),
    ("Linux", "arm64"): ("aarch64-unknown-linux-gnu", ".so"),
    ("Linux", "x86_64"): ("x86_64-unknown-linux-gnu", ".so"),
}
PLUGINS = ("blink.lib", "blink.cmp", "blink.pairs")


def run(*args):
    return subprocess.check_output(args, text=True).strip()


def fetch(url):
    command = [
        "curl",
        "--fail",
        "--silent",
        "--show-error",
        "--location",
        "--retry",
        "3",
        "--retry-all-errors",
        "--max-time",
        "180",
        url,
    ]
    config = None
    token = os.environ.get("GITHUB_TOKEN")
    if token and url.startswith("https://api.github.com/"):
        # Avoid unauthenticated runner rate limits. Keep the token out of argv,
        # exceptions, logs, artifact metadata and release-asset download requests.
        command.extend(["--config", "-"])
        config = (
            "header = " + json.dumps("Authorization: Bearer " + token) + "\n"
        ).encode()
    return subprocess.check_output(command, input=config)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def relative_path(value):
    path = Path(value)
    if path.is_absolute() or not path.parts or ".." in path.parts:
        raise ValueError(f"Unsafe artifact path: {value}")
    return path


def exact_tag(source, revision):
    refs = {}
    for line in run("git", "ls-remote", "--tags", source).splitlines():
        sha, ref = line.split()
        refs[ref.removeprefix("refs/tags/")] = sha
    tags = [
        tag
        for tag in refs
        if re.fullmatch(r"v\d+\.\d+\.\d+", tag)
        and refs.get(tag + "^{}", refs[tag]) == revision
    ]
    if not tags:
        raise ValueError(f"No exact stable release tag for {source} at {revision}")
    return max(tags, key=lambda tag: tuple(map(int, tag[1:].split("."))))


def write_asset(root, relative, data, files):
    path = root / relative_path(relative)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + ".ci-tmp")
    temporary.write_bytes(data)
    temporary.replace(path)
    files[str(relative)] = digest(data)


def prepare(args):
    triple, extension = PLATFORMS[(platform.system(), platform.machine())]
    locked = json.loads(args.lock.read_text())["plugins"]
    checkouts = args.data_root / "site/pack/core/opt"
    for name in PLUGINS:
        if (
            run("git", "-C", str(checkouts / name), "rev-parse", "HEAD")
            != locked[name]["rev"]
        ):
            raise ValueError(f"{name} checkout does not match nvim-pack-lock.json")

    files = {}
    native = {}
    for name in ("blink.cmp", "blink.pairs"):
        plugin = locked[name]
        match = re.fullmatch(r"https://github\.com/([\w.-]+/[\w.-]+)", plugin["src"])
        if not match:
            raise ValueError(f"Unsupported plugin source: {plugin['src']}")
        tag = exact_tag(plugin["src"], plugin["rev"])
        checkout = str(checkouts / name)
        ref = f"refs/tags/{tag}"
        if subprocess.run(
            ["git", "-C", checkout, "show-ref", "--verify", "--quiet", ref],
            check=False,
        ).returncode:
            run(
                "git",
                "-C",
                checkout,
                "fetch",
                "--no-tags",
                plugin["src"],
                f"{ref}:{ref}",
            )
        if (
            run("git", "-C", checkout, "rev-parse", f"{ref}^{{commit}}")
            != plugin["rev"]
        ):
            raise ValueError(
                f"Local release tag does not match locked revision: {name}/{tag}"
            )
        release = json.loads(
            fetch(f"https://api.github.com/repos/{match[1]}/releases/tags/{tag}")
        )
        if release.get("draft") or release.get("tag_name") != tag:
            raise ValueError(f"Not a published release: {name}/{tag}")
        filename = triple + extension
        asset = next(asset for asset in release["assets"] if asset["name"] == filename)
        url = f"{plugin['src']}/releases/download/{tag}/{filename}"
        data = fetch(url)
        sha = digest(data)
        if asset.get("digest") != "sha256:" + sha:
            raise ValueError(
                f"Missing or mismatched upstream asset digest: {name}/{filename}"
            )
        base = Path("site/pack/core/opt") / name
        if name == "blink.cmp":
            checksum = fetch(url + ".sha256")
            if checksum.decode().split()[0] != sha:
                raise ValueError("blink.cmp upstream checksum mismatch")
            library = base / "target/release" / ("libblink_cmp_fuzzy" + extension)
            write_asset(args.data_root, library, data, files)
            write_asset(args.data_root, str(library) + ".sha256", checksum, files)
            write_asset(
                args.data_root, base / "target/release/version", tag.encode(), files
            )
        else:
            library = (
                base
                / "lib"
                / ("libblink_pairs_parser" + extension + "." + plugin["rev"][:7])
            )
            write_asset(args.data_root, library, data, files)
        native[name] = {"rev": plugin["rev"], "tag": tag, "url": url, "sha256": sha}
        print(f"Prepared {name} {tag}: {filename}")

    manifest = {
        "schema": 1,
        "triple": triple,
        "plugins": {name: locked[name]["rev"] for name in PLUGINS},
        "native": native,
        "files": files,
    }
    args.manifest.parent.mkdir(parents=True, exist_ok=True)
    args.manifest.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")


def verify(args):
    manifest = json.loads(args.manifest.read_text())
    if manifest.get("schema") != 1:
        raise ValueError("Unknown Blink manifest schema")
    for relative, expected_hash in manifest["files"].items():
        source = args.data_root / relative_path(relative)
        if digest(source.read_bytes()) != expected_hash:
            raise ValueError(f"Prepared native asset changed: {relative}")
    return manifest


def stage(args):
    manifest = verify(args)
    for relative in manifest["files"]:
        relative = relative_path(relative)
        source = args.data_root / relative
        destination = args.destination / relative
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)
    # Source metadata (.git) must remain with the installed vim.pack checkouts.
    for name, expected_revision in manifest["plugins"].items():
        checkout = args.destination / "site/pack/core/opt" / name
        if run("git", "-C", str(checkout), "rev-parse", "HEAD") != expected_revision:
            raise ValueError(f"Staged checkout revision mismatch: {name}")
    print("Staged only the verified native libraries and required metadata")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    for command in ("prepare", "stage", "verify"):
        sub = commands.add_parser(command)
        sub.add_argument("--data-root", required=True, type=Path)
        sub.add_argument("--manifest", required=True, type=Path)
        if command == "prepare":
            sub.add_argument("--lock", required=True, type=Path)
        elif command == "stage":
            sub.add_argument("--destination", required=True, type=Path)
    args = parser.parse_args()
    {"prepare": prepare, "stage": stage, "verify": verify}[args.command](args)


if __name__ == "__main__":
    try:
        main()
    except (
        KeyError,
        StopIteration,
        ValueError,
        OSError,
        subprocess.CalledProcessError,
    ) as error:
        sys.exit(f"Blink release preparation failed: {error}")
