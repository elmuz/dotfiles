#!/bin/bash

sudo apt-get update && sudo apt install -y \
  autoconf \
  automake \
  build-essential \
  bison \
  curl \
  edid-decode \
  git \
  libcairo2-dev \
  libexpat1-dev \
  libegl1-mesa-dev \
  libevdev-dev \
  libffi-dev \
  libgbm-dev \
  libgles2-mesa-dev \
  libgtk-4-dev \
  libgtk-3-dev \
  libjson-c-dev \
  libjsoncpp-dev \
  liblcms2-dev \
  libmtdev-dev \
  libpango1.0-dev \
  libtool \
  libseat-dev \
  libsystemd-dev \
  libudev-dev \
  libwacom-dev \
  libx11-dev \
  libxcb1-dev \
  libxcb-composite0-dev \
  libxcb-dri3-dev \
  libxcb-ewmh-dev \
  libxcb-icccm4-dev \
  libxcb-present-dev \
  libxcb-res0-dev \
  libxcb-render0-dev \
  libxcb-render-util0-dev \
  libxcb-shape0-dev \
  libxcb-shm0-dev \
  libxcb-xkb-dev \
  libxcb-xfixes0-dev \
  libxcb-xinput-dev \
  libxml2-dev \
  ninja-build \
  pkg-config \
  xwayland \
  xcb-proto \
  xutils-dev

export PREFIX=/opt/sway
sudo mkdir -p $PREFIX

export WORKDIR=$HOME/build
mkdir -p $WORKDIR && cd $WORKDIR

# --- Idempotent uv venv setup with repair ---
# Check if the .venv directory exists
if [ -d "$WORKDIR/.venv" ]; then
    # If it exists, check for pyvenv.cfg
    if [ ! -f "$WORKDIR/.venv/pyvenv.cfg" ]; then
        echo "Broken virtual environment detected (pyvenv.cfg missing). Removing and recreating..."
        rm -rf "$WORKDIR/.venv" || { echo "Error: Failed to remove broken virtual environment. Exiting."; exit 1; }
        uv venv || { echo "Error: Failed to create uv virtual environment after removal. Exiting."; exit 1; }
    else
        echo "uv virtual environment already exists and appears healthy."
    fi
else
    echo "uv virtual environment does not exist. Creating..."
    uv venv || { echo "Error: Failed to create uv virtual environment. Exiting."; exit 1; }
fi

export PATH="$WORKDIR/.venv/bin:$PATH"
uv pip install "meson>=1.3" || { echo "Error: Failed to install meson>=1.3. Exiting."; exit 1; }


export PKG_CONFIG_PATH="$PREFIX/lib/x86_64-linux-gnu/pkgconfig:$PREFIX/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"

# libinput
export LIBINPUT_VERS=1.28.1
cd "$WORKDIR"
if [ -d libinput ]; then
    cd libinput && git fetch
else
    git clone https://gitlab.freedesktop.org/libinput/libinput \
    && cd libinput
fi
rm -rf build \
  && git checkout "$LIBINPUT_VERS" \
  && meson setup --prefix="$PREFIX" build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install

# pixman
export PIXMAN_VERS=pixman-0.46.2
cd "$WORKDIR"
if [ -d pixman ]; then
    cd pixman && git fetch
else
    git clone https://gitlab.freedesktop.org/pixman/pixman.git \
    && cd pixman
fi
rm -rf build \
  && git checkout "$PIXMAN_VERS" \
  && meson setup --prefix="$PREFIX" build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install

# libxkbcommon
export XKBCOMMON_VERS=xkbcommon-1.10.0
cd "$WORKDIR"
if [ -d libxkbcommon ]; then
    cd libxkbcommon && git fetch
else    
    git clone https://github.com/xkbcommon/libxkbcommon.git \
    && cd libxkbcommon
fi
rm -rf build \
  && git checkout "$XKBCOMMON_VERS" \
  && meson setup --prefix="$PREFIX" build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install

# libdrm
export LIBDRM_VERS=libdrm-2.4.125
cd "$WORKDIR"
if [ -d libdrm ]; then
    cd libdrm && git fetch
else
    git clone https://gitlab.freedesktop.org/mesa/libdrm.git \
    && cd libdrm
fi
rm -rf build \
  && git checkout "$LIBDRM_VERS" \
  && meson setup --prefix="$PREFIX" build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install

# wayland
export WAYLAND_VERS=1.23.93
cd "$WORKDIR"
if [ -d wayland ]; then
    cd wayland && git fetch
else
    git clone https://gitlab.freedesktop.org/wayland/wayland.git \
    && cd wayland
fi
rm -rf build \
  && git checkout "$WAYLAND_VERS" \
  && meson setup --prefix="$PREFIX" -Ddocumentation=false build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install

# wayland-protocols
export WAYLAND_PROTO_VERS=1.45
cd "$WORKDIR"
if [ -d wayland-protocols ]; then
    cd wayland-protocols && git fetch
else
    git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git \
    && cd wayland-protocols
fi
rm -rf build \
  && git checkout "$WAYLAND_PROTO_VERS" \
  && meson setup --prefix="$PREFIX" -Dtests=false build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install

# hwdata
export HWDATA_VERS=v0.397
cd "$WORKDIR"
if [ -d hwdata ]; then
    cd hwdata && git fetch
else
    git clone https://github.com/vcrhonek/hwdata.git \
    && cd hwdata 
fi
rm -rf build \
  && git checkout "$HWDATA_VERS" \
  && ./configure --prefix="$PREFIX" --disable-blacklist \
  && make \
  && sudo make install

# libdisplay-info
export LIBDISPLAY_INFO_VERS=0.2.0
cd "$WORKDIR"
if [ -d libdisplay-info ]; then
    cd libdisplay-info && git fetch
else
    git clone https://gitlab.freedesktop.org/emersion/libdisplay-info.git \
    && cd libdisplay-info
fi
rm -rf build \
  && git checkout "$LIBDISPLAY_INFO_VERS" \
  && meson setup --prefix="$PREFIX" build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install

# libliftoff
export LIBLIFTOFF_VERS=v0.5.0
cd "$WORKDIR"
if [ -d libliftoff ]; then
    cd libliftoff && git fetch
else
    git clone https://gitlab.freedesktop.org/emersion/libliftoff.git \
    && cd libliftoff
fi
rm -rf build \
  && git checkout "$LIBLIFTOFF_VERS" \
  && meson setup --prefix="$PREFIX" build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install

# libxcb-errors
export LIBXCB_ERRORS_VERS="xcb-util-errors-1.0.1"
cd "$WORKDIR"
if [ -d libxcb-errors ]; then
    cd libxcb-errors && git fetch
else
    git clone --recurse-submodules https://gitlab.freedesktop.org/xorg/lib/libxcb-errors.git \
    && cd libxcb-errors
fi
git checkout "$LIBXCB_ERRORS_VERS"
./autogen.sh
./configure --prefix="$PREFIX" --libdir="$PREFIX/lib/x86_64-linux-gnu"
make
sudo make install

# wlroots
export WLROOTS_VERS=0.19.0
export WLR_XWAYLAND="/usr/bin/Xwayland"
cd "$WORKDIR"
if [ -d wlroots ]; then
    cd wlroots && git fetch
else
    git clone https://gitlab.freedesktop.org/wlroots/wlroots.git \
    && cd wlroots
fi
rm -rf build \
  && git checkout "$WLROOTS_VERS" \
  && meson setup --prefix="$PREFIX" -Dxwayland=enabled build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install

# sway
export SWAY_VERS=1.11
cd "$WORKDIR"
if [ -d sway ]; then
    cd sway && git fetch
else
    git clone https://github.com/swaywm/sway.git \
    && cd sway
fi
rm -rf build \
  && git checkout "$SWAY_VERS" \
  && meson setup --prefix="$PREFIX" build/ \
  && ninja -C build/ \
  && sudo ninja -C build/ install
