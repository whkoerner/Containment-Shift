#!/usr/bin/env python3
"""Static-only repository validation. Never implies Unity compilation or runtime PASS."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "UnityProject"
ASSETS = PROJECT / "Assets"
ERRORS = []


def check(condition, message):
    if not condition:
        ERRORS.append(message)


def main():
    for relative in ["README.md", "AGENTS.md", "docs/PROJECT_EXECUTION_PLAN.md",
                     "docs/CURRENT_TASKS.md", "docs/NEXT_SESSION.md",
                     "docs/TEST_RESULTS.md", "docs/NOT_RUN.md",
                     "UnityProject/Packages/manifest.json",
                     "UnityProject/ProjectSettings/ProjectVersion.txt"]:
        check((ROOT / relative).is_file(), "Missing required file: " + relative)

    asmdefs = list(ASSETS.rglob("*.asmdef"))
    names = set()
    refs = {}
    for path in [PROJECT / "Packages/manifest.json", *asmdefs]:
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            if path.suffix == ".asmdef":
                name = data["name"]
                check(name not in names, "Duplicate asmdef: " + name)
                names.add(name)
                refs[name] = data.get("references", [])
            else:
                check(isinstance(data.get("dependencies"), dict),
                      "Manifest missing dependencies")
        except (OSError, ValueError, KeyError) as exc:
            ERRORS.append(f"Invalid JSON or schema: {path.relative_to(ROOT)}: {exc}")

    for name, dependencies in refs.items():
        for dependency in dependencies:
            check(dependency in names or dependency.startswith("GUID:") or
                  dependency in {"Unity.InputSystem"},
                  f"Unknown local assembly reference in {name}: {dependency}")

    for asset in ASSETS.rglob("*"):
        if asset.is_file() and not asset.name.endswith(".meta"):
            check(asset.with_name(asset.name + ".meta").is_file(),
                  "Missing .meta: " + str(asset.relative_to(ROOT)))

    for required in ["P01-M01-T01", "P01-M03-T03", "P04-M01-T04", "P08-M01-T05"]:
        plan = ROOT / "docs/PROJECT_EXECUTION_PLAN.md"
        if plan.exists():
            check(required in plan.read_text(encoding="utf-8"), "Missing task: " + required)

    if ERRORS:
        for error in ERRORS:
            print("FAIL:", error)
        return 1
    print(f"PASS static-only: manifest, {len(asmdefs)} asmdefs, asset metadata, roadmap IDs")
    print("NOT RUN: Unity import, C# compile, EditMode, PlayMode, standalone, multiplayer")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
