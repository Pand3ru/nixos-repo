{ config, pkgs, ... }:

let
  marketplace = pkgs.vscode-marketplace;
  native = pkgs.vscode-extensions;
in
{
  programs.vscode = {
    enable = true;

    package = pkgs.vscode.fhsWithPackages (ps: with ps; [
      go
      gopls
      gotools
      golangci-lint
      rustup
      gcc
      clang
      clang-tools
      cmake
      jdk
      python3
      python3Packages.pip
      pyright
      haskell-language-server
      ghc
      cabal-install
      stack
      texlive.combined.scheme-full
      typst
      zlib
      openssl
      zathura
    ]);

    extensions = [
      native.dracula-theme.theme-dracula
      native.vscodevim.vim
      native.bbenoist.nix
      marketplace.golang.go
      native.rust-lang.rust-analyzer
      native.vadimcn.vscode-lldb
      marketplace.ms-vscode.cpptools
      marketplace.ms-vscode.cmake-tools
      marketplace.twxs.cmake
      marketplace.redhat.java
      marketplace.vscjava.vscode-java-debug
      marketplace.vscjava.vscode-java-test
      marketplace.vscjava.vscode-maven
      marketplace.ms-python.python
      marketplace.ms-python.vscode-pylance
      marketplace.ms-python.debugpy
      marketplace.haskell.haskell
      marketplace.justusadam.language-haskell
      native.james-yu.latex-workshop
      native.myriad-dreamin.tinymist
      native.yzhang.markdown-all-in-one
      marketplace.usernamehw.errorlens
      marketplace.streetsidesoftware.code-spell-checker
      marketplace.bnavetta.zoterolatex
      marketplace.cattherapy.vscode-cat-therapy
    ];

    profiles.default = {

      userSettings = {
        "editor.fontFamily"        = "'JetBrains Mono', 'Fira Code', monospace";
        "editor.fontSize"          = 14;
        "editor.lineHeight"        = 1.6;
        "editor.tabSize"           = 2;
        "editor.insertSpaces"      = true;
        "editor.formatOnSave"      = true;
        "editor.wordWrap"          = "off";
        "editor.rulers"            = [ 80 120 ];
        "editor.minimap.enabled"   = false;
        "editor.renderWhitespace"  = "trailing";
        "editor.cursorBlinking"    = "smooth";
        "editor.smoothScrolling"   = true;

        "workbench.colorTheme"     = "Dracula";
        "workbench.iconTheme"      = "vs-seti";

        "telemetry.telemetryLevel" = "off";

        "files.autoSave"           = "onFocusChange";
        "files.trimTrailingWhitespace" = true;

        "terminal.integrated.fontFamily" = "'JetBrains Mono', monospace";

        "vim.insertModeKeyBindingsNonRecursive" = [
          { before = [ "k" "j" ]; after = [ "<Esc>" ]; }
        ];
        "vim.visualModeKeyBindingsNonRecursive" = [
          { before = [ "k" "j" ]; after = [ "<Esc>" ]; }
        ];
        "vim.leader"             = "<space>";
        "vim.hlsearch"           = true;
        "editor.lineNumbers"     = "relative";
        "vim.useSystemClipboard" = true;
        "vim.handleKeys" = {
          "<C-f>"     = false;
          "<C-space>" = false;
          "<C-z>"     = false;
          "<C-s>"     = false;
          "<C-c>"     = false;
          "<C-v>"     = false;
          "<C-a>"     = false;
          "<C-w>"     = false;
          "<C-p>"     = false;
        };

        "go.useLanguageServer"           = true;
        "go.lintTool"                    = "golangci-lint";
        "go.lintOnSave"                  = "package";
        "go.formatTool"                  = "goimports";
        "[go]"."editor.formatOnSave"     = true;
        "[go]"."editor.defaultFormatter" = "golang.go";

        "rust-analyzer.check.command"          = "clippy";
        "rust-analyzer.inlayHints.enable"      = true;
        "[rust]"."editor.formatOnSave"         = true;
        "[rust]"."editor.defaultFormatter"     = "rust-lang.rust-analyzer";

        "clangd.arguments" = [ "--background-index" "--clang-tidy" "--header-insertion=iwyu" ];
        "C_Cpp.intelliSenseEngine"         = "disabled";
        "[c]"."editor.defaultFormatter"   = "ms-vscode.cpptools";
        "[cpp]"."editor.defaultFormatter" = "ms-vscode.cpptools";

        "java.configuration.updateBuildConfiguration" = "automatic";
        "java.format.enabled"                         = true;

        "python.languageServer"              = "Pylance";
        "python.analysis.typeCheckingMode"   = "basic";
        "[python]"."editor.formatOnSave"     = true;
        "[python]"."editor.defaultFormatter" = "ms-python.python";

        "haskell.manageHLS"        = "PATH";
        "haskell.formattingProvider" = "ormolu";

        "latex-workshop.latex.autoBuild.run" = "onSave";
        "latex-workshop.view.pdf.viewer"     = "external";
        "latex-workshop.view.pdf.external.viewer.command" = "zathura";
        "latex-workshop.view.pdf.external.viewer.args"    = [ "%PDF%" ];
        "latex-workshop.view.pdf.external.synctex.command" = "zathura";
        "latex-workshop.view.pdf.external.synctex.args" = [
          "--synctex-forward"
          "%LINE%:%CHARACTER%:%TEX%"
          "%PDF%"
        ];
        "latex-workshop.latex.outDir"   = "%DIR%/build";
        "latex-workshop.latex.clean.fileTypes" = [
          "*.aux" "*.bbl" "*.blg" "*.log" "*.out"
          "*.toc" "*.fls" "*.fdb_latexmk" "*.synctex.gz"
        ];
        "latex-workshop.synctex.afterBuild.enabled" = true;
        "latex-workshop.formatter.latex" = "latexindent";

        "tinymist.exportPdf"          = "onSave";
        "tinymist.formatterMode"      = "typstyle";
        "tinymist.preview.invertColors" = "auto";
        "tinymist.preview.background" = true;

        "errorLens.enabledDiagnosticLevels" = [ "error" "warning" "info" ];
      };

      keybindings = [
        {
          key     = "ctrl+f";
          command = "workbench.action.quickOpen";
          when    = "!inQuickOpen";
        }
        {
          key     = "ctrl+f";
          command = "workbench.action.closeQuickOpen";
          when    = "inQuickOpen";
        }
        {
          key     = "ctrl+space";
          command = "workbench.action.findInFiles";
        }
        {
          key     = "ctrl+alt+b";
          command = "latex-workshop.build";
          when    = "editorTextFocus && resourceLangId == latex";
        }
        {
          key     = "ctrl+alt+v";
          command = "latex-workshop.view";
          when    = "editorTextFocus && resourceLangId == latex";
        }
        {
          key     = "ctrl+alt+p";
          command = "tinymist.startDefaultPreview";
          when    = "editorTextFocus && resourceLangId == typst";
        }
      ];
    };
  };
}
