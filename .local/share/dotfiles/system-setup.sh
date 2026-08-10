#!/bin/sh
# system-setup.sh
# Post-install SYSTEM configuration for a fresh Arch Linux setup.
#
# This is the Phase 3 companion to INSTALL.sh: it automates the /etc-level
# changes that yadm cannot capture (they live outside $HOME). It is
# IDEMPOTENT — safe to run multiple times.
#
# Run it as the normal user (sudo is invoked internally):
#   curl -sSL https://raw.githubusercontent.com/elmuz/dotfiles/main/.local/share/dotfiles/system-setup.sh | sh
#   # or, if already cloned:
#   ~/.local/share/dotfiles/system-setup.sh
#
# Sections (see DISASTER_RECOVERY_PLAN.md, Phase 3):
#   1. ALHP optimized repositories (x86-64-v4)    5. power-profiles-daemon
#   2. makepkg.conf (-march=native, RUSTFLAGS)    6. user groups (wheel, video)
#   3. custom keyboard layout (wasd)              7. locale (en_US.UTF-8)
#   4. snapper btrfs snapshots + timers           8. iwd + systemd-resolved
#                                                 9. fwupd refresh timer
#
# NOTE: battery charge thresholds are intentionally NOT configured — the
# Framework AMD 7040 laptop handles them via BIOS.

set -e

info() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

# Prompt for sudo early, so a long-running script doesn't hang mid-way.
sudo -v

# ---------------------------------------------------------------------------
# 1. ALHP optimized repositories
# ---------------------------------------------------------------------------
setup_alhp() {
    info "ALHP optimized repositories (x86-64-v4)"

    if ! /lib/ld-linux-x86-64.so.2 --help 2>/dev/null | grep -q 'x86-64-v4'; then
        warn "CPU does not support x86-64-v4; skipping ALHP."
        return 0
    fi

    # Import the ALHP signing key (fixes a PGP signature verification quirk,
    # see INSTALL.md). Non-fatal: the alhp-keyring package covers most of it.
    if ! gpg --list-keys 2>/dev/null | grep -qi 'anonfunc'; then
        curl -fsSL https://somegit.dev/ALHP/alhp-keyring/raw/branch/master/master/anonfunc.asc \
            -o /tmp/anonfunc.asc 2>/dev/null && gpg --import /tmp/anonfunc.asc >/dev/null 2>&1 \
            || warn "could not import ALHP key (non-fatal)"
    fi

    # NOTE: alhp-keyring + alhp-mirrorlist are installed via pkglist.txt.
    # Add the x86-64-v4 repos to /etc/pacman.conf (idempotent).
    sudo cp /etc/pacman.conf /etc/pacman.conf.bak 2>/dev/null || true
    if ! grep -q '^\[core-x86-64-v4\]' /etc/pacman.conf; then
        sudo sed -i '/^\[core\]$/i [core-x86-64-v4]\nInclude = /etc/pacman.d/alhp-mirrorlist\n' /etc/pacman.conf
    fi
    if ! grep -q '^\[extra-x86-64-v4\]' /etc/pacman.conf; then
        sudo sed -i '/^\[extra\]$/i [extra-x86-64-v4]\nInclude = /etc/pacman.d/alhp-mirrorlist\n' /etc/pacman.conf
    fi

    # Refresh the package DB against the new repos.
    sudo pacman -Syy
}

# ---------------------------------------------------------------------------
# 2. makepkg.conf — native optimizations
# ---------------------------------------------------------------------------
setup_makepkg() {
    info "makepkg.conf (-march=native, native RUSTFLAGS)"
    sudo sed -i '/^CFLAGS=/,/"/c CFLAGS="-march=native -O2 -pipe -fno-plt -fexceptions"' /etc/makepkg.conf
    sudo sed -i '/^CXXFLAGS=/c CXXFLAGS="$CFLAGS -Wp,-D_GLIBCXX_ASSERTIONS"' /etc/makepkg.conf
    sudo sed -i '/^RUSTFLAGS=/c RUSTFLAGS="-C opt-level=3 -C target-cpu=native"' /etc/makepkg.conf
}

# ---------------------------------------------------------------------------
# 3. Custom keyboard layout (wasd)
# ---------------------------------------------------------------------------
setup_keyboard() {
    info "Custom keyboard layout (wasd)"
    SRC="$HOME/.local/share/X11/xkb/symbols/wasd"
    if [ -f "$SRC" ]; then
        sudo install -m 644 "$SRC" /usr/share/X11/xkb/symbols/wasd
    else
        warn "keyboard layout not found at $SRC (yadm clone missing?); skipping."
    fi
}

# ---------------------------------------------------------------------------
# 4. Snapper btrfs snapshots
# ---------------------------------------------------------------------------
setup_snapper() {
    info "Snapper btrfs snapshots"
    if ! command -v snapper >/dev/null 2>&1; then
        warn "snapper not installed; skipping."
        return 0
    fi

    if [ ! -d /etc/snapper/configs/root ]; then
        sudo snapper -c root create-config /
    else
        warn "snapper config 'root' already exists; skipping."
    fi
    if [ ! -d /etc/snapper/configs/home ]; then
        sudo snapper -c home create-config /home
    else
        warn "snapper config 'home' already exists; skipping."
    fi

    sudo systemctl enable --now snapper-timeline.timer snapper-cleanup.timer
}

# ---------------------------------------------------------------------------
# 5. power-profiles-daemon
# ---------------------------------------------------------------------------
setup_power() {
    info "power-profiles-daemon"
    if command -v powerprofilesctl >/dev/null 2>&1; then
        sudo systemctl enable power-profiles-daemon
    else
        warn "power-profiles-daemon not installed; skipping."
    fi
}

# ---------------------------------------------------------------------------
# 6. User groups
# ---------------------------------------------------------------------------
setup_groups() {
    info "User groups (wheel, video)"
    sudo usermod -aG wheel,video "$USER"
}

# ---------------------------------------------------------------------------
# 7. Locale
# ---------------------------------------------------------------------------
setup_locale() {
    info "Locale (en_US.UTF-8)"
    grep -q '^en_US.UTF-8' /etc/locale.gen \
        || sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    sudo locale-gen >/dev/null
    printf 'LANG=en_US.UTF-8\n' | sudo tee /etc/locale.conf >/dev/null
}

# ---------------------------------------------------------------------------
# 8. Network (iwd + systemd-resolved)
# ---------------------------------------------------------------------------
setup_network() {
    info "iwd + systemd-resolved"
    sudo tee /etc/iwd/main.conf >/dev/null <<'EOF'
[General]
EnableNetworkConfiguration=true

[Network]
NameResolvingService=systemd
EOF
    sudo systemctl enable systemd-resolved iwd
}

# ---------------------------------------------------------------------------
# 9. fwupd (firmware updates; the service itself is dbus-activated)
# ---------------------------------------------------------------------------
setup_fwupd() {
    info "fwupd (firmware metadata refresh timer)"
    sudo systemctl enable fwupd-refresh.timer 2>/dev/null \
        || warn "fwupd-refresh.timer not available; skipping."
}

# ---------------------------------------------------------------------------
setup_alhp
setup_makepkg
setup_keyboard
setup_snapper
setup_power
setup_groups
setup_locale
setup_network
setup_fwupd

printf '\n\033[1;32mDone.\033[0m Consider a reboot, then verify:\n'
printf '  pacman -Suy                        # ALHP repos active\n'
printf '  cat /sys/class/power_supply/*/charge_control_end_threshold  # BIOS handles it\n'
printf '  snapper list                       # snapshots configured\n'
