# Disaster Recovery Plan — Full System Restore Assessment

> **Date:** 2025-08-06 (rev. 2)  
> **System:** Framework Laptop 13 AMD Ryzen 5 7640U (codename: `arya`)  
> **OS:** Arch Linux (rolling)  
> **DE/WM:** niri (Wayland)  
> **Dotfiles:** `yadm` → `git@github.com:elmuz/dotfiles.git`

---

## 1. Executive Summary

This document assesses the current backup/recovery setup and outlines a strategy for a **recreation-based disaster recovery** (as opposed to full-disk cloning). Goal: given a vanilla Arch ISO install, restore the system to a usable state with minimal friction.

**Guiding philosophy (rev. 2):**
- **Minimal by design.** Keep only what is actually used and has configs. A fresh install is an opportunity to *discard* cruft, not to pixel-perfect clone.
- **Not over-automated.** Many things are already part of the base system. The master script handles the *essential* skeleton; the rest is a reviewed checklist.
- **Secrets strategy:** identity/login secrets live in self-hosted **Bitwarden**; the long-term plan is to move SSH onto **GPG**. Local private material must be decryptable from a backup (yadm encrypt).

---

## 2. Current State Assessment

### 2.1 What Works Well ✅

| Area | Status | Notes |
|------|--------|-------|
| `yadm` dotfiles | ✅ Good | 83 files tracked, SSH push to GitHub, GPG-encrypted secrets archive |
| SSH public keys | ✅ Good | Tracked in yadm |
| Themes (Nordic) | ✅ Good | Scripted download in INSTALL.sh |
| Custom keyboard layout | ✅ Good | `wasd` tracked, copied to /usr/share/X11/xkb/symbols/ |
| xkcd-viewer | ✅ Good | Self-built Rust project → **source on GitHub** (`elmuz/xkcd-viewer`), rebuildable |
| GPG identity key | ✅ Good | ed25519 key exists (2026-01-01) |

### 2.2 Broken / Stale / Deprecated ❌

| Issue | Severity | Resolution |
|-------|----------|-----------|
| Charge-thresholds scripts | 🔴 REMOVE | **Delete** — Framework AMD 7040 handles thresholds via BIOS |
| `gnome-keyring` in portal config | 🟡 Clean | Not used; portal Secret line is stale → remove/verify |
| `fuzzel-rbw` | 🟡 Remove | Experiment, dropped (99% Bitwarden usage is in-browser) |
| niri monitor name hardcoded | 🟡 LOW | `"PNP(YEY) YMG-4K32-01 demoset-1"` — reimplement single/double-screen split (low priority) |
| waybar backlight device | 🟡 LOW | `amdgpu_bl1`, hardware-specific |
| `wallpaper.sh`/`wbg` | 🟡 Orphaned | Not invoked anywhere; actual mechanism is `awww` |
| AWS credentials filename | 🔴 FIX | `credentials,` (trailing comma) → `credentials` |

### 2.3 Secrets Inventory

| Secret type | Where it lives | Status / Plan |
|-------------|---------------|---------------|
| Login / identity secrets | **Bitwarden** (self-hosted) | ✅ Out of DR scope — laptop is a client; server is external to this scenario |
| SSH private keys | `~/.ssh/id_*.key` | 🔴 Local, encrypted in yadm; plan: migrate to GPG |
| GPG key | `~/.local/share/gnupg/` | 🔴 **NOT covered by yadm encrypt** → must add backup |
| AWS credentials | `~/.config/aws/credentials` | 🔴 Fix filename; add to yadm encrypt |
| exercism token | `~/.config/exercism/user.json` | ✅ In yadm encrypt |

**GPG migration note:** GPG key exists but `gpg-agent.conf` has **no `enable-ssh-support`** — SSH is not yet routed through GPG. To complete the plan: add the auth subkey + `enable-ssh-support` to `gpg-agent.conf`, and **back up the GPG private keys** (they are the linchpin of the future identity setup).

### 2.4 Gaps in yadm Coverage

**Config dirs to TRACK (add to yadm):**

| Config | Path | Why |
|--------|------|-----|
| xdg-desktop-portal | `~/.config/xdg-desktop-portal/` | Portal config for niri (gtk;wlr) |
| qt6ct | `~/.config/qt6ct/qt6ct.conf` | Qt6 theme (Nordic, qt6gtk2) |
| nwg-look | `~/.config/nwg-look/` | GTK theming tool |
| qalculate | `~/.config/qalculate/` | Calculator prefs |
| Thunar | `~/.config/Thunar/uca.xml` | Custom actions (skip accels.scm) |
| neofetch / fastfetch | `~/.config/neofetch/` | Cosmetic |
| swayimg | `~/.config/swayimg/` | Image viewer |
| kde.org/ghostwriter | `~/.config/kde.org/ghostwriter.conf` | Markdown editor theme |
| pavucontrol.ini | `~/.config/pavucontrol.ini` | Minimal |
| niri/wallpaper.sh | `~/.config/niri/wallpaper.sh` | Legacy, but tiny & documents the mechanism |

**Config dirs to NOT track (by design):**

| Path | Why |
|------|-----|
| `~/.mozilla/` (Firefox profile) | **Synced via Mozilla account** — restore from remote, don't back up locally |
| Auto-generated configs (window sizes, geometry) | Useless noise, but harmless if present |
| Large caches / `~/.cache/awww` | Volatile, not worth backing up |

### 2.5 Package List

**Current state:** three stale lists (Sway/Hyprland era). ~60 installed packages appear in no list (niri, kitty, mako, aww, brightnessctl, wl-gammarelay-rs, superfile, snapper, fwupd, fprintd, pi-coding-agent, …).

**Rev. 2 approach — minimal & curated:**
- Maintain **one authoritative, manually-curated list** of packages you *actually use and configure* (not `pacman -Qqe` wholesale).
- A fresh install is a **cleaning opportunity**: start from the curated essential list, add back only what you need.
- Accept that this is imperfect; the ritual is a deliberate review, not automation.

### 2.6 System-Level Post-Install Steps (Not Captured by yadm)

| Step | Location | State |
|------|----------|-------|
| ALHP repos (x86-64-v4) | `/etc/pacman.conf` | ✅ |
| makepkg flags (`-march=native`) | `/etc/makepkg.conf` | ✅ |
| Custom keyboard layout | `/usr/share/X11/xkb/symbols/wasd` | ✅ via INSTALL.sh |
| Locale / keymap | `/etc/locale.conf` | ✅ us |
| Network (iwd) | `/etc/iwd/main.conf` | ✅ documented |
| Snapper configs + timers | `/etc/snapper/configs/{home,root}` | ✅ |
| User groups (video, wheel) | — | ✅ via INSTALL.sh |
| Firmware (fwupd, fw-ectool-git) | — | 🟡 add to pkglist |
| Fingerprint (fprintd) | — | 🔴 biometric, cannot restore — re-enroll by hand |
| power-profiles-daemon | systemd | ✅ active |
| **Charge thresholds** | — | **REMOVED** — handled by BIOS on Framework |

### 2.7 Uncommitted Changes (Would Be Lost)

```
 M .config/fontconfig/fonts.conf
 M .config/waybar/style.css
```

### 2.8 Data / Tooling Inventory

| Item | Strategy |
|------|----------|
| `~/Pictures/wallpaper_C.jpg` | Low priority; optional small backup |
| `~/tools/xkcd-viewer` | **Rebuild from GitHub** (`elmuz/xkcd-viewer`), don't back up binary |
| `~/tools/wbg` | Self-built; only used by legacy wallpaper.sh → evaluate/delete |
| `~/tools/pycharm`, `aws-cli-v2`, `zed`, `zedless`, `nebula-sync` | **Do NOT recreate** in DR — one-off manual installs |
| `~/Documents/last-will`, `~/tools/resume` | Separate git repos |
| `~/Videos ~/Music ~/Downloads` | Bulk data → external HDD (rsnapshot) |

---

## 3. DR Architecture: Recreation vs Restore

```
┌────────────────────────────────────────────────┐
│  RECREATION (from scratch, post-ISO install)    │
│  ─────────────────────────────────────────────  │
│  • Master script + curated package list        │
│  • System config (pacman, makepkg, keyboard…)  │
│  • yadm clone → dotfiles                       │
│  • yadm decrypt → SSH keys + GPG backup        │
│  • AUR helper (paru)                           │
│  • Themes/icons/cursors                        │
│  • zsh + oh-my-zsh + nvim plugins              │
│  • xkcd-viewer: clone + cargo build            │
│  • Firmware, fingerprint re-enroll             │
└────────────────────────────────────────────────┘
                        ↓
┌────────────────────────────────────────────────┐
│  RESTORE (from remote / re-enroll)              │
│  ─────────────────────────────────────────────  │
│  • Bitwarden login (self-hosted)               │
│  • Mozilla/Firefox from account sync           │
│  • Wallpaper (optional set via `awww img`)     │
│  • Bulk data (Videos/Music/Downloads)          │
│  • GPG keys (from backup)                      │
└────────────────────────────────────────────────┘
```

---

## 4. What Needs Action (Prioritized)

### 🔴 Action now
1. Commit uncommitted yadm changes (`fonts.conf`, `waybar/style.css`)
2. **Delete** charge-thresholds files from repo + remove from INSTALL.sh
3. Fix AWS credentials filename (`credentials,` → `credentials`)
4. **Add GPG private keys to backup** (yadm encrypt or documented copy) — critical for the GPG/SSH migration
5. Remove `gnome-keyring` reference from `~/.config/xdg-desktop-portal/` (clean stale Secret line)
6. Remove `fuzzel-rbw` from pkglist (experiment dropped)

### 🟡 Do next
7. Commit untracked configs to yadm (see §2.4)
8. Build the curated minimal pkglist (not wholesale `-Qqe`)
9. Reimplement niri single/double-screen split (low priority, nice-to-have)

### 🟢 Optional
10. Back up wallpaper image (small, cheap)
11. Complete GPG/SSH migration (`enable-ssh-support` + auth subkey)

---

## 5. Action Plan — Phased Implementation

### Phase 0: Hygiene (DONE ✅)
- [x] `yadm add` + commit the 2 modified files
- [x] `git rm` charge-thresholds.service / charge-thresholds.sh
- [x] Remove charge-thresholds from INSTALL.sh + INSTALL.md
- [x] Fix `~/.config/aws/credentials,` → `credentials` (+ zshenv)
- [x] Add GPG key material to yadm encrypt (private-keys-v1.d + revocs)
- [x] Clean `gnome-keyring` line from portal config
- [x] Remove `fuzzel-rbw` from pkglist (wasn't in any list — noted only)

### Phase 1: Curated package list (DONE ✅ — 122 pkgs in `~/.config/pkgs/pkglist.txt`)
- [x] Canonical list promoted to `~/.config/pkgs/pkglist.txt` (tracked by yadm)
- [x] INSTALL.sh now installs from `$XDG_CONFIG_HOME/pkgs/pkglist.txt`
- [x] Deleted stale lists: `pkglist.txt.new`, dotfiles `pkglist{,-intel,-amd}.txt`
- [x] Dropped: sway stack (kept swaylock), gammastep/redshift, rofi, xbindkeys, feh, i3-wm, fuzzel-rbw, alacritty, uwsm, lf, mc, xorg-xinit/xorg-host
- [x] Dropped unused apps: chromium, code, monero-gui, gnome-klotski, love (simple `pacman -S` if ever needed)
- [x] Excluded: texlive-fonts* (rare), flatpak (no apps)
- [x] Kept superseded **configs tracked** (alacritty, sway, gammastep, rofi, etc.) — lightweight, possible return
- [x] PyCharm/zed/aws-cli-v2/nebula-sync → manual one-offs, NOT in list; PyCharm has online-synced profile

### Phase 2: Capture dotfiles
- [ ] `yadm add` the §2.4 tracked list
- [ ] Add `~/.config/niri/wallpaper.sh`
- [ ] Extend `.config/yadm/encrypt` with `.local/share/gnupg/` (GPG keys) + `aws/credentials`
- [ ] Document the **"do not back up by design"** list (Mozilla, caches) in INSTALL.md

### Phase 3: System-setup script
- [ ] `system-setup.sh`: ALHP repos, makepkg flags, keyboard layout, snapper timers, power-profiles, user groups, locale, iwd, fwupd
- [ ] **No** charge-thresholds step (BIOS handles it)

### Phase 4: Rewrite INSTALL.sh / INSTALL.md
- [ ] Modular master script (base → packages → dotfiles → system → themes → shell → services → decrypt)
- [ ] Add **xkcd-viewer build step**: `git clone git@github.com:elmuz/xkcd-viewer && cargo build --release && cp target/release/xkcd-viewer ~/.local/bin/`
- [ ] Add post-install checklist: fingerprint re-enroll, Bitwarden login, Firefox account sync, wallpaper set (`awww img ~/Pictures/wallpaper_C.jpg`)
- [ ] Update docs to niri stack; remove Sway/Hyprland references

### Phase 5: Backup strategy for data
- [ ] rsnapshot for `~/Videos ~/Music ~/Downloads` → external HDD
- [ ] Ensure `~/Documents/last-will`, `~/tools/resume` git repos are pushed
- [ ] Make `backup-to-external-hdd.sh` actually run (currently just prints instructions)

### Phase 6: DR testing + living document
- [ ] Quarterly test from ISO in a VM/spare disk
- [ ] Maintain a **tool-decision log** (see §7.3) so future-you knows what to recreate vs skip
- [ ] After every major config change: `yadm add` + commit immediately

---

## 6. Master Restore Script Blueprint

```bash
# 4. As user, run the master restore:
curl -sSL https://raw.githubusercontent.com/elmuz/dotfiles/main/.local/share/dotfiles/INSTALL.sh | bash

# 5. Decrypt secrets (SSH keys + GPG):
yadm decrypt

# 6. Build personal tools:
git clone git@github.com:elmuz/xkcd-viewer ~/projects/xkcd-viewer
(cd ~/projects/xkcd-viewer && cargo build --release)
cp ~/projects/xkcd-viewer/target/release/xkcd-viewer ~/.local/bin/

# 7. Manual checklist:
#    - Login to Bitwarden (self-hosted)
#    - Login to Mozilla account (Firefox sync)
#    - Enroll fingerprint (fprintd)
#    - Set wallpaper if not restored: awww img ~/Pictures/wallpaper_C.jpg
#    - Adjust monitor names if hardware differs
```

---

## 7. Key Findings & Recommendations

### 7.1 Critical Fixes
1. **GPG keys not backed up** — the linchpin of your future identity setup; add to yadm encrypt
2. **Charge thresholds** — remove (BIOS handles)
3. **AWS credentials filename** — fix trailing comma
4. **Uncommitted yadm changes** — commit

### 7.2 Observations
| Observation | Recommendation |
|------------|---------------|
| GPG key exists but `gpg-agent.conf` lacks `enable-ssh-support` | Complete migration: add auth subkey + flag, back up keys |
| `wallpaper.sh`/`wbg` orphaned; actual wallpaper is `awww` | Track wallpaper.sh (tiny doc), delete wbg unless re-used |
| `awww` memory is in `~/.cache/awww`, flaky ~1/20 boots | Document `awww img` fallback in checklist |
| Portal config references non-installed `gnome-keyring` | Clean the Secret line |
| `fuzzel-rbw` installed but dropped | Remove from pkglist |
| `~/tools` contains one-off manual installs (pycharm, aws-cli, zed) | Don't recreate in DR; keep a tool-decision log instead |
| Monitor-qualified niri config | Re-add single/double-screen split (low priority) |

### 7.3 Tool-Decision Log (living document)
Keep a short log in INSTALL.md of what to recreate vs skip, so DR stays honest:
- **Recreate from GitHub:** xkcd-viewer (cargo build)
- **Skip (manual one-off, simple setup):** zed, aws-cli-v2, nebula-sync
- **PyCharm:** online-synced profile; NOT recreated; planned to be abandoned for Vim/FOSS IDE
- **Superseded (pkg dropped, config kept tracked):** sway*, gammastep/redshift, rofi, xbindkeys, feh, i3-wm, fuzzel-rbw, alacritty, uwsm, lf, mc
- **Unused apps (drop, `pacman -S` if ever needed):** chromium, code, monero-gui, gnome-klotski, love, texlive-fonts*
- **Evaluate (self-built):** wbg (only used by legacy wallpaper.sh)
- **Remote-restore:** Firefox (Mozilla sync), Bitwarden (self-hosted, out of DR scope)
- **Re-enroll by hand:** fingerprint (fprintd)

---

## 8. Appendix

### Regenerate current state
```bash
pacman -Qqe | sort > ~/.config/pkgs/pkglist-$(date +%F).txt
pacman -Qqm | sort          # AUR
systemctl list-unit-files --state=enabled --no-legend                    # system
systemctl --user list-unit-files --state=enabled --no-legend             # user
```

### Do-not-back-up (by design)
```
~/.mozilla/          → Mozilla account sync
~/.cache/awww        → volatile, re-set via `awww img`
auto-generated geometry configs
```

### Secrets coverage map
```
Bitwarden (self-hosted)  → login/identity secrets
yadm encrypt (GPG)       → SSH keys, exercises token, AWS (after fix), GPG keys*
GPG keys                 → add to yadm encrypt (private-keys-v1.d + key passphrase)
* future: SSH via gpg-agent (enable-ssh-support)
```