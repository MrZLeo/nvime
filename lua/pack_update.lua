local M = {}
local busy = false
local lockfile = "nvim-pack-lock.json"

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "PackUpdate" })
end

local function finish(message, level)
    busy = false
    if message then
        notify(message, level)
    end
end

local function git_error(result)
    return vim.trim((result.stderr or "") .. "\n" .. (result.stdout or ""))
end

local function start_git(config, args, on_exit)
    local command = vim.list_extend({ "git", "-C", config }, args)
    -- Repository-local variables override -C. Keep the rest of the environment,
    -- including the user's Git configuration, hooks and signing settings.
    local env = vim.fn.environ()
    for _, name in ipairs({
        "GIT_DIR",
        "GIT_WORK_TREE",
        "GIT_INDEX_FILE",
        "GIT_COMMON_DIR",
        "GIT_OBJECT_DIRECTORY",
        "GIT_ALTERNATE_OBJECT_DIRECTORIES",
    }) do
        env[name] = nil
    end
    return vim.system(command, { text = true, env = env, clear_env = true }, on_exit)
end

local function git(config, args, allow_difference)
    local result = start_git(config, args):wait()
    if result.code ~= 0 and not (allow_difference and result.code == 1) then
        error(git_error(result), 0)
    end
    return result
end

local function check_repository(config)
    -- Check whether we are in a specific checkout
    if git(config, { "symbolic-ref", "--quiet", "HEAD" }, true).code ~= 0 then
        error("Refusing to auto-commit on a detached HEAD.", 0)
    end

    -- Check whether lockfile is track by git
    git(config, { "ls-files", "--error-unmatch", "--", lockfile })

    -- Check whether git is working in other stages
    local args = { "rev-parse", "--path-format=absolute" }
    for _, marker in ipairs({
        "MERGE_HEAD",
        "CHERRY_PICK_HEAD",
        "REVERT_HEAD",
        "rebase-merge",
        "rebase-apply",
        "sequencer",
    }) do
        vim.list_extend(args, { "--git-path", marker })
    end
    for path in git(config, args).stdout:gmatch("[^\r\n]+") do
        if vim.uv.fs_stat(path) then
            error(
                "Finish the current Git merge/rebase/cherry-pick/revert before using PackUpdate.",
                0
            )
        end
    end

    -- Check whether git has unresovled conflict
    if git(config, { "diff", "--name-only", "--diff-filter=U" }).stdout ~= "" then
        error("Resolve Git conflicts before using PackUpdate.", 0)
    end

    -- Check whether lockfile is staged
    if git(config, { "diff", "--cached", "--quiet", "--", lockfile }, true).code ~= 0 then
        error("The lockfile is already staged; commit or unstage it before using PackUpdate.", 0)
    end
end

local function commit_lockfile(config)
    -- Recheck: the user may have staged files or started a rebase while reviewing updates.
    check_repository(config)
    if git(config, { "diff", "--quiet", "--", lockfile }, true).code == 0 then
        return finish()
    end

    -- --only commits this working-tree file without including other staged changes.
    -- Keep the user's hooks and signing settings; never push automatically.
    start_git(
        config,
        { "commit", "--only", "-m", "chore(plugins): update lockfile", "--", lockfile },
        vim.schedule_wrap(function(result)
            if result.code == 0 then
                finish(vim.trim(result.stdout))
            else
                finish(
                    "Plugins updated, but auto-commit failed. The lockfile is still on disk; "
                        .. "fix Git and commit it manually.\n"
                        .. git_error(result),
                    vim.log.levels.ERROR
                )
            end
        end)
    )
end

local function watch_confirmation(config, buffer)
    local group = vim.api.nvim_create_augroup("NVIMEPackUpdate", { clear = true })
    local attempted, updated = 0, 0
    vim.api.nvim_create_autocmd({ "PackChangedPre", "PackChanged" }, {
        group = group,
        callback = function(event)
            if event.data.kind ~= "update" or vim.api.nvim_get_current_buf() ~= buffer then
                return
            end
            if event.event == "PackChangedPre" then
                attempted = attempted + 1
            else
                updated = updated + 1
            end
        end,
    })

    vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        buffer = buffer,
        callback = function()
            vim.api.nvim_del_augroup_by_id(group)
            finish()
        end,
    })

    -- vim.pack's BufWriteCmd was registered first, so it execute before us.
    -- In this stage, we can make sure that lockfile was updated.
    vim.api.nvim_create_autocmd("BufWriteCmd", {
        group = group,
        buffer = buffer,
        once = true,
        callback = function()
            -- Stop watching the buffer, but stay busy until the async commit finishes.
            vim.api.nvim_del_augroup_by_id(group)
            if attempted ~= updated then
                return finish(
                    "Some plugin updates failed; review nvim-pack.log and commit the lockfile manually.",
                    vim.log.levels.ERROR
                )
            end
            if updated == 0 then
                return finish()
            end
            local committed, commit_error = pcall(commit_lockfile, config)
            if not committed then
                finish(
                    "Plugins updated, but auto-commit was skipped. Commit the lockfile manually.\n"
                        .. tostring(commit_error),
                    vim.log.levels.ERROR
                )
            end
        end,
    })
end

function M.update()
    if busy then
        notify("An update or lockfile commit is already in progress.", vim.log.levels.WARN)
        return
    end
    busy = true

    local config = vim.fn.stdpath("config")
    local ready, reason = pcall(check_repository, config)
    if not ready then
        return finish(
            "Auto-commit unavailable; no update started.\n" .. tostring(reason),
            vim.log.levels.ERROR
        )
    end

    local previous_buffer = vim.api.nvim_get_current_buf()
    local ok, err = pcall(vim.pack.update)
    if not ok then
        return finish(tostring(err), vim.log.levels.ERROR)
    end

    local buffer = vim.api.nvim_get_current_buf()
    if buffer == previous_buffer or vim.bo[buffer].filetype ~= "nvim-pack" then
        return finish()
    end

    watch_confirmation(config, buffer)
end

return M
