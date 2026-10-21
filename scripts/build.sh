#!/bin/bash
# SidSpin — Debian sid live ISO build script.
#
# Produces a live ISO that boots into a minimal KDE Plasma session and
# installs to disk with Calamares, letting you pick the desktop you want
# on the installed system.
#
# Requires: live-build, xorriso, rsync, and sudo.  The script re-runs
# itself as root, because live-build needs it.
# Mirror: http://mirror.linux.org.au/debian (override with SIDSPIN_MIRROR).

set -euo pipefail

PROJECT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$PROJECT/config"
BUILD="$PROJECT/build"
MIRROR="${SIDSPIN_MIRROR:-http://mirror.linux.org.au/debian}"
OUTPUT="$BUILD/sidspin-amd64.iso"

log()  { echo "[sidspin] $*"; }
die()  { echo "[sidspin] ERROR: $*" >&2; exit 1; }

# live-build needs root; re-run the whole script as root so that every
# file it creates belongs to the same user.
if [ "$(id -u)" -ne 0 ]; then
    command -v sudo >/dev/null || die "run this script as root (it needs sudo to re-exec itself)"
    log "re-running as root"
    exec sudo --preserve-env=SIDSPIN_MIRROR "$0" "$@"
fi

command -v lb      >/dev/null || die "live-build is not installed"
command -v rsync   >/dev/null || die "rsync is not installed"
command -v xorriso >/dev/null || die "xorriso is not installed"

# ------------------------------------------------------------------ unmount
# An interrupted build leaves mounts behind in build/chroot.
for m in dev/pts dev proc sys; do
    if mountpoint -q "$BUILD/chroot/$m" 2>/dev/null; then
        umount -R "$BUILD/chroot/$m" 2>/dev/null || true
    fi
done

# -------------------------------------------------------------------- clean
rm -rf "$BUILD"
mkdir -p "$BUILD"

# ---------------------------------------------------------------- lb config
# Live mode: the ISO ships a full desktop session (KDE Plasma).
cd "$BUILD"
log "configuring live-build (sid, live desktop, amd64)"
lb config \
    --mode debian \
    --distribution sid \
    --architecture amd64 \
    --mirror-bootstrap "$MIRROR" \
    --mirror-chroot "$MIRROR" \
    --mirror-chroot-security "$MIRROR" \
    --mirror-binary "$MIRROR" \
    --mirror-binary-security "$MIRROR" \
    --linux-packages "linux-image" \
    --initramfs live-boot \
    --iso-volume "SIDSPIN" \
    --iso-application "SidSpin" \
    --bootappend-live "boot=live components live-config.username=user quiet splash console=ttyS0,115200n8" \
    2>&1 | tail -3

# ----------------------------------------------------------- package lists
# Package lists must be flat in config/package-lists/ (sid's live-build
# ignores lists in subdirectories).
mkdir -p "$BUILD/config/package-lists"
cp "$CONF/package-lists/"*.list "$BUILD/config/package-lists/"

# ------------------------------------------------------------------- hooks
# live-build only runs config/hooks/normal/*.hook.chroot when there is at
# least one hook in config/hooks/live/ too, so both are staged.
mkdir -p "$BUILD/config/hooks/normal" "$BUILD/config/hooks/live"
for hook in "$CONF/hooks/normal/"*.hook.chroot; do
    [ -e "$hook" ] || continue
    install -m 755 "$hook" "$BUILD/config/hooks/normal/$(basename "$hook")"
done
for hook in "$CONF/hooks/live/"*.hook.chroot; do
    [ -e "$hook" ] || continue
    install -m 755 "$hook" "$BUILD/config/hooks/live/$(basename "$hook")"
done

# ---------------------------------------------------------------- includes
# Calamares settings, branding, the desktop chooser and the helper scripts
# land in the live image here.
#
# live-build copies config/includes.chroot/ into the chroot *after* the
# packages are installed, so it can override files the packages ship (the
# Calamares configuration, for one).  The directory has to exist before the
# copy, and the empty includes.chroot_after_packages/ that "lb config"
# creates has to go, otherwise live-build prefers it.
rmdir "$BUILD/config/includes.chroot_after_packages" 2>/dev/null || true
mkdir -p "$BUILD/config/includes.chroot"
if [ -d "$CONF/includes.chroot" ]; then
    cp -a "$CONF/includes.chroot/." "$BUILD/config/includes.chroot/"
fi

# ------------------------------------------------------------------- build
log "building live ISO (bootstraps sid, this takes a while)"
lb build 2>&1 | tail -5

ISO="$BUILD/live-image-amd64.hybrid.iso"
[ -f "$ISO" ] || die "lb build produced no ISO"

cp "$ISO" "$OUTPUT"
log "built $OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
