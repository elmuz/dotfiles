#!/usr/bin/env python3

import json
import subprocess
import sys


def get_windows():
    """Get all windows from niri and return a mapping of display strings to window IDs"""
    try:
        # Get window information from niri
        result = subprocess.run(
            ["niri", "msg", "--json", "windows"],
            capture_output=True,
            text=True,
            check=True,
        )
        windows = json.loads(result.stdout)

        # Create mapping: "[app_id] title" -> window_id
        window_map = {}
        fuzzel_options = []

        for window in windows:
            window_id = window.get("id")
            app_id = window.get("app_id", "Unknown")
            title = window.get("title", "Untitled")

            # Create display string for fuzzel
            display_string = f"{title}\0icon\x1f{app_id}"

            # Store mapping
            window_map[f"{title}"] = window_id
            fuzzel_options.append(display_string)

        return window_map, fuzzel_options

    except subprocess.CalledProcessError as e:
        print(f"Error getting windows from niri: {e}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON from niri: {e}", file=sys.stderr)
        sys.exit(1)


def launch_fuzzel(options):
    """Launch fuzzel with the given options and return the selected option"""
    try:
        # Create input for fuzzel
        input_text = "\n".join(options)

        # Launch fuzzel
        result = subprocess.run(
            [
                "fuzzel",
                "--dmenu",
                "--icon-theme",
                "Papirus",
            ],
            input=input_text,
            capture_output=True,
            text=True,
            check=True,
        )

        return result.stdout.strip()

    except subprocess.CalledProcessError as e:
        if e.returncode == 2:  # User cancelled
            sys.exit(0)
        else:
            print(f"Error launching fuzzel: {e}", file=sys.stderr)
            sys.exit(1)


def focus_window(window_id):
    """Focus the window with the given ID"""
    try:
        subprocess.run(
            ["niri", "msg", "action", "focus-window", "--id", str(window_id)],
            check=True,
        )
    except subprocess.CalledProcessError as e:
        print(f"Error focusing window {window_id}: {e}", file=sys.stderr)
        sys.exit(1)


def main():
    # Get windows and create mapping
    window_map, fuzzel_options = get_windows()

    if not fuzzel_options:
        print("No windows found", file=sys.stderr)
        sys.exit(1)

    # Launch fuzzel and get user selection
    selected = launch_fuzzel(fuzzel_options)

    # Check if selection is valid
    if selected not in window_map:
        print(f"Invalid selection: {selected}", file=sys.stderr)
        sys.exit(1)

    # Focus the selected window
    window_id = window_map[selected]
    focus_window(window_id)


if __name__ == "__main__":
    main()
