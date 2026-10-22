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
- **Own UI**: the welcome page and the desktop chooser are our own QML,
  loaded from the branding directory, in SidSpin's colours.
- **Partition editors**: GParted and KDE Partition Manager are in the live
  session, so you can lay out or shrink the disk yourself before you
  install.
- **sid**: tracks Debian unstable.

## Layout

```
scripts/build.sh                      live-build orchestrator
config/package-lists/00-live.list.chroot   live session (KDE Plasma + apps)
config/package-lists/10-installer.list.chroot  installer + partition editors
config/includes.chroot/               copied into the live image
    etc/calamares/settings.conf       installer flow
    etc/calamares/modules/            module configuration
    etc/calamares/branding/sidspin/   branding, slideshow, our QML pages
    etc/sddm.conf.d/                  live session auto-login
    usr/bin/sidspin-install           launcher for the installer
    usr/bin/sidspin-install-de        installs the chosen desktop
config/hooks/normal/                  chroot hooks (locale, plymouth, ...)
config/hooks/live/                    required for the normal hooks to run
```

## Custom pages

Calamares can load a view module's QML from the branding directory
instead of its built-in copy, using two keys in the module's config:

```yaml
qmlSearch: branding
qmlFilename: /etc/calamares/branding/sidspin/welcome.qml
```

We use that for two pages:

| Module | File | What it does |
|---|---|---|
| `welcomeq` | `branding/sidspin/welcome.qml` | Our own welcome page: what SidSpin is, and the three steps of the install |
| `packagechooserq` | `branding/sidspin/chooser.qml` | The desktop chooser, with a description per desktop and a full/minimal toggle |

The chooser writes the chosen desktop and profile to GlobalStorage under
`packagechooser_packagechooserq`, as `<desktop>:<profile>`, which the
`shellprocess` module expands into the argument for
`sidspin-install-de`.

## Desktops and profiles

The installer asks for two things: which desktop, and how much of it.

| Desktop | Minimal | Full |
|---|---|---|
| KDE Plasma | `plasma-desktop` | `kde-plasma-desktop` |
| GNOME | `gnome-core` | `task-gnome-desktop` |
| XFCE | `xfce4` | `task-xfce-desktop` |
| MATE | `mate-desktop-environment-core` | `task-mate-desktop` |
| LXQt | `lxqt-core` | `task-lxqt-desktop` |
| Cinnamon | `cinnamon` | `task-cinnamon-desktop` |

Roughly how much each profile weighs:

| Desktop | Minimal | Full |
|---|---|---|
| GNOME | ~390 MB | ~500 MB |
| XFCE | ~85 MB | ~280 MB |
| MATE | ~290 MB | ~620 MB |
| LXQt | ~150 MB | ~340 MB |
| Cinnamon | ~200 MB | ~860 MB |
| KDE Plasma | ~1.8 GB | ~1.8 GB |

KDE Plasma is the odd one out: the live image ships it, so the target
already has the shell, and the difference between the two profiles is
only the application suite that comes with it.

## Build

```bash
cd /home/tagmanpro/Github/Sidspin && ./scripts/build.sh
```

The script re-runs itself as root (live-build needs it), so `sudo
./scripts/build.sh` works too.

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
3. The lists are named `*.list.chroot`, not `*.list`. A plain `*.list` is
   also installed into the ISO's `/pool`, which adds ~1.2 GB of `.deb`
   files we never install from. A `*.list.chroot` only goes into the
   chroot.
4. `chroot_hooks` only runs when `config/hooks/normal/` **and**
   `config/hooks/live/` both contain hooks.
5. `config/includes.chroot/` is copied after the packages are installed, so
   it can override files the packages ship. `lb config` does not create
   that directory, and the empty `includes.chroot_after_packages/` it does
   create takes precedence over it — both have to be handled.
6. `lb config` slimmed options (no `--allow-root`/`--tmpdir`/`--variant`).
7. Debian's `calamares-settings-debian` references modules (`dpkg-unsafe-io`,
   `sources-media`, `sources-final`, `bootloader-config`) that are **not**
   shipped in sid's `calamares` package. The sequence in
   `config/includes.chroot/etc/calamares/settings.conf` only uses modules
   that exist.
8. `policykit-1` was split up; sid has `polkitd` and a separate `pkexec`
   package.

## Verified

- The ISO builds and boots; the live session starts Plasma and logs in.
- The Calamares pages load with our own QML (welcome and desktop chooser),
  tested against Calamares 3.4.2 under Xvfb.
- Clicking a desktop updates `config.packageChoice`, which is what the
  `shellprocess` module expands into the argument for
  `sidspin-install-de`.

## Not verified

- Full install to a booted target (untested)
- UEFI boot (only BIOS tested)
- Desktop chooser → installed desktop (untested)
- Plymouth splash on target (configured but untested)

## Planned

- Optional **extras** on the installer page (office suite, media players,
  and so on) on top of the chosen desktop and profile.
