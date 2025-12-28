{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.webdev;
in {
  options.modules.webdev = {
    enable = mkEnableOption "web development environment";

    nodejs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Node.js and npm";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.nodejs;
        description = "Node.js package to use";
      };
    };

    python = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Python web development tools";
      };
    };

    rust = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Rust web development tools";
      };
    };

    go = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Go web development tools";
      };
    };

    databases = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable database clients and tools";
      };
    };

    containerization = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Docker and containerization tools";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Git tools
      git
      git-lfs
      gh
    ]
    ++ optionals cfg.nodejs.enable [
      # Node.js runtime and package managers
      cfg.nodejs.package
      nodePackages.yarn
      nodePackages.pnpm
      bun

      # TypeScript and language servers
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted

      # Code formatting and linting
      nodePackages.prettier
      nodePackages.eslint
    ]
    ++ optionals cfg.python.enable [
      # Python runtime and core tools
      python312
      python312Packages.pip
      python312Packages.virtualenv
      poetry

      # Web frameworks
      python312Packages.flask
      python312Packages.requests

      # Development tools
      python312Packages.black
      python312Packages.pytest
    ]
    ++ optionals cfg.rust.enable [
      # Rust toolchain
      rustc
      cargo
      rustfmt
      clippy
      rust-analyzer
    ]
    ++ optionals cfg.go.enable [
      # Go toolchain
      go
      gopls
      gotools
      golangci-lint
    ]
    ++ optionals cfg.databases.enable [
      # Database clients
      postgresql
      sqlite
      dbeaver-bin
    ]
    ++ optionals cfg.containerization.enable [
      # Container and orchestration tools
      docker-compose
      kubectl
      k9s
    ];

    # Shell aliases
    home.shellAliases = {
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";

      # Docker shortcuts
      dps = "docker ps";
      dpa = "docker ps -a";
      di = "docker images";
      dc = "docker-compose";
    };

    # Environment variables
    home.sessionVariables = mkMerge [
      (mkIf cfg.nodejs.enable {
        NODE_PATH = "${cfg.nodejs.package}/lib/node_modules";
      })
      (mkIf cfg.go.enable {
        GOPATH = "$HOME/go";
        GOBIN = "$HOME/go/bin";
      })
    ];
  };
}