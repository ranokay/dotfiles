{pkgs, ...}: {
  # Server-focused home configuration
  # Minimal setup for headless server environments

  # Server-specific packages
  home = {
    packages = with pkgs; [
      # System monitoring
      htop
      btop
      iotop
      nethogs

      # Network tools
      dig
      nmap
      netcat
      curl
      wget

      # Text processing
      jq
      yq-go

      # File management
      tree
      unzip
      zip

      # Process management
      tmux
      screen
      killall
    ];

    # Server-specific shell aliases
    shellAliases = {
      # System monitoring shortcuts
      "ports" = "netstat -tuln";
      "listening" = "lsof -i -P -n | grep LISTEN";
      "processes" = "ps aux | head -20";
      "meminfo" = "free -h";
      "diskinfo" = "df -h";

      # Log viewing shortcuts
      "logs" = "journalctl -f";
      "logsboot" = "journalctl -b";
      "logserr" = "journalctl -p err";

      # Service management shortcuts
      "sysstart" = "sudo systemctl start";
      "sysstop" = "sudo systemctl stop";
      "sysrestart" = "sudo systemctl restart";
      "sysstatus" = "systemctl status";
      "sysenable" = "sudo systemctl enable";
      "sysdisable" = "sudo systemctl disable";
    };

    # Server-specific environment variables
    sessionVariables = {
      # Set vim as default editor for servers
      EDITOR = "vim";
      VISUAL = "vim";

      # Disable less history file on servers
      LESSHISTFILE = "-";
    };
  };

  # Configure tmux for server use
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    extraConfig = ''
      # Server-optimized tmux configuration
      set -g status-bg black
      set -g status-fg white
      set -g status-interval 1
      set -g status-left-length 30
      set -g status-left '#[fg=green](#S) #(whoami)@#H'
      set -g status-right '#[fg=yellow]#(cut -d " " -f 1-3 /proc/loadavg)#[default] #[fg=blue]%H:%M:%S'
    '';
  };
}
