#!/usr/bin/env python3
"""Generate a case-insensitive clang/lld VFS overlay mapping virtual dirs to real MSVC/SDK dirs."""
import json
import os
import sys

out = sys.argv[1]
pairs = sys.argv[2:]  # virtual=real ...


def build(real):
    entries = []
    for name in sorted(os.listdir(real)):
        p = os.path.join(real, name)
        if os.path.isdir(p):
            entries.append({"name": name, "type": "directory", "contents": build(p)})
        else:
            entries.append({"name": name, "type": "file", "external-contents": p})
    return entries


roots = []
for pair in pairs:
    virt, real = pair.split("=", 1)
    roots.append({"name": virt, "type": "directory", "contents": build(real)})

with open(out, "w") as f:
    json.dump({"version": 0, "case-sensitive": "false", "roots": roots}, f)
