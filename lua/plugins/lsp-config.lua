return {
    {
        "williamboman/mason.nvim",
        config = function()
            require('mason').setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "tsserver",
                    "clangd",
                    "denols",
                    "gopls",
                }
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            local lspconfig = require("lspconfig")
            local util = require("lspconfig.util")

            local is_deno_project = function(root_dir)
                return util.root_pattern("deno.json", "deno.jsonc")(root_dir) ~= nil
            end

            lspconfig.tsserver.setup({
                filetypes = { "javascript", "typescript", "vue" },
                root_dir = function(fname)
                    -- If the project is a Deno project, do not start tsserver
                    if is_deno_project(fname) then
                        return nil
                    end
                    -- Otherwise, use package.json or git ancestor as root
                    return util.root_pattern("package.json")(fname)
                        or util.find_git_ancestor(fname)
                        or vim.loop.cwd() -- Default to current working directory
                end,
                single_file_support = true,
                capabilities = capabilities,
                on_attach = function(client)
                    local is_deno = is_deno_project(client.config.cmd_cwd)
                    if is_deno then
                        vim.schedule(function()
                            client.stop()
                        end)
                    end
                end,
            })

            lspconfig.denols.setup({
                root_dir = util.root_pattern("deno.json", "deno.jsonc"),
                capabilities = capabilities,
            })

            lspconfig.lua_ls.setup({
                capabilities = capabilities
            })

            lspconfig.clangd.setup({
                capabilities = capabilities
            })

            lspconfig.gopls.setup({
                capabilities = capabilities
            })

            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, {})
        end
    }
}
