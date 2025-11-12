# NixOS 25.05 "Warbler" - Shinchan Configuration
## Quick Start Guide

---

## 📦 What You've Received

A complete, professional NixOS 25.05 configuration with:

✅ **Fully automated installation script** with robust error handling  
✅ **Niri Wayland compositor** (scrollable-tiling, modern, beautiful)  
✅ **LUKS2 full disk encryption** (single password unlock)  
✅ **BTRFS filesystem** with optimal subvolume layout  
✅ **Security hardened** (AppArmor, firewall, DNS-over-TLS)  
✅ **WiFi fixed** (iwd backend for your WIOM adapter)  
✅ **Complete dev environment** (Python, Node.js, Rust, C++, AI/ML)  
✅ **All requested apps** (Obsidian, Anki, QGIS, VS Code, etc.)  
✅ **Beautiful terminal** (Alacritty + Fish + Starship)  
✅ **Auto-wallpaper changer** (every 3 minutes)  
✅ **Permanent night light** (4100K via hyprsunset)  
✅ **Dark mode everywhere** (system-wide)  
✅ **Professional documentation** (README + guides)

---

## 🗂️ File Structure

```
nixos-config/
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Dependency lock file
├── configuration.nix            # Main system config
├── home.nix                     # Home Manager config
├── hardware-configuration.nix   # Auto-generated hardware config
├── README.md                    # Main documentation
├── QUICK_START.md              # This file
├── REMAINING_MODULES_GUIDE.md  # Complete module implementations
├── scripts/
│   └── install.sh              # Automated installer
└── modules/
    ├── boot.nix                # Boot + kernel + LUKS
    ├── security.nix            # AppArmor + firewall + DNS
    ├── networking.nix          # iwd + NetworkManager
    ├── users.nix               # User management
    ├── desktop/
    │   ├── niri.nix           # Niri compositor
    │   ├── fonts.nix          # Font configuration
    │   ├── theming.nix        # Dark theme
    │   └── wallpaper.nix      # Auto wallpaper changer
    ├── shell/
    │   ├── fish.nix           # Fish shell
    │   ├── alacritty.nix      # Terminal
    │   └── cli-tools.nix      # Modern CLI tools
    ├── development/
    │   ├── languages.nix      # Python, Node, Rust, etc.
    │   ├── editors.nix        # Neovim + VS Code
    │   └── ai-ml.nix          # ML/AI libraries
    └── applications/
        ├── native.nix         # Native packages
        └── flatpak.nix        # Flatpak apps
```

---

## 🚀 Installation Steps

### 1. Download NixOS ISO
```bash
# Download NixOS 25.05 Minimal ISO from:
https://nixos.org/download

# Flash to USB drive (8GB minimum)
```

### 2. Boot and Connect WiFi
```bash
# Boot from USB
# Connect to WiFi:
sudo systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "YOUR_WIFI"
> set_network 0 psk "PASSWORD"
> enable_network 0
> quit
```

### 3. Run Installation Script
```bash
# Download install script
curl -L https://raw.githubusercontent.com/YOUR_USERNAME/nixos-config/main/scripts/install.sh -o install.sh

chmod +x install.sh

# Run it (will ask for disk and password)
sudo ./install.sh
```

### 4. Copy Configuration
```bash
# Clone your config repo (or copy files manually)
cd /mnt/etc/nixos
# Copy all the configuration files provided

# OR download directly:
# curl -L https://github.com/YOUR_USERNAME/nixos-config/archive/main.tar.gz | tar xz -C /mnt/etc/nixos --strip-components=1
```

### 5. Install NixOS
```bash
# Install system
sudo nixos-install --flake /mnt/etc/nixos#NixOS

# Set root and user password when prompted
# Password will be used for: LUKS unlock + login + sudo
```

### 6. Reboot
```bash
# Remove USB and reboot
sudo reboot
```

---

## 🎨 First Boot Configuration

### Login
- **Username**: `shinchan`
- **Password**: (the one you set during installation)
- System will unlock LUKS and log you in with a single password

### Install Flatpak Apps
```bash
# Browsers
flatpak install -y flathub com.brave.Browser
flatpak install -y flathub org.mozilla.firefox
flatpak install -y flathub com.google.Chrome

# Communication
flatpak install -y flathub org.telegram.desktop
flatpak install -y flathub org.signal.Signal

# Utilities
flatpak install -y flathub com.obsproject.Studio  # OBS
flatpak install -y flathub org.gnome.Boxes       # VMs
```

### Set Default Browser
```bash
xdg-settings set default-web-browser com.brave.Browser.desktop
```

### Configure Git
```bash
git config --global user.name "shinchan"
git config --global user.email "your-email@example.com"
```

### Add Wallpapers
```bash
# Create wallpaper directory (should already exist)
mkdir -p ~/Pictures/Wallpapers

# Add your favorite wallpapers
# They will automatically rotate every 3 minutes
```

---

## ⌨️ Keyboard Shortcuts (Niri)

| Shortcut | Action |
|----------|--------|
| `Super + T` | Open terminal |
| `Super + D` | Application launcher |
| `Super + Q` | Close window |
| `Super + Shift + E` | Exit Niri |
| `Super + H/L` | Move focus left/right |
| `Super + J/K` | Move focus up/down |
| `Super + Shift + H/L` | Move window left/right |
| `Super + F` | Fullscreen |
| `Super + O` | Overview mode |
| `Super + 1-5` | Switch workspace |
| `Super + S` | Screenshot (select area) |
| `Print` | Screenshot (full screen) |
| `Super + Escape` | Lock screen |

---

## 🔧 System Management

### Update System
```bash
# Update packages
rebuild

# Or manually:
sudo nixos-rebuild switch --flake /etc/nixos#NixOS
```

### Clean Old Generations
```bash
# Clean generations older than 15 days
clean

# Or manually:
sudo nix-collect-garbage --delete-older-than 15d
```

### Rollback to Previous Generation
```bash
sudo nixos-rebuild switch --rollback
```

### View System Info
```bash
fastfetch    # Beautiful system info
btop         # System monitor
```

---

## 🛠️ Troubleshooting

### WiFi Not Working
```bash
# Check iwd status
sudo systemctl status iwd

# Restart networking
sudo systemctl restart NetworkManager iwd

# Scan for networks
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect "SSID_NAME"
```

### Niri Won't Start
```bash
# Check logs
journalctl -u display-manager -b

# Restart display manager
sudo systemctl restart display-manager
```

### DNS Not Working
```bash
# Check DNS status
resolvectl status

# Restart systemd-resolved
sudo systemctl restart systemd-resolved
```

### System Won't Boot
1. Boot from NixOS live USB
2. Decrypt and mount disk:
   ```bash
   cryptsetup open /dev/nvme0n1p2 cryptroot
   mount -o subvol=@ /dev/mapper/cryptroot /mnt
   mount -o subvol=@home /dev/mapper/cryptroot /mnt/home
   mount -o subvol=@nix /dev/mapper/cryptroot /mnt/nix
   mount /dev/nvme0n1p1 /mnt/boot
   ```
3. Fix configuration:
   ```bash
   nixos-enter
   # Make changes
   exit
   ```
4. Reboot

---

## 📚 Learning Resources

- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **Niri Wiki**: https://github.com/YaLTeR/niri/wiki
- **NixOS Wiki**: https://nixos.wiki/
- **Home Manager**: https://nix-community.github.io/home-manager/

---

## ✅ Verification Checklist

After installation, verify:

- [ ] System boots and decrypts with single password
- [ ] Niri loads and displays properly
- [ ] WiFi connects successfully
- [ ] Terminal (Alacritty) opens with Fish shell
- [ ] Fastfetch shows system info on terminal open
- [ ] Night light is enabled (screen looks warm)
- [ ] Wallpapers change automatically
- [ ] Sound works (test with mpv)
- [ ] Bluetooth works (if you have devices)
- [ ] Brave browser is default
- [ ] VS Code opens
- [ ] Neovim works
- [ ] Python runs: `python --version`
- [ ] Node.js runs: `node --version`
- [ ] Git configured: `git config --list`

---

## 🎯 Next Steps

1. **Customize Neovim**: Edit `~/.config/nvim/init.lua`
2. **Configure Fish shell**: Edit `~/.config/fish/config.fish`
3. **Add SSH keys**: `ssh-keygen -t ed25519`
4. **Install Python packages**: `pip install --user pandas numpy`
5. **Set up development projects**
6. **Configure Anki for UPSC studies**
7. **Set up Obsidian vault**
8. **Publish config to GitHub** (remove any sensitive data first!)

---

## 💡 Tips

- **Monthly updates**: Run `rebuild` once a month
- **Backup important data**: BTRFS snapshots help, but external backup is crucial
- **Learn Nix language**: It's powerful once you understand it
- **Join NixOS community**: Discourse, Reddit, Matrix
- **Keep this configuration in Git**: Track all changes

---

## 🎊 Congratulations!

You now have a **production-ready, secure, beautiful, and powerful** NixOS system tailored to your needs!

**Enjoy coding, learning, and conquering the UPSC! 📚**

---

**System**: NixOS 25.05 "Warbler"  
**User**: shinchan  
**Hostname**: NixOS  
**Desktop**: Niri (Wayland)  
**Terminal**: Alacritty + Fish  
**Editor**: Neovim (default) + VS Code

---

*Built with ❤️ and extensive research*  
*Based on official NixOS 25.05 documentation and community best practices*