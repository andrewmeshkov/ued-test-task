#!/usr/bin/env bash
set -euo pipefail
ROOT="/mnt/c/Users/Андрон/Projects/ued-frontier-teacher"
cd "$ROOT"
source .venv-wsl/bin/activate
export XLA_PYTHON_CLIENT_PREALLOCATE=false

MODES=(
  lf_accel
  sfl_pure
  sfl_accel_long
  mna_accel
  learnability_filtered
  learnability_ema
  accel_maxmc
  plr_pvl
)

COMMON=(
  --seed 0
  --num_updates 2
  --eval_freq 1
  --sfl_collect_num_batches 1
  --sfl_collect_batch 8
  --sfl_top_k 4
  --sfl_train_from_pool 4
  --score_rollout_steps 32
  --level_buffer_capacity 32
  --num_train_envs 8
  --num_steps 32
)

for mode in "${MODES[@]}"; do
  echo "=== SMOKE $mode ==="
  python examples/maze_teacher.py \
    --teacher_mode "$mode" \
    --run_name "smoke_${mode}" \
    "${COMMON[@]}"
done

echo "ALL_SMOKE_OK"
