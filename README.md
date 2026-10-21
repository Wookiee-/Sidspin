# SidSpin

A live ISO for Debian **sid**.

Boot it and you land in a minimal **KDE Plasma** session. Run the installer
and it copies that system to your disk, where you get to pick the desktop
you actually want: KDE Plasma, GNOME, XFCE, MATE, LXQt or Cinnamon.

## What it is

- **Live ISO**: boots into a working desktop, not an installer-only image.
- **Minimal session**: KDE Plasma with Dolphin, Konsole, Kate and Firefox
  ESR. Nothing else.
- **Calamares installer**: partition, create a user, install to disk with
  GRUB.
- **Desktop chooser**: the installer asks which desktop to install and
  points the display manager at it.
- **sid**: tracks Debian unstable.

## Layout

```
scripts/build.sh                      live-build orchestrator
config/package-lists/00-live.list     live session (KDE Plasma + apps)
config/package-lists/10-installer.list  installer-only dependencies
config/includes.chroot/               copied into the live image
    etc/calamares/settings.conf       installer flow
    etc/calamares/modules/            module configuration
    etc/calamares/branding/sidspin/   branding and slideshow
    etc/sddm.conf.d/                  live session auto-login
    usr/bin/sidspin-install           launcher for the installer
    usr/bin/sidspin-install-de        installs the chosen desktop
config/hooks/normal/                  chroot hooks (locale, plymouth, ...)
config/hooks/live/                    required for the normal hooks to run
```

## Build

```bash
cd /home/tagmanpro/Github/Sidspin && sudo ./scripts/build.sh
```

Output: `build/sidspin-amd64.iso`

Override the mirror with `SIDSPIN_MIRROR`, e.g.

```bash
sudo SIDSPIN_MIRROR=https://deb.debian.org/debian ./scripts/build.sh
```

## How the desktop choice works

1. `packagechooser` shows the list of desktops. The chosen id is written to
   GlobalStorage under `packagechooser_packagechooser`.
2. The `shellprocess` module expands `${gs[packagechooser_packagechooser]}`
   and runs `/usr/bin/sidspin-install-de <id>` **inside the target chroot**.
3. That script installs the desktop, removes the desktops that are not
   wanted, sets `/etc/X11/default-display-manager` and enables the matching
   service.

The target starts as a copy of the live session, so KDE Plasma is already
present. Picking a different desktop installs it and purges Plasma.

## sid workarounds

These are the live-build quirks that this build works around:

1. sid has no `live-boot-amd64` → `LB_LINUX_PACKAGES="linux-image"`.
2. Package lists must be flat in `config/package-lists/` (no subdirs).
3. `chroot_hooks` only runs when `config/hooks/normal/` **and**
   `config/hooks/live/` both contain hooks.
4. `config/includes.chroot/` is copied after the packages are installed, so
   it can override files the packages ship.
5. `lb config` slimmed options (no `--allow-root`/`--tmpdir`/`--variant`).
6. Debian's `calamares-settings-debian` references modules (`dpkg-unsafe-io`,
   `sources-media`, `sources-final`, `bootloader-config`) that are **not**
   shipped in sid's `calamares` package. The sequence in
   `config/includes.chroot/etc/calamares/settings.conf` only uses modules
   that exist.

## Not verified

- Full install to a booted target (untested)
- UEFI boot (only BIOS tested)
- Desktop chooser → installed desktop (untested)
- Plymouth splash on target (configured but untested)

## Planned

- Per-desktop **minimal** and **full** profiles (currently every desktop
  installs its Debian task package, i.e. the full set).
- Optional **extras** on the installer page (office suite, media players,
  and so on) on top of the chosen desktop.
