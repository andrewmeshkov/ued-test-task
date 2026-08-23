import json
import subprocess
from pathlib import Path

print("=== processes ===")
try:
    out = subprocess.check_output(
        ["wsl", "-e", "bash", "-lc", "ps aux | grep -E 'maze_|run_full' | grep -v grep || true"],
        text=True,
        errors="replace",
    )
    print(out.strip() or "(none)")
except Exception as e:
    print(e)

print()
for metrics in sorted(Path("logs").rglob("metrics.jsonl")):
    if "smoke" in str(metrics):
        continue
    rows = [json.loads(l) for l in metrics.read_text(encoding="utf-8").splitlines() if l.strip()]
    if not rows:
        continue
    r = rows[-1]
    best = max(rows, key=lambda x: x["solve_rate/mean"])
    run = f"{metrics.parent.parent.name}/{metrics.parent.name}"
    print(f"=== {run} ===")
    print(
        f"updates {r['num_updates']}/30000  "
        f"mean={r['solve_rate/mean']:.3f}  "
        f"best_mean={best['solve_rate/mean']:.3f}@{best['num_updates']}"
    )
    for k in [
        "SixteenRooms",
        "SixteenRooms2",
        "Labyrinth",
        "LabyrinthFlipped",
        "Labyrinth2",
        "StandardMaze",
        "StandardMaze2",
        "StandardMaze3",
    ]:
        print(f"  {k}: {r[f'solve_rate/{k}']:.2f}")
    print()
