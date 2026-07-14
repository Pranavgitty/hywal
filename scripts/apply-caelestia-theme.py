#!/usr/bin/env python3

"""Apply Caelestia's existing themes from HyWal's Matugen-generated scheme."""

import json
import os
from pathlib import Path


def main() -> None:
    state_home = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state"))
    scheme_path = state_home / "caelestia" / "scheme.json"

    try:
        scheme = json.loads(scheme_path.read_text())
        colours = scheme["colours"]
        mode = scheme["mode"]
    except (OSError, KeyError, TypeError, json.JSONDecodeError) as error:
        raise SystemExit(f"HyWal: cannot read Caelestia scheme: {error}") from error

    from caelestia.utils.theme import apply_colours

    apply_colours(colours, mode)


if __name__ == "__main__":
    main()
