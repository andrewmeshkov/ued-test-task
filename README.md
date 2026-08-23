# UED Frontier Teacher (LF-ACCEL)

Teacher for open-ended Minigrid UED on [JaxUED](https://github.com/DramaCow/jaxued). Goal: beat **PLR⊥** and **ACCEL** on held-out mazes at the same student budget (30k PPO updates).

## Method: LF-ACCEL

| Piece | Choice | Source |
|-------|--------|--------|
| Score | Bernoulli learnability \(p(1-p)\), Laplace \(\alpha=1\) | Rutherford et al. 2024 (SFL) |
| Buffer stats | Cumulative `ep_count` / `suc_count` across replays | this work |
| Replay | Robust PLR⊥ (no exploratory grads on DR) | Jiang et al. 2021 |
| Mutations | ACCEL edits (`num_edits=5`) after replay | Parker-Holder et al. 2022 |
| Student | PPO + LSTM, JaxUED defaults — **not changed** | Coward et al. 2024 |

Logging is **local** (`logs/.../metrics.jsonl`), no wandb.

## Setup

```powershell
cd C:\Users\Андрон\Projects\ued-frontier-teacher
py -3.11 -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
pip install --no-deps -e vendor/jaxued
```

**GPU on Windows:** `jax[cuda12]==0.4.30` has no Win CUDA wheels. For full 30k-update runs use **WSL2** (see below) or Colab/Kaggle. Native `.venv` here is CPU — fine for smoke tests.

### WSL2 GPU (recommended for full runs)

```bash
wsl
cd /mnt/c/Users/Андрон/Projects/ued-frontier-teacher
python3.11 -m venv .venv-wsl && source .venv-wsl/bin/activate
pip install "jax[cuda12]==0.4.30" flax==0.8.5 chex==0.1.86 optax==0.2.3 \
  distrax==0.1.5 gymnax==0.0.8 orbax-checkpoint==0.5.3 "numpy<2" pillow imageio
pip install --no-deps -e vendor/jaxued
```

## Smoke test (CPU)

```powershell
.\.venv\Scripts\python.exe examples\maze_frontier.py `
  --seed 0 --num_updates 250 --eval_freq 250 --eval_num_attempts 2 `
  --checkpoint_save_interval 0 --run_name smoke
```

First JIT compile can take several minutes on CPU.

## Teacher variants (`examples/maze_teacher.py`)

Unified entry point for curriculum experiments. Select with `--teacher_mode`:

| Mode | Score / collect | Notes |
|------|-----------------|-------|
| `lf_accel` | \(p(1-p)\) + cumulative buffer + ACCEL | default (same as `maze_frontier.py`) |
| `sfl_pure` | collect ~2k maps → top-K by \(p(1-p)\) → train | Rutherford SFL, no PLR buffer |
| `sfl_accel_long` | LF-ACCEL but score from long rollouts (`--score_rollout_steps 512`) | separates train vs score horizon |
| `mna_accel` | MNA (DEGen): sum of negative advantages × solved gate | ACCEL mutations |
| `learnability_filtered` | \(p(1-p)\) only if level solved ≥ once | drops unsolvable noise |
| `learnability_ema` | EMA of \(p\) → \(p(1-p)\) | smoother than raw counters |
| `accel_maxmc` | MaxMC (ACCEL baseline score) | for comparison |
| `plr_pvl` | positive value loss (PLR baseline score) | for comparison |

```bash
# WSL GPU — full budget, seed 0
source .venv-wsl/bin/activate
python examples/maze_teacher.py --teacher_mode sfl_pure --seed 0 --run_name sfl_pure --checkpoint_save_interval 17
# all new methods sequentially:
bash scripts/run_new_methods.sh 0
```

Smoke all modes: `bash scripts/smoke_teacher_modes.sh`


Do **not** override student PPO flags. Use `--checkpoint_save_interval 17`.

```powershell
# PLR⊥
.\.venv\Scripts\python.exe examples\maze_plr_baseline.py --seed 0 --run_name plr --checkpoint_save_interval 17

# ACCEL
.\.venv\Scripts\python.exe examples\maze_plr_baseline.py --seed 0 --run_name accel --use_accel --checkpoint_save_interval 17

# DR
.\.venv\Scripts\python.exe examples\maze_dr_baseline.py --seed 0 --run_name dr --checkpoint_save_interval 17

# LF-ACCEL (ours)
.\.venv\Scripts\python.exe examples\maze_frontier.py --seed 0 --run_name lf_accel --checkpoint_save_interval 17
```

Repeat for seeds `0,1,2`. Or: `bash scripts/run_full_seed.sh 0` under WSL.

## Outputs

| Path | Contents |
|------|----------|
| `logs/<run_name>/<seed>/metrics.jsonl` | solve rates, sampler stats |
| `checkpoints/<run_name>/<seed>/` | orbax checkpoints for secret-set eval |
| `report/REPORT.md` | experimental write-up |

## Layout

```
examples/
  maze_frontier.py      # LF-ACCEL teacher (legacy entry)
  maze_teacher.py       # unified teacher modes (SFL, MNA, filtered, EMA, …)
  teacher_scores.py     # score functions
  maze_plr_baseline.py  # PLR⊥ / ACCEL (local log)
  maze_dr_baseline.py   # DR (local log)
  local_log.py
scripts/
  run_new_methods.sh    # queue: sfl_pure, sfl_accel_long, mna_accel, lf_filtered, lf_ema
  smoke_teacher_modes.sh
vendor/jaxued/          # upstream JaxUED (editable install)
report/REPORT.md
```
