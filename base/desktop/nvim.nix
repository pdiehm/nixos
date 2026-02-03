{ inputs, lib, machine, pkgs, ... }: {
  home-manager.users.pascal = {
    imports = [ inputs.nixvim.homeModules.nixvim ];

    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      extraConfigLuaPre = lib.readFile ../../resources/vim/nvim.lua;
      filetype.extension.zsh = "sh";
      nixpkgs.useGlobalPackages = true;

      autoCmd = lib.mapAttrsToList (event: command: { inherit command event; }) {
        TermClose = "lua if vim.v.event.status ~= 0 then vim.api.nvim_input('<CR>') end";
        TermOpen = "setlocal nospell";
      };

      clipboard = {
        providers.wl-copy.enable = true;
        register = "unnamedplus";
      };

      colorschemes.onedark = {
        enable = true;

        settings = {
          term_colors = false;
          transparent = true;
        };
      };

      diagnostic.settings = {
        severity_sort = true;
        update_in_insert = true;
        virtual_text = true;
      };

      extraFiles = {
        "spell/de.utf-8.spl".source = ../../resources/vim/de.utf-8.spl;
        "spell/de.utf-8.sug".source = ../../resources/vim/de.utf-8.sug;
        "spell/en.utf-8.spl".source = ../../resources/vim/en.utf-8.spl;
        "spell/en.utf-8.sug".source = ../../resources/vim/en.utf-8.sug;
      };

      keymaps = lib.mkNvimKeymaps {
        "!"."<C-BS>" = "<C-w>";
        nx.x = "\"_x";

        n = {
          "<C-j>" = "m`J``";
          "<Space><Return>" = "<Cmd>terminal<CR>i";
          "<Space><Space>" = "<Cmd>Oil<CR>";
          X = "\"_D";
          gQ = "<Cmd>cprevious<CR>";
          gl = "<C-o>";
          gq = "<Cmd>cnext<CR>";
          vv = "gv";
        };

        nt = {
          "<A-S-Tab>" = "<Cmd>tabprevious<CR>";
          "<A-S-h>" = "<Cmd>wincmd H<CR>";
          "<A-S-j>" = "<Cmd>wincmd J<CR>";
          "<A-S-k>" = "<Cmd>wincmd K<CR>";
          "<A-S-l>" = "<Cmd>wincmd L<CR>";
          "<A-S-w>" = "<Cmd>new<CR>";
          "<A-Tab>" = "<Cmd>tabnext<CR>";
          "<A-h>" = "<Cmd>wincmd h<CR>";
          "<A-j>" = "<Cmd>wincmd j<CR>";
          "<A-k>" = "<Cmd>wincmd k<CR>";
          "<A-l>" = "<Cmd>wincmd l<CR>";
          "<A-t>" = "<Cmd>tab new<CR>";
          "<A-w>" = "<Cmd>vertical new<CR>";
        };

        t = {
          "<C-BS>" = "<C-h>";
          "<A-Esc>" = "<C-\\><C-n>";
        };

        x = {
          H = "<gv";
          J = ":m '>+1<CR>gv=gv";
          K = ":m '<-2<CR>gv=gv";
          L = ">gv";
          O = ":sort<CR>";
        };
      };

      lsp = {
        keymaps = lib.mkNvimKeymaps {
          n = {
            gP.__raw = "vim.diagnostic.goto_prev";
            ga.__raw = "vim.lsp.buf.code_action";
            gd.__raw = "vim.lsp.buf.definition";
            gi.__raw = "vim.lsp.buf.implementation";
            gp.__raw = "vim.diagnostic.goto_next";
            gr.__raw = "vim.lsp.buf.empty_rename";
          };
        };

        servers = {
          bashls.enable = true;
          clangd.enable = true;
          cmake.enable = true;
          cssls.enable = true;
          dockerls.enable = true;
          eslint.enable = true;
          gdscript.enable = true;
          html.enable = true;
          java_language_server.enable = true;
          jsonls.enable = true;
          phpactor.enable = true;
          pylsp.enable = true;
          tailwindcss.enable = true;
          texlab.enable = true;
          ts_ls.enable = true;
          yamlls.enable = true;

          lua_ls = {
            enable = true;

            config.settings.Lua = {
              runtime.version = "LuaJIT";
              workspace.library = [ "${pkgs.neovim}/share/nvim/runtime/lua" ];
            };
          };

          nixd = {
            enable = true;

            config.settings.nixd = {
              nixpkgs.expr = ''(builtins.getFlake "/home/pascal/.config/nixos").nixosConfigurations."${machine.name}".pkgs'';
              options.nixos.expr = ''(builtins.getFlake "/home/pascal/.config/nixos").nixosConfigurations."${machine.name}".options'';
            };
          };

          rust_analyzer = {
            enable = true;
            config.settings.rust-analyzer.check.command = "clippy";
          };
        };
      };

      opts = {
        expandtab = true;
        hlsearch = false;
        ignorecase = true;
        linebreak = true;
        list = true;
        mouse = "";
        number = true;
        relativenumber = true;
        scrolloff = 8;
        shell = "${lib.getExe pkgs.zsh} --interactive";
        shiftwidth = 2;
        showmode = false;
        signcolumn = "yes";
        smartcase = true;
        smartindent = true;
        softtabstop = 2;
        spell = true;
        spelllang = "en,de";
        splitbelow = true;
        splitright = true;
        tabstop = 2;
        updatetime = 250;
        wrap = false;
      };

      performance = {
        byteCompileLua = {
          enable = true;
          luaLib = true;
          nvimRuntime = true;
          plugins = true;
        };

        combinePlugins = {
          enable = true;
          standalonePlugins = [ "onedark.nvim" ];
        };
      };

      plugins = {
        lspconfig.enable = true;
        nvim-surround.enable = true;
        ts-autotag.enable = true;
        web-devicons.enable = true;

        autoclose = {
          enable = true;

          settings.keys = {
            "'".close = false;
            ">".pair = "><";
          };
        };

        blink-cmp = {
          enable = true;

          settings = {
            cmdline.enabled = false;
            fuzzy.sorts = [ "exact" "score" "sort_text" ];
            signature.enabled = true;

            completion = {
              list.selection.preselect = false;

              documentation = {
                auto_show = true;
                auto_show_delay_ms = 0;
              };
            };

            keymap = {
              preset = "none";
              "<A-Space>" = [ "show_signature" "hide_signature" ];
              "<C-Return>" = [ "select_and_accept" ];
              "<C-Space>" = [ "show" "hide" ];
              "<C-d>" = [ "scroll_documentation_down" "scroll_signature_down" "fallback" ];
              "<C-u>" = [ "scroll_documentation_up" "scroll_signature_up" "fallback" ];
              "<S-Tab>" = [ "select_prev" "fallback" ];
              "<Tab>" = [ "select_next" "fallback" ];
            };
          };
        };

        conform-nvim = {
          enable = true;

          settings = {
            format_on_save.lsp_format = "never";

            formatters = lib.mkNvimFormatters {
              black = [ (lib.getExe pkgs.python3Packages.black) "--line-length=120" ];
              clang-format = [ (lib.getExe' pkgs.clang-tools "clang-format") ];
              cmake-format = [ (lib.getExe pkgs.cmake-format) "--autosort" "--line-width=120" "--tab-size=2" ];
              dockerfmt = [ (lib.getExe pkgs.dockerfmt) "--indent=2" "--newline" ];
              gdformat = [ (lib.getExe' pkgs.gdtoolkit_4 "gdformat") "--line-length=120" ];
              google-java-format = [ (lib.getExe pkgs.google-java-format) ];
              isort = [ (lib.getExe pkgs.python3Packages.isort) ];
              nixfmt = [ (lib.getExe pkgs.nixfmt) "--strict" "--width=120" ];
              rustfmt = [ (lib.getExe pkgs.rustfmt) ];
              shfmt = [ (lib.getExe pkgs.shfmt) "--indent=2" ];
              stylua = [ (lib.getExe pkgs.stylua) "--column-width=120" "--indent-type=Spaces" "--indent-width=2" ];

              bibtex-tidy = [
                (lib.getExe pkgs.bibtex-tidy)
                "--blank-lines"
                "--merge"
                "--no-escape"
                "--numeric"
                "--remove-empty-fields"
                "--sort"
                "--sort-fields"
                "--trailing-commas"
                "--wrap=120"
              ];

              latexindent = [
                (lib.getExe' pkgs.texlivePackages.latexindent "latexindent")
                "--local=${../../resources/latexindent.yaml}"
                "--logfile=/dev/null"
              ];

              prettier = [
                (lib.getExe pkgs.prettier)
                "--arrow-parens=avoid"
                "--brace-style=1tbs"
                "--print-width=120"
                "--tab-width=2"
              ];
            };

            formatters_by_ft = {
              bib = [ "bibtex-tidy" ];
              c = [ "clang-format" ];
              cmake = [ "cmake-format" ];
              cpp = [ "clang-format" ];
              css = [ "prettier" ];
              dockerfile = [ "dockerfmt" ];
              gdscript = [ "gdformat" ];
              html = [ "prettier" ];
              java = [ "google-java-format" ];
              javascript = [ "prettier" ];
              javascriptreact = [ "prettier" ];
              json = [ "prettier" ];
              jsonc = [ "prettier" ];
              lua = [ "stylua" ];
              markdown = [ "prettier" ];
              nix = [ "nixfmt" ];
              php = [ "prettier" ];
              python = [ "isort" "black" ];
              rust = [ "rustfmt" ];
              scss = [ "prettier" ];
              sh = [ "shfmt" ];
              tex = [ "latexindent" ];
              typescript = [ "prettier" ];
              typescriptreact = [ "prettier" ];
              xml = [ "prettier" ];
              yaml = [ "prettier" ];
            };
          };
        };

        gitsigns = {
          enable = true;

          settings = {
            current_line_blame = true;
            current_line_blame_opts.delay = 250;
          };
        };

        lualine = {
          enable = true;

          settings = {
            options.always_show_tabline = false;
            sections.lualine_x = [ "lsp_status" "filetype" ];
            tabline.lualine_a.__raw = "{ { 'tabs', mode = 1 } }";
          };
        };

        oil = {
          enable = true;

          settings = {
            skip_confirm_for_simple_edits = true;
            use_default_keymaps = false;
            view_options.show_hidden = true;

            keymaps = {
              "<BS>" = "actions.parent";
              "<Return>" = "actions.select";
              "~" = "actions.cd";
              _ = "actions.open_cwd";
              q = "actions.close";
            };
          };
        };

        telescope = {
          enable = true;

          extensions = {
            fzf-native.enable = true;
            ui-select.enable = true;
          };

          keymaps = {
            "<Space>/" = "search_history";
            "<Space>:" = "command_history";
            "<Space>a" = "spell_suggest";
            "<Space>b" = "buffers";
            "<Space>c" = "git_commits";
            "<Space>d" = "lsp_document_symbols";
            "<Space>f" = "find_files hidden=true";
            "<Space>g" = "live_grep";
            "<Space>h" = "help_tags";
            "<Space>j" = "jumplist";
            "<Space>k" = "grep_string";
            "<Space>l" = "resume";
            "<Space>o" = "vim_options";
            "<Space>p" = "diagnostics";
            "<Space>q" = "quickfix";
            "<Space>r" = "lsp_references";
            "<Space>s" = "git_status";
            "<Space>t" = "todo-comments";
            "<Space>v" = "git_bcommits";
            "<Space>w" = "lsp_workspace_symbols";
            "<Space>x" = "current_buffer_fuzzy_find";
            "<Space>z" = "git_stash";
          };

          settings.defaults = {
            file_ignore_patterns = [ "^.git/" ];
            layout_strategy = "flex";

            mappings.i = {
              "<A-Return>" = "select_tab";
              "<A-S-q>" = "smart_add_to_qflist";
              "<A-q>" = "smart_send_to_qflist";
              "<Esc>" = "close";
              "<S-Return>" = "select_vertical";
            };

            vimgrep_arguments = [
              "rg"
              "--color=never"
              "--column"
              "--hidden"
              "--line-number"
              "--no-heading"
              "--pcre2"
              "--smart-case"
              "--with-filename"
            ];
          };
        };

        todo-comments = {
          enable = true;

          settings = {
            search.args = [ "--color=never" "--column" "--hidden" "--line-number" "--no-heading" "--smart-case" "--with-filename" ];

            highlight = {
              after = "";
              keyword = "fg";
            };
          };
        };

        toggleterm = {
          enable = true;

          settings = {
            open_mapping = "[[<A-Return>]]";
            size = 8;
          };
        };

        treesitter = {
          enable = true;
          highlight.enable = true;
          indent.enable = true;
        };
      };
    };
  };
}
