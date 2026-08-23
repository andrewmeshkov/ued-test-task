#!/usr/bin/env bash
# Run new teacher variants (seed 0) sequentially on WSL GPU.
set -euo pipefail
ROOT="/mnt/c/Users/Андрон/Projects/ued-frontier-teacher"
cd "$ROOT"
source .venv-wsl/bin/activate
export XLA_PYTHON_CLIENT_PREALLOCATE=false
SEED="${1:-0}"
LOG="logs/methods_queue_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1

run() {
  local mode="$1"
  local run_name="$2"
  shift 2
  echo "======== $mode seed=$SEED ========"
  python examples/maze_teacher.py --teacher_mode "$mode" --run_name "$run_name" --seed "$SEED" \
    --checkpoint_save_interval 17 "$@"
}

run sfl_pure "sfl_pure"
run sfl_accel_long "sfl_accel_long"
run mna_accel "mna_accel"
run learnability_filtered "lf_filtered"
run learnability_ema "lf_ema"
echo "ALL NEW METHOD RUNS COMPLETE"
