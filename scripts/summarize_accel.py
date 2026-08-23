import json
from pathlib import Path

p = Path("logs/accel/0/metrics.jsonl")
rows = [json.loads(l) for l in p.read_text(encoding="utf-8").splitlines() if l.strip()]
print(f"points={len(rows)} first_u={rows[0]['num_updates']} last_u={rows[-1]['num_updates']}")
keys = [
    "num_updates",
    "solve_rate/mean",
    "solve_rate/SixteenRooms",
    "solve_rate/SixteenRooms2",
    "solve_rate/Labyrinth",
    "solve_rate/LabyrinthFlipped",
    "solve_rate/Labyrinth2",
    "solve_rate/StandardMaze",
    "solve_rate/StandardMaze2",
    "solve_rate/StandardMaze3",
]
# print milestones
want = {250, 1000, 2500, 5000, 7500, 10000, 15000, 20000, 25000, 30000}
for r in rows:
    u = r["num_updates"]
    if u in want or r is rows[-1]:
        vals = {k: (round(float(r[k]), 3) if k != "num_updates" else int(r[k])) for k in keys}
        print(vals)
