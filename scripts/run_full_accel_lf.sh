#!/usr/bin/env bash
# Sequential full runs: ACCEL then LF-ACCEL for seeds 0,1,2.
set -euo pipefail
ROOT="/mnt/c/Users/Андрон/Projects/ued-frontier-teacher"
cd "$ROOT"
source .venv-wsl/bin/activate
export XLA_PYTHON_CLIENT_PREALLOCATE=false
mkdir -p logs/full_runs
LOG="logs/full_runs/queue_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1
echo "Logging to $LOG"
python -c "import jax; print(jax.__version__, jax.devices())"

SEEDS=(0 1 2)
for SEED in "${SEEDS[@]}"; do
  echo "======== ACCEL seed=$SEED ========"
  python examples/maze_plr_baseline.py \
    --seed "$SEED" --run_name accel --use_accel \
    --checkpoint_save_interval 17

  echo "======== LF-ACCEL seed=$SEED ========"
  python examples/maze_frontier.py \
    --seed "$SEED" --run_name lf_accel \
    --checkpoint_save_interval 17
done
echo "ALL RUNS COMPLETE"
