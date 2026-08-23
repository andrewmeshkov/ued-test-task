#!/usr/bin/env bash
set -euo pipefail
SEED="${1:-0}"
python examples/maze_plr_baseline.py --seed "$SEED" --run_name "plr" --checkpoint_save_interval 17
python examples/maze_plr_baseline.py --seed "$SEED" --run_name "accel" --use_accel --checkpoint_save_interval 17
python examples/maze_frontier.py --seed "$SEED" --run_name "lf_accel" --checkpoint_save_interval 17
