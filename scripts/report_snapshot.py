import json
from pathlib import Path

levels = [
    "SixteenRooms",
    "SixteenRooms2",
    "Labyrinth",
    "LabyrinthFlipped",
    "Labyrinth2",
    "StandardMaze",
    "StandardMaze2",
    "StandardMaze3",
]

def load(path):
    return [json.loads(l) for l in Path(path).read_text(encoding="utf-8").splitlines() if l.strip()]

for name, path in [
    ("ACCEL/0", "logs/accel/0/metrics.jsonl"),
    ("LF-ACCEL/0", "logs/lf_accel/0/metrics.jsonl"),
    ("ACCEL/1", "logs/accel/1/metrics.jsonl"),
]:
    rows = load(path)
    last = rows[-1]
    best = max(rows, key=lambda r: r["solve_rate/mean"])
    print(f"\n## {name} last@{last['num_updates']} mean={last['solve_rate/mean']:.3f} best={best['solve_rate/mean']:.3f}@{best['num_updates']}")
    for lv in levels:
        print(f"  {lv}: last={last[f'solve_rate/{lv}']:.2f} best_row_at_peak={best[f'solve_rate/{lv}']:.2f}")
    # milestones
    for u in [5000, 10000, 15000, 20000, 25000, 30000]:
        matches = [r for r in rows if r["num_updates"] == u]
        if matches:
            print(f"  @{u}: mean={matches[0]['solve_rate/mean']:.3f}")
