"""Gather final metrics for the report."""
import json
from pathlib import Path

LEVELS = [
    "SixteenRooms",
    "SixteenRooms2",
    "Labyrinth",
    "LabyrinthFlipped",
    "Labyrinth2",
    "StandardMaze",
    "StandardMaze2",
    "StandardMaze3",
]


def load(run: str, seed: int):
    p = Path(f"logs/{run}/{seed}/metrics.jsonl")
    if not p.exists():
        return None
    return [json.loads(l) for l in p.read_text(encoding="utf-8").splitlines() if l.strip()]


def main():
    for run in ["accel", "lf_accel", "sfl_pure", "sfl_accel_long", "mna_accel", "lf_filtered", "lf_ema", "plr"]:
        for seed in [0, 1, 2]:
            rows = load(run, seed)
            if not rows:
                continue
            r = rows[-1]
            best = max(rows, key=lambda x: x["solve_rate/mean"])
            print(f"{run}/{seed}: final={r['solve_rate/mean']:.3f} best={best['solve_rate/mean']:.3f}@{best['num_updates']} n={r['num_updates']}")
            if r["num_updates"] >= 30000:
                per = " ".join(f"{lv[:4]}={r[f'solve_rate/{lv}']:.2f}" for lv in LEVELS)
                print(f"  {per}")


if __name__ == "__main__":
    main()
