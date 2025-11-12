# 🐧 NixOS 25.05 "Warbler" - Shinchan's Ultimate Configuration

> **Production-Ready NixOS with Niri Compositor, LUKS Encryption, and Professional Development Environment**

![NixOS Version](https://img.shields.io/badge/NixOS-25.05%20Warbler-blue?style=flat-square&logo=nixos)
![Flakes](https://img.shields.io/badge/Flakes-Enabled-green?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)

---

## 🎯 **Overview**

This is a **professional, modular, and production-ready** NixOS 25.05 configuration featuring:

- **🪟 Niri**: Scrollable-tiling Wayland compositor
- **🔒 Full Disk Encryption**: LUKS2 with single-password unlock
- **🖥️ BTRFS**: Modern filesystem with snapshots and compression
- **🚀 Flakes**: Reproducible and declarative system management
- **🎨 Aesthetic**: Beautiful terminal with Alacritty, Fish shell, and modern CLI tools
- **🛠️ Development**: Ready for Web Dev, Python, C++, JavaScript, Rust, AI/ML, Data Science
- **🔐 Security**: AppArmor, Firewall, DNS over TLS (NextDNS), kernel hardening

---

## 📋 **System Specifications**

| Component | Details |
|-----------|---------|
| **Hostname** | `NixOS` |
| **User** | `shinchan` |
| **CPU** | AMD Ryzen 3 3200G (4 cores, Vega Graphics) |
| **RAM** | 24GB (8GB + 16GB @ 3200MHz) |
| **Storage** | 256GB NVMe SSD (Samsung/WD/Crucial) |
| **Graphics** | AMD Vega 8 (integrated) + NVIDIA-ready |
| **WiFi** | WIOM WiFi (requires iwd backend) |
| **Desktop** | Niri (Wayland scrollable-tiling compositor) |
| **Resolution** | 1920x1080 |
| **Timezone** | Asia/Kolkata (IST) |

---

## ✨ **Key Features**

### 🔒 **Security & Privacy**
- ✅ LUKS2 full disk encryption (single password unlock)
- ✅ AppArmor enabled for application sandboxing
- ✅ Hardened Linux kernel (latest stable)
- ✅ Firewall (firewalld) with strict rules
- ✅ DNS over TLS: NextDNS (241198) → Quad9 → Cloudflare → Google
- ✅ No swap, no zram (24GB RAM is sufficient)
- ✅ Secure boot ready (UEFI)

### 🖥️ **Desktop Environment**
- ✅ **Niri**: Modern Wayland compositor with scrollable tiling
- ✅ **Alacritty**: GPU-accelerated terminal (default)
- ✅ **Fish Shell**: Modern, user-friendly shell with autosuggestions
- ✅ **Fastfetch**: Beautiful system information display
- ✅ **Hyprsunset**: Permanent 4100K night light filter
- ✅ **Auto-wallpaper**: Changes every 3 minutes from `~/Pictures/Wallpapers`

### 🎨 **Aesthetics**
- ✅ **Fonts**: CaskaydiaMono Nerd Font, Cascadia Code, JetBrains Mono
- ✅ **Dark Mode**: System-wide default (GTK, KDE, terminals)
- ✅ **Rounded Corners**: 14px radius on all windows
- ✅ **Transparency**: 0.92 opacity for subtle depth
- ✅ **Beautiful Prompt**: Starship with custom configuration

### 🛠️ **Development Tools**
- ✅ **Python** (with pip, venv, data science libraries)
- ✅ **Node.js & npm** (for web development)
- ✅ **Rust** (cargo, rustc, rust-analyzer)
- ✅ **C/C++** (gcc, g++, cmake)
- ✅ **Neovim** (default editor with LSP support)
- ✅ **VS Code** (official Microsoft build)
- ✅ **Git** with GitHub CLI

### 📦 **Applications**

#### **Native (Nix Packages)**
- 📝 Obsidian, Anki, LibreOffice
- 🗺️ QGIS (geographic information system)
- 🎬 Kdenlive (video editing)
- 🎵 mpv (media player)
- 📄 Okular (PDF reader)
- 🖼️ Gwenview (image viewer)
- ☁️ Megasync (cloud storage)
- 💻 VS Code, Neovim
- 🔄 Git, Btop, Fastfetch

#### **Flatpak Applications**
- 🌐 **Brave** (default browser), Firefox, Chrome
- 💬 Telegram, Signal
- 🖥️ Gnome Boxes (virtual machines)
- 🎥 OBS Studio (screen recording)

---

## 📁 **Directory Structure**

```
/etc/nixos/
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Lock file for reproducibility
├── configuration.nix            # Main system configuration
├── hardware-configuration.nix   # Auto-generated hardware config
├── modules/
│   ├── boot.nix                # Boot loader & kernel settings
│   ├── security.nix            # Security hardening (AppArmor, firewall)
│   ├── networking.nix          # Network configuration (iwd, DNS)
│   ├── users.nix               # User accounts configuration
│   ├── desktop/
│   │   ├── niri.nix           # Niri compositor setup
│   │   ├── fonts.nix          # System fonts configuration
│   │   ├── theming.nix        # GTK/Qt themes
│   │   └── wallpaper.nix      # Wallpaper auto-changer
│   ├── shell/
│   │   ├── fish.nix           # Fish shell configuration
│   │   ├── alacritty.nix      # Alacritty terminal
│   │   └── cli-tools.nix      # CLI utilities (btop, eza, bat, etc.)
│   ├── development/
│   │   ├── languages.nix      # Programming languages
│   │   ├── editors.nix        # Neovim, VS Code
│   │   └── ai-ml.nix          # Python ML/AI libraries
│   └── applications/
│       ├── native.nix         # Native packages
│       └── flatpak.nix        # Flatpak applications
└── scripts/
    ├── install.sh             # Automated installation script
    └── post-install.sh        # Post-installation configuration
```

---

## 🚀 **Installation Instructions**

### **Prerequisites**
1. Download **NixOS 25.05 Minimal ISO** from [nixos.org](https://nixos.org/download)
2. Create a bootable USB drive (8GB minimum)
3. Backup all important data (installation will **wipe the disk**)

### **Step 1: Boot into NixOS Installer**
1. Boot from USB drive
2. Connect to WiFi:
   ```bash
   sudo systemctl start wpa_supplicant
   wpa_cli
   > add_network
   > set_network 0 ssid "YOUR_WIFI_NAME"
   > set_network 0 psk "YOUR_PASSWORD"
   > enable_network 0
   > quit
   ```

### **Step 2: Run Automated Installer**
```bash
# Download the configuration
curl -L https://raw.githubusercontent.com/YOUR_USERNAME/nixos-config/main/scripts/install.sh -o install.sh

# Make it executable
chmod +x install.sh

# Run installation (will prompt for encryption password)
sudo ./install.sh
```

### **Step 3: First Boot**
1. Remove USB drive and reboot
2. Enter your encryption password at the Niri login screen
3. System will unlock and log you in automatically
4. Run post-installation script:
   ```bash
   sudo nixos-rebuild switch --flake /etc/nixos#NixOS
   ```

---

## 🔧 **Post-Installation**

### **Initial Setup**
```bash
# Update the system
sudo nixos-rebuild switch --flake /etc/nixos#NixOS

# Install Flatpak apps
flatpak install flathub com.brave.Browser
flatpak install flathub org.mozilla.firefox
flatpak install flathub com.google.Chrome
flatpak install flathub org.telegram.desktop
flatpak install flathub org.signal.Signal

# Set Brave as default browser
xdg-settings set default-web-browser com.brave.Browser.desktop
```

### **Configure Git**
```bash
git config --global user.name "shinchan"
git config --global user.email "your-email@example.com"
```

### **Add Wallpapers**
```bash
# Create wallpaper directory
mkdir -p ~/Pictures/Wallpapers

# Add your favorite wallpapers there
# They will automatically rotate every 3 minutes
```

---

## 📝 **Usage Guide**

### **Keyboard Shortcuts (Niri)**

| Shortcut | Action |
|----------|--------|
| `Super + T` | Open terminal (Alacritty) |
| `Super + D` | Launch application (fuzzel) |
| `Super + Q` | Close window |
| `Super + Shift + E` | Exit Niri |
| `Super + H/L` | Move focus left/right |
| `Super + J/K` | Move focus up/down |
| `Super + Shift + H/L` | Move window left/right |
| `Super + F` | Toggle fullscreen |
| `Super + O` | Overview mode |

### **System Management**

```bash
# Update system
sudo nixos-rebuild switch --flake /etc/nixos#NixOS

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Clean old generations (keep last 5)
sudo nix-collect-garbage --delete-older-than 15d

# Check system status
fastfetch
btop
```

### **Development Workflow**

```bash
# Python development
python -m venv venv
source venv/bin/activate
pip install numpy pandas scikit-learn

# Node.js development
npm init -y
npm install express

# Rust development
cargo new my-project
cd my-project
cargo run
```

---

## 🔍 **Troubleshooting**

### **WiFi Not Working**
```bash
# Restart NetworkManager
sudo systemctl restart NetworkManager

# Check iwd status
sudo systemctl status iwd

# Scan for networks
iwctl station wlan0 scan
iwctl station wlan0 get-networks
```

### **Niri Not Starting**
```bash
# Check logs
journalctl -u display-manager -b

# Restart display manager
sudo systemctl restart display-manager
```

### **Encrypted Disk Won't Unlock**
- Ensure you're typing the password correctly at the login screen
- Check if systemd initrd is enabled in boot configuration
- Try unlocking manually from TTY (Ctrl+Alt+F2)

---

## 🤝 **Contributing**

This is a personal configuration, but suggestions and improvements are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📚 **Resources**

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Niri Documentation](https://github.com/YaLTeR/niri/wiki)
- [Home Manager](https://nix-community.github.io/home-manager/)
- [NixOS Wiki](https://nixos.wiki/)

---

## 📄 **License**

MIT License - Feel free to use and modify!

---

## 💬 **Acknowledgments**

- **NixOS Community** for the excellent documentation and support
- **Niri Developers** for creating an amazing Wayland compositor
- **YaLTeR** for Niri development
- **All open-source contributors** who make this possible

---

**Built with ❤️ by shinchan | NixOS 25.05 "Warbler"**
