#!/usr/bin/env python3
"""Small JSON store used by the Quickshell todo board and Fish command."""

import argparse
import json
import os
import tempfile
from datetime import datetime
from pathlib import Path


STORE = Path.home() / ".cache" / "quickshell-rice" / "todos.json"


def read_items():
    try:
        data = json.loads(STORE.read_text())
        return data if isinstance(data, list) else []
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return []


def write_items(items):
    STORE.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix="todos.", suffix=".json", dir=STORE.parent)
    try:
        with os.fdopen(fd, "w") as handle:
            json.dump(items, handle, indent=2)
            handle.write("\n")
        os.replace(name, STORE)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def normalize_items(items):
    """Keep only active notes and assign each one a unique slot from 1 to 6."""
    active = [item for item in items if not item.get("checked", False)]
    normalized = []
    used = set()
    for item in active[:6]:
        old_id = item.get("id")
        try:
            old_id = int(old_id)
        except (TypeError, ValueError):
            old_id = 0
        slot = old_id if 1 <= old_id <= 6 and old_id not in used else next(
            slot for slot in range(1, 7) if slot not in used
        )
        used.add(slot)
        normalized.append({
            "id": slot,
            "text": str(item.get("text", "")),
            "reminderTime": str(item.get("reminderTime", "")),
            "checked": False,
            "lastNotifiedAt": str(item.get("lastNotifiedAt", "")),
        })
    return normalized


def next_slot(items):
    used = {int(item["id"]) for item in items if 1 <= int(item["id"]) <= 6}
    return next((slot for slot in range(1, 7) if slot not in used), None)


parser = argparse.ArgumentParser()
parser.add_argument("action", choices=("add", "read", "check", "notify"))
parser.add_argument("--text", default="")
parser.add_argument("--time", default="")
parser.add_argument("--id", type=int, default=0)
args = parser.parse_args()

raw_items = read_items()
items = normalize_items(raw_items)
if items != raw_items:
    write_items(items)
if args.action == "add":
    slot = next_slot(items)
    if slot is None:
        parser.error("all six todo slots are occupied; check one off first")
    item = {
        "id": slot,
        "text": args.text,
        "reminderTime": args.time,
        "checked": False,
        "lastNotifiedAt": "",
    }
    items.append(item)
    write_items(items)
    print(json.dumps(item))
elif args.action == "check":
    items = [item for item in items if int(item.get("id", 0)) != args.id]
    write_items(items)
    print(json.dumps(items))
elif args.action == "notify":
    stamp = datetime.now().astimezone().isoformat(timespec="seconds")
    changed = False
    for item in items:
        if int(item.get("id", 0)) == args.id and not item.get("checked", False):
            item["lastNotifiedAt"] = stamp
            changed = True
    if changed:
        write_items(items)
    print(json.dumps(items))
else:
    print(json.dumps(items))
