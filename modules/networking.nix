{ config, pkgs, lib, ... }:

{
  ################################################################################
  # Networking Configuration Module
  # WiFi (iwd), NetworkManager, DNS, and Network Optimizations
  ################################################################################

  ################################################################################
  # NetworkManager - Primary Network Management
  ################################################################################
  networking.networkmanager = {
    enable = true;
    
    # Use iwd as WiFi backend (required for WIOM WiFi hardware)
    # This fixes the WiFi issues experienced on Fedora and Arch
    wifi.backend = "iwd";
    
    # Enable WiFi power saving
    wifi.powersave = true;
    
    # MAC address randomization for privacy
    wifi.macAddress = "random";
    ethernet.macAddress = "random";
    
    # Use systemd-resolved for DNS
    dns = "systemd-resolved";
    
    # Enable NetworkManager-wait-online service
    # Ensures network is ready before services that need it
    wait-online.enable = true;
    
    # Connection check
    connectivity = {
      enable = true;
      uri = "https://nmcheck.gnome.org/check_network_status.txt";
      interval = 300;  # Check every 5 minutes
    };
    
    # Extra configuration for NetworkManager
    extraConfig = ''
      [main]
      # Use keyfile plugin for storing connections
      plugins=keyfile
      
      # Randomize MAC addresses
      wifi.scan-rand-mac-address=yes
      
      [connection]
      # Autoconnect to known networks
      connection.autoconnect-priority=999
      
      # IPv6 privacy extensions
      ipv6.ip6-privacy=2
      
      [device]
      # WiFi backend configuration
      wifi.backend=iwd
    '';
    
    # Unmanaged devices (if any)
    unmanaged = [];
    
    # Dispatcher scripts directory
    dispatcherScripts = [];
  };
  
  ################################################################################
  # iwd (iNet Wireless Daemon) - Modern WiFi Backend
  ################################################################################
  networking.wireless.iwd = {
    enable = true;
    
    settings = {
      # General iwd settings
      General = {
        # Enable built-in DHCP client (faster than NetworkManager's)
        EnableNetworkConfiguration = false;  # Let NetworkManager handle this
        
        # Use default interface naming (wlan0)
        UseDefaultInterface = true;
        
        # Roaming configuration
        RoamRetryInterval = 15;
      };
      
      # Network configuration (handled by NetworkManager)
      Network = {
        # Enable IPv6
        EnableIPv6 = true;
        
        # Route priority offset (lower = higher priority)
        RoutePriorityOffset = 300;
        
        # Name resolution
        NameResolvingService = "systemd";
      };
      
      # Scanning configuration
      Scan = {
        # Disable periodic scanning when connected
        DisablePeriodicScan = false;
        
        # Disable roaming when connected
        DisableRoamingScan = false;
      };
      
      # Settings for better compatibility
      Settings = {
        # Automatically connect to known networks
        AutoConnect = true;
        
        # Use 4-way handshake offload if available
        AlwaysRandomizeAddress = false;
      };
      
      # Driver quirks for maximum compatibility
      DriverQuirks = {
        # Use default interface (required for NetworkManager integration)
        UseDefaultInterface = true;
        
        # Control port over NL80211 (improves compatibility)
        # Set to false if WiFi connection fails
        ControlPortOverNL80211 = true;
        
        # Power save mode
        PowerSaveDisable = false;
      };
      
      # Security settings
      Security = {
        # Enterprise network configuration (if needed for eduroam, etc.)
        EAP-Method = "PEAP";
        EAP-Identity = "anonymous";
      };
    };
  };
  
  ################################################################################
  # WPA Supplicant - Disabled (using iwd instead)
  ################################################################################
  # Ensure wpa_supplicant is not running (conflicts with iwd)
  networking.wireless.enable = false;
  
  ################################################################################
  # Additional Network Packages
  ################################################################################
  environment.systemPackages = with pkgs; [
    # NetworkManager TUI for easy WiFi management
    networkmanager_dmenu
    networkmanagerapplet
    
    # iwd tools for WiFi management
    iw
    wireless-tools
    
    # Network diagnostics
    dig
    traceroute
    mtr
    iperf3
    speedtest-cli
    
    # WiFi analysis
    wavemon
    
    # Network monitoring
    nethogs
    iftop
    
    # Bluetooth networking
    bluez
    bluez-tools
  ];
  
  ################################################################################
  # Hostname Configuration
  ################################################################################
  # Hostname is set in configuration.nix (NixOS)
  # networking.hostName is defined there
  
  # Allow mDNS (Avahi) for local network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # Support for .local domain resolution
    nssmdns6 = true;
    
    # Publish services
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
  
  ################################################################################
  # Network Optimization
  ################################################################################
  boot.kernel.sysctl = {
    # TCP optimization for better throughput
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 67108864";
    "net.ipv4.tcp_wmem" = "4096 65536 67108864";
    
    # Enable TCP Fast Open
    "net.ipv4.tcp_fastopen" = 3;
    
    # TCP congestion control (BBR for better performance)
    "net.ipv4.tcp_congestion_control" = "bbr";
    
    # Enable TCP window scaling
    "net.ipv4.tcp_window_scaling" = 1;
    
    # Increase the maximum number of connections
    "net.core.somaxconn" = 65536;
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    
    # Reduce TIME_WAIT sockets
    "net.ipv4.tcp_fin_timeout" = 15;
    "net.ipv4.tcp_tw_reuse" = 1;
    
    # Enable TCP timestamps
    "net.ipv4.tcp_timestamps" = 1;
    
    # Enable selective acknowledgments
    "net.ipv4.tcp_sack" = 1;
    
    # MTU probing
    "net.ipv4.tcp_mtu_probing" = 1;
    
    # IPv6 optimizations
    "net.ipv6.conf.all.use_tempaddr" = 2;
    "net.ipv6.conf.default.use_tempaddr" = 2;
  };
  
  # Load TCP BBR module
  boot.kernelModules = [ "tcp_bbr" ];
  
  ################################################################################
  # IPv6 Configuration
  ################################################################################
  networking.enableIPv6 = true;
  
  # IPv6 privacy extensions (temporary addresses)
  networking.tempAddresses = "enabled";
  
  ################################################################################
  # Hosts File Configuration
  ################################################################################
  # Block known malicious domains (optional)
  # networking.extraHosts = ''
  #   # Block ads and trackers
  #   0.0.0.0 ads.example.com
  #   0.0.0.0 tracker.example.com
  # '';
  
  ################################################################################
  # systemd Network Services
  ################################################################################
  systemd.services.NetworkManager-wait-online = {
    # Reduce timeout to speed up boot
    serviceConfig = {
      TimeoutStartSec = "15sec";
    };
  };
  
  # Ensure iwd starts before NetworkManager
  systemd.services.iwd = {
    wantedBy = [ "multi-user.target" ];
    before = [ "NetworkManager.service" ];
    
    # Restart iwd if it fails
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  
  ################################################################################
  # WiFi Connection Troubleshooting Notes
  ################################################################################
  # 
  # If WiFi still doesn't work after installation:
  # 
  # 1. Check iwd status:
  #    sudo systemctl status iwd
  # 
  # 2. Check NetworkManager status:
  #    sudo systemctl status NetworkManager
  # 
  # 3. Scan for networks:
  #    iwctl station wlan0 scan
  #    iwctl station wlan0 get-networks
  # 
  # 4. Connect to a network:
  #    iwctl station wlan0 connect "SSID_NAME"
  # 
  # 5. Check NetworkManager connections:
  #    nmcli device status
  #    nmcli connection show
  # 
  # 6. If ControlPortOverNL80211 causes issues, disable it:
  #    networking.wireless.iwd.settings.DriverQuirks.ControlPortOverNL80211 = false;
  # 
  # 7. Check kernel messages for WiFi-related errors:
  #    dmesg | grep -i wifi
  #    journalctl -u iwd -b
  # 
  # 8. Restart networking services:
  #    sudo systemctl restart iwd
  #    sudo systemctl restart NetworkManager
  # 
  # 9. Ensure WiFi is not blocked by rfkill:
  #    rfkill list
  #    sudo rfkill unblock wifi
  # 
  # 10. Check if firmware is loaded:
  #     ls /lib/firmware/ | grep -i wifi
  # 
  ################################################################################
  
  ################################################################################
  # Hardware-Specific WiFi Firmware
  ################################################################################
  # Most WiFi firmware is included by default in NixOS
  # If you need additional firmware, add it here
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
  
  ################################################################################
  # Notes for Router DNS Override Issue
  ################################################################################
  # 
  # To prevent router from overriding DNS settings:
  # 
  # 1. systemd-resolved is configured to use specific DNS servers
  # 2. NetworkManager is configured to use systemd-resolved
  # 3. The DNS hierarchy is enforced: NextDNS → Quad9 → Cloudflare → Google
  # 4. DHCP DNS servers are ignored in favor of our configuration
  # 
  # If you still experience DNS override:
  # - Check: resolvectl status
  # - Verify: cat /etc/resolv.conf (should point to systemd-resolved)
  # - Force DNS: sudo systemctl restart systemd-resolved
  # 
  ################################################################################
}