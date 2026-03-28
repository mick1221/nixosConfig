 { pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    # LSP servers and tools neovim needs on PATH
    extraPackages = with pkgs; [

      lua-language-server
      ripgrep # needed by telescope
      vscode-langservers-extracted # html, css
      typescript-language-server # js, ts
      nil # nix
    ];

    plugins = with pkgs.vimPlugins; [
      # Set leader before any plugin keymaps
      {
        plugin = pkgs.emptyDirectory;
        type = "lua";
        config = ''
          vim.g.mapleader = ' '
        '';
      }

      # Treesitter - better syntax highlighting
      {
        plugin = nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require('nvim-treesitter.configs').setup({
            highlight = { enable = true },
          })
        '';
      }

      # LSP config
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = ''
          vim.lsp.config('lua_ls',{})
          vim.lsp.enable('lua_ls')
          vim.lsp.config('html',{})
          vim.lsp.enable('html')
          vim.lsp.config('cssls',{})
          vim.lsp.enable('cssls')
          vim.lsp.config('ts_ls',{})
          vim.lsp.enable('ts_ls')
          vim.lsp.config('nil_ls',{})
          vim.lsp.enable('nil_ls')
        '';
      }

      # Completion engine
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require('cmp')
          local luasnip = require('luasnip')

          cmp.setup({
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<CR>'] = cmp.mapping.confirm({ select = true }),
              ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                else
                  fallback()
                end
              end, { 'i', 's' }),
              ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                else
                  fallback()
                end
              end, { 'i', 's' }),
            }),
            sources = cmp.config.sources({
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
            }),
          })
        '';
      }

      # Fuzzy finder
      {
        plugin = telescope-nvim;
        type = "lua";
        config = ''
          require('telescope').setup({})
          vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files)
          vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep)
        '';
      }

      # Catppuccin colorscheme
      {
        plugin = catppuccin-nvim;
        type = "lua";
        config = ''
          require('catppuccin').setup({
            flavour = "mocha", -- latte, frappe, macchiato, mocha
          })
          vim.cmd.colorscheme('catppuccin')
        '';
      }

      # which-key - shows available keybinds
      {
        plugin = which-key-nvim;
        type = "lua";
        config = ''
          require('which-key').setup({})
        '';
      }
    ];

    extraLuaConfig = ''
      -- Basic options
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true

    '';
  };
}
