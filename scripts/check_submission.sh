#!/usr/bin/env bash
set -euo pipefail
ROOT="/mnt/c/Users/Андрон/Projects/ued-frontier-teacher"
cd "$ROOT"
echo "=== checkpoints tree ==="
find checkpoints -maxdepth 3 -type d 2>/dev/null | sort
echo
for d in accel lf_accel plr dr sfl_pure sfl_accel_long mna_accel lf_filtered lf_ema; do
  echo "== $d =="
  if [ ! -d "checkpoints/$d" ]; then
    echo "  (нет каталога)"
    continue
  fi
  for s in 0 1 2; do
    p="checkpoints/$d/$s"
    if [ -d "$p" ]; then
      size=$(du -sh "$p" 2>/dev/null | cut -f1)
      steps=$(ls "$p/models" 2>/dev/null | grep -E '^[0-9]+$' | sort -n | tail -3 | tr '\n' ' ')
      echo "  seed $s: $size  last_steps: $steps"
    else
      echo "  seed $s: нет"
    fi
  done
done
echo
echo "=== logs (completed baselines) ==="
for d in plr dr accel lf_accel; do
  for s in 0 1 2; do
    f="logs/$d/$s/metrics.jsonl"
    if [ -f "$f" ]; then
      python3 -c "import json; r=json.loads(open('$f').read().strip().split(chr(10))[-1]); print(f'$d/$s: updates={r[\"num_updates\"]} mean={r[\"solve_rate/mean\"]:.3f}')"
    else
      echo "$d/$s: нет лога"
    fi
  done
done
