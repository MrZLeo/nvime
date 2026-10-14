-- Integration tests use real vim.pack, local plugin remotes and disposable Git repos.
local root = assert(vim.env.NVIME_TEST_ROOT)
local config = vim.fn.stdpath("config")
local lockfile = "nvim-pack-lock.json"
local lockpath = config .. "/" .. lockfile
local messages = {}
vim.notify = function(message)
    messages[#messages + 1] = tostring(message)
end

local function git(path, ...)
    local args = { "git", "-C", path }
    vim.list_extend(args, { ... })
    local result = vim.system(args, { text = true }):wait()
    assert(result.code == 0, result.stderr .. result.stdout)
    return vim.trim(result.stdout)
end

local function init_repo(path)
    vim.fn.mkdir(path, "p")
    git(path, "init", "--quiet", "--initial-branch=main")
    git(path, "config", "user.name", "NVIME Test")
    git(path, "config", "user.email", "nvime-test@example.invalid")
    git(path, "config", "commit.gpgsign", "false")
end

local function has_message(text)
    return vim.iter(messages):any(function(message)
        return message:find(text, 1, true) ~= nil
    end)
end

local function wait_for(predicate)
    assert(vim.wait(10000, predicate, 10), "Timed out: " .. table.concat(messages, "\n"))
end

local function head()
    return git(config, "rev-parse", "HEAD")
end

local function update()
    messages = {}
    vim.cmd.PackUpdate()
    local buffer = vim.api.nvim_get_current_buf()
    assert(vim.bo[buffer].filetype == "nvim-pack", table.concat(messages, "\n"))
    return buffer
end

local function closed(buffer)
    wait_for(function()
        return not vim.api.nvim_buf_is_valid(buffer)
    end)
end

local function refuse(expected)
    local previous = head()
    local buffer = vim.api.nvim_get_current_buf()
    messages = {}
    vim.cmd.PackUpdate()
    assert(has_message(expected), table.concat(messages, "\n"))
    assert(vim.api.nvim_get_current_buf() == buffer)
    assert(head() == previous, "Refused operation created a commit")
end

local function apply_and_commit(env)
    local previous = head()
    for name, value in pairs(env or {}) do
        assert(vim.env[name] == nil, "Unexpected test environment: " .. name)
        vim.env[name] = value
    end
    local buffer = update()
    -- Reentry while reviewing must not create another confirmation buffer.
    vim.cmd.PackUpdate()
    assert(has_message("already in progress"))
    assert(vim.api.nvim_get_current_buf() == buffer)
    vim.fn.writefile({ "hold" }, root .. "/hold-commit")
    vim.cmd.write()
    -- The commit runs asynchronously; reentry must still be blocked.
    messages = {}
    vim.cmd.PackUpdate()
    assert(has_message("already in progress"), table.concat(messages, "\n"))
    assert(vim.api.nvim_get_current_buf() == buffer)
    closed(buffer)
    -- Closing the confirmation buffer must not release busy while Git is running.
    local current = vim.api.nvim_get_current_buf()
    messages = {}
    vim.cmd.PackUpdate()
    assert(has_message("already in progress"), table.concat(messages, "\n"))
    assert(vim.api.nvim_get_current_buf() == current)
    vim.fn.delete(root .. "/hold-commit")
    wait_for(function()
        return has_message("chore(plugins): update lockfile")
    end)
    for name, value in pairs(env or {}) do
        assert(vim.env[name] == value, "PackUpdate changed the parent environment: " .. name)
        vim.env[name] = nil
    end
    assert(head() ~= previous, "No commit created")
    assert(git(config, "rev-parse", "HEAD^") == previous, "Created more than one commit")
    assert(
        git(config, "diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD")
            == "nvim/" .. lockfile
    )
    assert(git(config, "diff", "HEAD", "--", lockfile) == "", "Lockfile not fully committed")
    local lock = vim.json.decode(table.concat(vim.fn.readfile(lockpath), "\n"))
    for _, plugin in ipairs(vim.pack.get()) do
        assert(lock.plugins[plugin.spec.name].rev == git(plugin.path, "rev-parse", "HEAD"))
    end
end

local ok, err = pcall(function()
    local sources = {}
    local specs = {}
    for _, name in ipairs({ "fixture-one", "fixture-two" }) do
        local path = root .. "/plugin sources/" .. name
        init_repo(path)
        vim.fn.writefile({ "initial" }, path .. "/README.md")
        git(path, "add", "README.md")
        git(path, "commit", "--quiet", "-m", "initial")
        sources[name] = path
        specs[#specs + 1] = { src = "file://" .. path, name = name }
    end
    local revision = 0
    local function advance(name)
        revision = revision + 1
        vim.fn.writefile({ "revision " .. revision }, sources[name] .. "/README.md")
        git(sources[name], "commit", "--quiet", "-am", "update " .. revision)
    end

    -- The config is nested inside a dotfiles repository, not its repository root.
    init_repo(vim.env.XDG_CONFIG_HOME)
    vim.pack.add(specs, { confirm = false, load = false })
    vim.fn.writefile({ "initial" }, config .. "/notes.lua")
    git(config, "add", lockfile, "notes.lua")
    git(config, "commit", "--quiet", "-m", "initial config")
    local initial = head()

    -- Run the command from an unrelated repository.
    local other = root .. "/another project"
    init_repo(other)
    vim.fn.writefile({ "{}" }, other .. "/" .. lockfile)
    git(other, "add", lockfile)
    git(other, "commit", "--quiet", "-m", "unrelated")
    local other_head = git(other, "rev-parse", "HEAD")
    vim.fn.writefile({ '{"unrelated":true}' }, other .. "/" .. lockfile)
    local other_diff = git(other, "diff", "--", lockfile)
    vim.cmd.cd(other)
    vim.opt.runtimepath:prepend(assert(vim.env.NVIME_REPO_ROOT))
    require("utils")

    -- Keep staged AND unstaged changes in the same unrelated file throughout.
    vim.fn.writefile({ "staged" }, config .. "/notes.lua")
    git(config, "add", "notes.lua")
    vim.fn.writefile({ "unstaged" }, config .. "/notes.lua")
    local staged = git(config, "diff", "--cached", "--", "notes.lua")
    local unstaged = git(config, "diff", "--", "notes.lua")

    -- Hooks must see only the lockfile, not the other staged Lua file.
    local hooks = root .. "/hooks"
    vim.fn.mkdir(hooks, "p")
    vim.fn.writefile({
        "#!/bin/sh",
        'test "$(git diff --cached --name-only)" = "nvim/nvim-pack-lock.json" || exit 1',
        'if test -f "$NVIME_TEST_ROOT/fail-commit"; then',
        '  echo "intentional hook failure" >&2; exit 1',
        "fi",
        'while test -f "$NVIME_TEST_ROOT/hold-commit"; do sleep 0.01; done',
    }, hooks .. "/pre-commit")
    assert(vim.uv.fs_chmod(hooks .. "/pre-commit", 493))
    git(config, "config", "core.hooksPath", hooks)

    -- No-op confirmations and cancellation never commit, even with a dirty lockfile.
    vim.fn.writefile({ "" }, lockpath, "a")
    local buffer = update()
    vim.cmd.write()
    closed(buffer)
    assert(head() == initial)
    advance("fixture-one")
    buffer = update()
    vim.cmd.quit()
    closed(buffer)
    assert(head() == initial)
    assert(git(config, "diff", "--", lockfile) ~= "")

    -- Two plugin updates produce one commit, capturing the final complete lockfile.
    advance("fixture-two")
    apply_and_commit()
    print("PASS: batched updates, cancellation, no-op, cwd and index isolation")

    -- Inherited Git routing must not redirect checks or commits to another checkout.
    advance("fixture-one")
    apply_and_commit({ GIT_DIR = other .. "/.git", GIT_WORK_TREE = other })
    assert(git(other, "rev-parse", "HEAD") == other_head)
    assert(git(other, "diff", "--", lockfile) == other_diff)
    print("PASS: inherited Git environment isolation")

    -- A failed hook leaves updated plugins/lockfile available for manual recovery.
    advance("fixture-one")
    local previous = head()
    vim.fn.writefile({ "fail" }, root .. "/fail-commit")
    buffer = update()
    vim.cmd.write()
    wait_for(function()
        return has_message("intentional hook failure")
    end)
    closed(buffer)
    assert(head() == previous)
    assert(git(config, "diff", "--", lockfile) ~= "")
    assert(git(config, "diff", "--cached", "--", lockfile) == "")
    vim.fn.delete(root .. "/fail-commit")

    -- Existing staged lockfile changes are never silently replaced.
    git(config, "add", lockfile)
    refuse("already staged")
    -- The guard must inspect the config's real index, not an inherited index file.
    vim.env.GIT_INDEX_FILE = other .. "/.git/index"
    refuse("already staged")
    assert(vim.env.GIT_INDEX_FILE == other .. "/.git/index")
    vim.env.GIT_INDEX_FILE = nil
    git(config, "reset", "--quiet", "HEAD", "--", lockfile)
    git(config, "commit", "--quiet", "--only", "-m", "manual recovery", "--", lockfile)

    -- Recheck Git state after the user has spent time in the confirmation buffer.
    advance("fixture-one")
    previous = head()
    buffer = update()
    vim.fn.writefile({ "" }, lockpath, "a")
    git(config, "add", lockfile)
    vim.cmd.write()
    closed(buffer)
    assert(has_message("auto-commit was skipped"))
    assert(head() == previous)
    git(config, "reset", "--quiet", "HEAD", "--", lockfile)
    git(config, "commit", "--quiet", "--only", "-m", "manual recovery", "--", lockfile)
    print("PASS: failed hooks, staged lockfile protection and post-confirmation recheck")

    -- A checkout failure in one plugin must not commit a partially successful batch.
    advance("fixture-one")
    advance("fixture-two")
    previous = head()
    buffer = update()
    local plugin_index = vim.fn.stdpath("data") .. "/site/pack/core/opt/fixture-one/.git/index.lock"
    vim.fn.writefile({ "locked" }, plugin_index)
    vim.cmd.write()
    closed(buffer)
    assert(has_message("Some plugin updates failed"), table.concat(messages, "\n"))
    assert(head() == previous)
    vim.fn.delete(plugin_index)
    apply_and_commit()
    print("PASS: partial update failures and subsequent retry")

    -- The raw API remains opt-out: a confirmed update creates no config commit.
    advance("fixture-one")
    previous = head()
    vim.pack.update()
    buffer = vim.api.nvim_get_current_buf()
    vim.cmd.write()
    closed(buffer)
    assert(head() == previous)
    assert(git(config, "diff", "--", lockfile) ~= "")
    git(config, "commit", "--quiet", "--only", "-m", "manual raw update", "--", lockfile)

    git(config, "checkout", "--quiet", "--detach")
    refuse("detached HEAD")
    git(config, "checkout", "--quiet", "main")
    for _, marker in ipairs({
        "MERGE_HEAD",
        "CHERRY_PICK_HEAD",
        "REVERT_HEAD",
        "rebase-merge",
        "rebase-apply",
        "sequencer",
    }) do
        local path = git(config, "rev-parse", "--path-format=absolute", "--git-path", marker)
        vim.fn.writefile({ head() }, path)
        refuse("Finish the current Git")
        vim.fn.delete(path)
    end

    local gitdir = vim.env.XDG_CONFIG_HOME .. "/.git"
    assert(vim.uv.fs_rename(gitdir, gitdir .. "-hidden"))
    messages = {}
    vim.cmd.PackUpdate()
    assert(has_message("Auto-commit unavailable"))
    assert(vim.uv.fs_rename(gitdir .. "-hidden", gitdir))
    assert(git(config, "diff", "--cached", "--", "notes.lua") == staged)
    assert(git(config, "diff", "--", "notes.lua") == unstaged)
    assert(git(other, "rev-parse", "HEAD") == other_head)
    assert(git(other, "diff", "--", lockfile) == other_diff)
    print(
        "PASS: raw API unchanged, detached/in-progress/non-Git guards; unrelated changes preserved"
    )
end)

if not ok then
    vim.api.nvim_err_writeln(tostring(err))
    vim.cmd.cquit()
end
print("PASS: PackUpdate integration tests")
