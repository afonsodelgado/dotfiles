#!/usr/bin/env python3
"""Create karabiner.json with the Caps Lock rule already enabled.

Karabiner only reads rules that a profile lists; a file dropped in
assets/complex_modifications is a template the UI can offer, not an active
rule. Writing the profile is what saves a trip through the GUI on a fresh
machine. An existing karabiner.json is left alone, since it is the user's.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
TARGET = os.path.expanduser("~/.config/karabiner/karabiner.json")

if os.path.exists(TARGET):
    print(f"{TARGET} exists; leaving it alone", file=sys.stderr)
    sys.exit(1)

with open(os.path.join(HERE, "caps-lock-tmux-prefix.json")) as f:
    rule = json.load(f)["rules"][0]

os.makedirs(os.path.dirname(TARGET), exist_ok=True)
with open(TARGET, "w") as f:
    json.dump(
        {
            "profiles": [
                {
                    "name": "Default profile",
                    "selected": True,
                    "complex_modifications": {"rules": [rule]},
                }
            ]
        },
        f,
        indent=4,
    )
    f.write("\n")

print(f"wrote {TARGET}")
