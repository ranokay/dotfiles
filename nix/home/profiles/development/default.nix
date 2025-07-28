{pkgs, ...}: {
  # Development-focused configuration
  home = {
    packages = with pkgs; [
      # Development tools (add common dev tools here)
      nodejs
      python3
      rustc
      cargo
      go

      # Build tools
      gnumake
      cmake

      # Database tools
      postgresql
      sqlite

      # DevOps tools
      docker-compose
      kubernetes-helm

      # Monitoring
      lazydocker
      k9s
    ];

    # Development-specific shell aliases
    shellAliases = {
      # Git shortcuts (extending the base git config)
      "gst" = "git status";
      "gco" = "git checkout";
      "gcb" = "git checkout -b";
      "gp" = "git push";
      "gpl" = "git pull";
      "gf" = "git fetch";
      "gm" = "git merge";
      "gr" = "git rebase";

      # Docker shortcuts
      "dcu" = "docker-compose up -d";
      "dcd" = "docker-compose down";
      "dcr" = "docker-compose restart";
      "dcl" = "docker-compose logs -f";

      # Kubernetes shortcuts
      "k" = "kubectl";
      "kgp" = "kubectl get pods";
      "kgs" = "kubectl get services";
      "kgd" = "kubectl get deployments";
    };

    # Development environment variables
    sessionVariables = {
      # Set default editor
      EDITOR = "cursor";
      VISUAL = "cursor";

      # Development paths
      GOPATH = "$HOME/go";

      # Node.js/npm configuration
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
  };
}
