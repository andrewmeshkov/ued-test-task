#!/usr/bin/env bash
# Quick status for the full-run queue.
ROOT="/mnt/c/Users/Андрон/Projects/ued-frontier-teacher"
cd "$ROOT"
echo "=== processes ==="
ps aux | grep -E 'maze_|run_full' | grep -v grep || echo "(none)"
echo
echo "=== latest queue log (tail) ==="
ls -t logs/full_runs/queue_*.log 2>/dev/null | head -1 | xargs -r tail -30
echo
echo "=== checkpoints so far ==="
find checkpoints -maxdepth 3 -type d 2>/dev/null | head -40
echo
echo "=== last metrics lines ==="
find logs -name metrics.jsonl 2>/dev/null | while read f; do
  echo "-- $f"
  tail -1 "$f"
done
