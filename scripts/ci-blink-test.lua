-- Called before init.lua with "guard", then again after startup to test natives.
if ... == "guard" then
    vim.g.nvime_ci_errors = {}
    local notify = vim.notify
    vim.notify = function(message, level, opts)
        if level == vim.log.levels.ERROR then
            local errors = vim.g.nvime_ci_errors
            table.insert(errors, tostring(message))
            vim.g.nvime_ci_errors = errors
        end
        return notify(message, level, opts)
    end

    local function forbidden()
        error("The release bundle must not download or build Blink libraries at startup")
    end
    vim.net.request = forbidden
    local system = vim.system
    vim.system = function(command, ...)
        local executable = vim.fn.fnamemodify(command[1], ":t")
        if vim.tbl_contains({ "curl", "wget", "cargo" }, executable) then
            forbidden()
        end
        if executable == "git" then
            for _, argument in ipairs(command) do
                if vim.tbl_contains({ "clone", "fetch", "pull", "ls-remote" }, argument) then
                    forbidden()
                end
            end
        end
        return system(command, ...)
    end
    return
end

local ok, err = pcall(function()
    assert(vim.env.NVIME_SKIP_BLINK_NATIVE ~= "1", "Native checks must not use the Lua fallback")
    for _, request in ipairs({
        function()
            vim.system({ "curl", "--version" })
        end,
        function()
            vim.net.request()
        end,
    }) do
        local allowed, message = pcall(request)
        assert(
            not allowed and tostring(message):find("release bundle must not download", 1, true),
            "Download guard is not active"
        )
    end
    assert(
        vim.wait(10000, function()
            local fuzzy = package.loaded["blink.cmp.fuzzy"]
            return fuzzy and fuzzy.implementation_type == "rust"
        end, 20),
        "blink.cmp did not initialize its Rust backend"
    )

    local fuzzy = require("blink.cmp.fuzzy.rust")
    assert(type(fuzzy.get_words("hello world")) == "table")
    assert(require("blink.pairs").library_available(), "Missing blink.pairs native library")
    local parser = require("blink.pairs.rust")
    assert(parser.supports_filetype("lua"))
    local buffer = vim.api.nvim_create_buf(false, true)
    parser.parse_buffer(buffer, 4, "lua", "local value = (1 + 2)\n")
    parser.remove_buffer(buffer)
    vim.api.nvim_buf_delete(buffer, { force = true })

    assert(vim.v.errmsg == "", vim.v.errmsg)
    assert(#(vim.g.nvime_ci_errors or {}) == 0, table.concat(vim.g.nvime_ci_errors or {}, "\n"))
    print("PASS: bundled Blink cmp Rust backend and pairs parser; no runtime downloads")
end)
if not ok then
    vim.api.nvim_err_writeln(tostring(err))
    vim.cmd("cquit")
end
