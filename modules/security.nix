{ config, pkgs, lib, ... }:

{
  ################################################################################
  # Security Hardening Module
  # AppArmor, Firewall, DNS Security, and System Hardening
  ################################################################################

  ################################################################################
  # AppArmor - Mandatory Access Control
  ################################################################################
  security.apparmor = {
    enable = true;
    
    # Kill processes that transition to an unknown AppArmor profile
    killUnconfinedConfinables = true;
    
    # Load all available AppArmor profiles
    packages = with pkgs; [
      apparmor-profiles
      apparmor-utils
    ];
  };
  
  ################################################################################
  # Firewall Configuration - firewalld (Modern, User-Friendly)
  ################################################################################
  networking.firewall = {
    # Enable firewall protection
    enable = true;
    
    # Default policy: deny all incoming, allow all outgoing
    # This is the secure default behavior
    
    # Allowed TCP ports (add services as needed)
    allowedTCPPorts = [
      # SSH (uncomment if needed for remote access)
      # 22
      
      # Add other services here as needed
    ];
    
    # Allowed UDP ports
    allowedUDPPorts = [
      # mDNS for local network discovery
      5353
      
      # Add other services here as needed
    ];
    
    # Allow ping (ICMP echo requests)
    allowPing = true;
    
    # Enable logging of refused connections (helpful for debugging)
    logRefusedConnections = true;
    
    # Log only limited number of packets to avoid log spam
    logRefusedPackets = false;
    
    # Connection tracking helpers (FTP, IRC, etc.)
    connectionTrackingModules = [];
    
    # Auto-load connection tracking helpers
    autoLoadConntrackHelpers = false;
  };
  
  # Use firewalld for advanced firewall management
  services.firewalld = {
    enable = true;
    
    # Default zone for network interfaces
    # "public" is restrictive, "home" is more permissive
    # Adjust based on your trust level of the network
  };
  
  ################################################################################
  # Fail2Ban - Intrusion Prevention (Optional, for SSH protection)
  ################################################################################
  # Uncomment if you enable SSH and want protection against brute-force attacks
  # services.fail2ban = {
  #   enable = true;
  #   maxretry = 5;
  #   ignoreIP = [
  #     "127.0.0.1/8"
  #     "::1"
  #     # Add your trusted IPs here
  #   ];
  # };
  
  ################################################################################
  # Sudo Configuration
  ################################################################################
  security.sudo = {
    enable = true;
    
    # Require password for sudo
    wheelNeedsPassword = true;
    
    # Timeout for sudo password cache (15 minutes)
    execWheelOnly = true;
    
    # Extra sudo rules
    extraRules = [
      {
        # Allow wheel group members to run all commands
        groups = [ "wheel" ];
        commands = [
          {
            command = "ALL";
            options = [ "SETENV" ];  # Allow environment variables
          }
        ];
      }
    ];
    
    # Extra configuration
    extraConfig = ''
      # Increase timestamp timeout to 15 minutes
      Defaults timestamp_timeout=15
      
      # Preserve useful environment variables
      Defaults env_keep += "SSH_AUTH_SOCK"
      Defaults env_keep += "PATH"
      
      # Disable lecture (annoying message)
      Defaults lecture = never
      
      # Use Wayland-specific askpass for GUI sudo prompts
      Defaults env_keep += "WAYLAND_DISPLAY"
      Defaults env_keep += "XDG_SESSION_TYPE"
    '';
  };
  
  ################################################################################
  # PAM (Pluggable Authentication Modules) Configuration
  ################################################################################
  security.pam = {
    # Enable PAM
    services = {
      # Login configuration
      login = {
        enableGnomeKeyring = true;
      };
      
      # Enable fingerprint authentication (if you have a fingerprint reader)
      # Uncomment if needed
      # login.fprintAuth = true;
      # sudo.fprintAuth = true;
    };
    
    # Enable U2F authentication (YubiKey, etc.) - Optional
    # u2f = {
    #   enable = true;
    #   control = "sufficient";
    # };
  };
  
  ################################################################################
  # DNS Configuration - Secure DNS with NextDNS
  ################################################################################
  
  # DNS-over-TLS configuration using systemd-resolved
  services.resolved = {
    enable = true;
    
    # Use DNS-over-TLS for privacy
    dnssec = "allow-downgrade";
    
    # Enable DNS over TLS
    dnsovertls = "opportunistic";
    
    # DNS servers in order: NextDNS → Quad9 → Cloudflare → Google
    fallbackDns = [
      # NextDNS (your custom ID: 241198)
      "45.90.28.0#241198.dns.nextdns.io"
      "2a07:a8c0::#241198.dns.nextdns.io"
      
      # Quad9 (security-focused, blocks malicious domains)
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
      
      # Cloudflare (fast and privacy-focused)
      "1.1.1.1#cloudflare-dns.com"
      "1.0.0.1#cloudflare-dns.com"
      "2606:4700:4700::1111#cloudflare-dns.com"
      "2606:4700:4700::1001#cloudflare-dns.com"
      
      # Google DNS (fallback)
      "8.8.8.8#dns.google"
      "8.8.4.4#dns.google"
      "2001:4860:4860::8888#dns.google"
      "2001:4860:4860::8844#dns.google"
    ];
    
    # Extra configuration for systemd-resolved
    extraConfig = ''
      DNSOverTLS=opportunistic
      MulticastDNS=yes
      LLMNR=yes
      Cache=yes
      CacheFromLocalhost=no
      DNSStubListener=yes
      ReadEtcHosts=yes
    '';
  };
  
  # Override NetworkManager's DNS settings to use systemd-resolved
  networking.networkmanager.dns = "systemd-resolved";
  
  ################################################################################
  # System Security Hardening
  ################################################################################
  
  # Protect kernel from user-space attacks
  boot.kernel.sysctl = {
    # Restrict kernel pointer visibility
    "kernel.kptr_restrict" = 2;
    
    # Restrict dmesg access
    "kernel.dmesg_restrict" = 1;
    
    # Restrict unprivileged BPF
    "kernel.unprivileged_bpf_disabled" = 1;
    
    # Restrict user namespaces (can break some containerization)
    "kernel.unprivileged_userns_clone" = 0;
    
    # Harden memory allocator
    "kernel.yama.ptrace_scope" = 2;
  };
  
  # Disable core dumps (can contain sensitive information)
  systemd.coredump.enable = false;
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "core";
      value = "0";
    }
  ];
  
  ################################################################################
  # Audit System (Optional, for security monitoring)
  ################################################################################
  # Linux audit framework for security event monitoring
  security.audit = {
    enable = false;  # Disabled by default to reduce overhead
    rules = [
      # Example: monitor /etc/passwd changes
      # "-w /etc/passwd -p wa -k passwd_changes"
      
      # Example: monitor sudo usage
      # "-a always,exit -F arch=b64 -S execve -F path=/run/wrappers/bin/sudo -k sudo_usage"
    ];
  };
  security.auditd.enable = false;
  
  ################################################################################
  # Additional Security Tools
  ################################################################################
  environment.systemPackages = with pkgs; [
    # AppArmor utilities
    apparmor-utils
    apparmor-profiles
    
    # Firewall management
    firewalld
    
    # Network analysis tools
    nmap
    tcpdump
    wireshark
    
    # Security scanning
    clamav  # Antivirus (optional, configure if needed)
    
    # Password management
    keepassxc
    
    # Encryption tools
    gnupg
    age
    
    # Secure deletion
    srm
  ];
  
  ################################################################################
  # ClamAV Antivirus (Optional, Disabled by Default)
  ################################################################################
  # Uncomment to enable antivirus scanning
  # services.clamav = {
  #   daemon.enable = true;
  #   updater.enable = true;
  #   updater.interval = "daily";
  #   updater.frequency = 1;
  # };
  
  ################################################################################
  # File Integrity Monitoring with AIDE (Optional)
  ################################################################################
  # Uncomment to enable file integrity monitoring
  # services.aide = {
  #   enable = true;
  #   interval = "daily";
  # };
  
  ################################################################################
  # Automatic Security Updates (Careful with this on NixOS)
  ################################################################################
  # Note: NixOS doesn't have traditional security updates
  # System updates are done declaratively through nixos-rebuild
  # We handle this through manual monthly updates as per requirements
  
  ################################################################################
  # SSH Hardening (If SSH is enabled in the future)
  ################################################################################
  services.openssh = {
    enable = false;  # Disabled by default, enable if needed
    
    settings = {
      # Disable root login
      PermitRootLogin = "no";
      
      # Disable password authentication (use keys only)
      PasswordAuthentication = false;
      
      # Enable public key authentication
      PubkeyAuthentication = true;
      
      # Disable empty passwords
      PermitEmptyPasswords = false;
      
      # Disable X11 forwarding (not needed for Wayland)
      X11Forwarding = false;
      
      # Use only strong ciphers
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
      
      # Use only strong MACs
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
      ];
      
      # Use only strong key exchange algorithms
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
    };
    
    # Listen on default port
    ports = [ 22 ];
    
    # Allow only specific users (add username if enabling SSH)
    # allowUsers = [ "shinchan" ];
  };
  
  ################################################################################
  # Security Notes and Best Practices
  ################################################################################
  # 
  # 1. Keep system updated regularly:
  #    sudo nixos-rebuild switch --flake /etc/nixos#NixOS
  # 
  # 2. Monitor system logs:
  #    journalctl -f
  # 
  # 3. Check firewall status:
  #    sudo firewall-cmd --state
  #    sudo firewall-cmd --list-all
  # 
  # 4. Review AppArmor profiles:
  #    sudo aa-status
  # 
  # 5. Test DNS configuration:
  #    resolvectl status
  #    resolvectl query nixos.org
  # 
  # 6. Enable automatic backups of important data
  # 
  # 7. Use strong, unique passwords for all accounts
  # 
  # 8. Enable 2FA where possible
  # 
  # 9. Regular security audits:
  #    nix-shell -p lynis --run "sudo lynis audit system"
  # 
  ################################################################################
}