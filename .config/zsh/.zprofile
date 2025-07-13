if [ -z "${WAYLAND_DISPLAY}" ] && [ -n "$XDG_VTNR" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  echo "Running zprofile, shell: $SHELL, args: $@, ppid: $PPID" >> ~/zprofile-debug.log
  exec niri-session
fi
