if [ -z "${WAYLAND_DISPLAY}" ] && [ -n "$XDG_VTNR" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  exec niri-session >> ~/.local/state/niri/niri.log 2>&1
fi
