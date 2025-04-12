return {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    single_file_support = true,
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
    settings = {}
}
