local uv = vim.uv or vim.loop

local function fail(message)
    local messages = vim.api.nvim_exec2("messages", { output = true }).output
    if messages ~= "" then
        vim.api.nvim_err_writeln(messages)
    end
    vim.api.nvim_err_writeln(message)
    vim.cmd("cquit")
end

local function assert_file(path, label)
    local stat = uv.fs_stat(path)
    if not stat or stat.type ~= "file" then
        fail(("Missing %s: %s"):format(label, path))
    end
    print(("Found %s: %s"):format(label, path))
end

local function wait_for(label, start)
    local done = false
    local err = nil
    local result = nil

    local ok, start_err = pcall(start, function(callback_err, callback_result)
        err = callback_err
        result = callback_result
        done = true
    end)

    if not ok then
        fail(("Failed to start %s: %s"):format(label, start_err))
    end

    if not vim.wait(180000, function()
        return done
    end, 250, false) then
        fail(("Timed out waiting for %s"):format(label))
    end

    if err then
        fail(("Failed to prepare %s: %s"):format(label, err))
    end

    return result
end

local function native_extension()
    local sysname = uv.os_uname().sysname:lower()
    if sysname == "darwin" then
        return ".dylib"
    end
    if sysname:find("windows", 1, true) then
        return ".dll"
    end
    return ".so"
end

local function packadd(plugin)
    local ok, err = pcall(vim.cmd.packadd, plugin)
    if not ok then
        fail(("Failed to load %s: %s"):format(plugin, err))
    end
end

packadd("blink.lib")
packadd("blink.cmp")
packadd("blink.pairs")

if vim.v.errmsg ~= "" then
    fail(vim.v.errmsg)
end

local ok_cmp_config, cmp_config = pcall(require, "blink.cmp.config")
if not ok_cmp_config then
    fail("blink.cmp config is not available: " .. tostring(cmp_config))
end

cmp_config.fuzzy.implementation = "rust"
cmp_config.fuzzy.prebuilt_binaries.force_version = cmp_config.fuzzy.prebuilt_binaries.force_version
    or "v*"

local ok_cmp_download, cmp_download = pcall(require, "blink.cmp.fuzzy.download")
if not ok_cmp_download then
    fail("blink.cmp fuzzy downloader is not available: " .. tostring(cmp_download))
end

local cmp_implementation = wait_for("blink.cmp fuzzy native library", function(done)
    cmp_download.ensure_downloaded(done)
end)

if cmp_implementation ~= "rust" then
    fail(
        ("blink.cmp fuzzy matcher resolved to %s, expected rust"):format(
            tostring(cmp_implementation)
        )
    )
end

local cmp_files = require("blink.cmp.fuzzy.download.files")
assert_file(cmp_files.lib_path, "blink.cmp fuzzy library")
assert_file(cmp_files.checksum_path, "blink.cmp fuzzy checksum")
assert_file(cmp_files.version_path, "blink.cmp fuzzy version")

local ok_pairs, pairs = pcall(require, "blink.pairs")
if not ok_pairs then
    fail("blink.pairs is not available: " .. tostring(pairs))
end

wait_for("blink.pairs native library", function(done)
    pairs.download_if_available(function(err)
        done(err, true)
    end)
end)

local ok_pairs_rust, pairs_rust_err = pcall(require, "blink.pairs.rust")
if not ok_pairs_rust then
    fail("blink.pairs native library is not loadable: " .. tostring(pairs_rust_err))
end

local pairs_source = debug.getinfo(pairs.download_if_available, "S").source:gsub("^@", "")
local pairs_root = pairs_source:gsub("/lua/blink/pairs/init%.lua$", "")
if pairs_root == pairs_source then
    fail("Failed to resolve blink.pairs plugin root from " .. pairs_source)
end

assert_file(
    pairs_root .. "/target/release/libblink_pairs" .. native_extension(),
    "blink.pairs native library"
)
assert_file(pairs_root .. "/target/release/version", "blink.pairs native version")
