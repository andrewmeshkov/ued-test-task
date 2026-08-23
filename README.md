# UED Frontier Teacher (LF-ACCEL)

Teacher для open-ended Minigrid UED на [JaxUED](https://github.com/DramaCow/jaxued). Цель: побить **PLR⊥** и **ACCEL** на held-out лабиринтах при том же бюджете student'а (30k PPO updates).

## Метод: LF-ACCEL

| Компонент | Выбор | Источник |
|-----------|--------|----------|
| Score | Bernoulli learnability \(p(1-p)\), Laplace \(\alpha=1\) | Rutherford et al. 2024 (SFL) |
| Статистика буфера | Накопительные `ep_count` / `suc_count` по replay | эта работа |
| Replay | Robust PLR⊥ (без exploratory grads на DR) | Jiang et al. 2021 |
| Мутации | ACCEL edits (`num_edits=5`) после replay | Parker-Holder et al. 2022 |
| Student | PPO + LSTM, дефолты JaxUED — **не меняем** | Coward et al. 2024 |

Логирование **локальное** (`logs/.../metrics.jsonl`), без wandb.

## Установка

```powershell
cd C:\Users\Андрон\Projects\ued-frontier-teacher
py -3.11 -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
pip install --no-deps -e vendor/jaxued
```

**GPU на Windows:** у `jax[cuda12]==0.4.30` нет Win CUDA wheels. Для полных прогонов на 30k updates используйте **WSL2** (ниже) или Colab/Kaggle. Нативный `.venv` здесь — CPU, удобен для smoke-тестов.

### WSL2 GPU (рекомендуется для полных прогонов)

```bash
wsl
cd /mnt/c/Users/Андрон/Projects/ued-frontier-teacher
python3.11 -m venv .venv-wsl && source .venv-wsl/bin/activate
pip install "jax[cuda12]==0.4.30" flax==0.8.5 chex==0.1.86 optax==0.2.3 \
  distrax==0.1.5 gymnax==0.0.8 orbax-checkpoint==0.5.3 "numpy<2" pillow imageio
pip install --no-deps -e vendor/jaxued
```

## Smoke-тест (CPU)

```powershell
.\.venv\Scripts\python.exe examples\maze_frontier.py `
  --seed 0 --num_updates 250 --eval_freq 250 --eval_num_attempts 2 `
  --checkpoint_save_interval 0 --run_name smoke
```

Первая JIT-компиляция на CPU может занять несколько минут.

## Варианты teacher (`examples/maze_teacher.py`)

Единая точка входа для экспериментов с curriculum. Выбор через `--teacher_mode`:

| Режим | Score / collect | Заметки |
|-------|-----------------|--------|
| `lf_accel` | \(p(1-p)\) + накопительный буфер + ACCEL | по умолчанию (как `maze_frontier.py`) |
| `sfl_pure` | collect ~2k карт → top-K по \(p(1-p)\) → train | Rutherford SFL, без PLR-буфера |
| `sfl_accel_long` | LF-ACCEL, но score с длинных rollouts (`--score_rollout_steps 512`) | разделяет горизонты train и score |
| `mna_accel` | MNA (DEGen): сумма отрицательных advantages × solved gate | мутации ACCEL |
| `learnability_filtered` | \(p(1-p)\) только если уровень решён ≥ 1 раза | отсекает нерешаемый шум |
| `learnability_ema` | EMA от \(p\) → \(p(1-p)\) | сглаженнее сырых счётчиков |
| `accel_maxmc` | MaxMC (score бейзлайна ACCEL) | для сравнения |
| `plr_pvl` | positive value loss (score бейзлайна PLR) | для сравнения |

```bash
# WSL GPU — полный бюджет, seed 0
source .venv-wsl/bin/activate
python examples/maze_teacher.py --teacher_mode sfl_pure --seed 0 --run_name sfl_pure --checkpoint_save_interval 17
# все новые методы по очереди:
bash scripts/run_new_methods.sh 0
```

Smoke всех режимов: `bash scripts/smoke_teacher_modes.sh`

## Полный бюджет (бейзлайны + метод)

**Не** переопределяйте PPO-флаги student'а. Используйте `--checkpoint_save_interval 17`.

```powershell
# PLR⊥
.\.venv\Scripts\python.exe examples\maze_plr_baseline.py --seed 0 --run_name plr --checkpoint_save_interval 17

# ACCEL
.\.venv\Scripts\python.exe examples\maze_plr_baseline.py --seed 0 --run_name accel --use_accel --checkpoint_save_interval 17

# DR
.\.venv\Scripts\python.exe examples\maze_dr_baseline.py --seed 0 --run_name dr --checkpoint_save_interval 17

# LF-ACCEL (наш метод)
.\.venv\Scripts\python.exe examples\maze_frontier.py --seed 0 --run_name lf_accel --checkpoint_save_interval 17
```

Повторите для сидов `0,1,2`. Или в WSL: `bash scripts/run_full_seed.sh 0`.

## Артефакты

| Путь | Содержимое |
|------|------------|
| `logs/<run_name>/<seed>/metrics.jsonl` | solve rates, статистика sampler'а |
| `checkpoints/<run_name>/<seed>/` | orbax-чекпоинты для eval на секретном наборе |
| `report/REPORT.md` / `report/REPORT.pdf` | отчёт по экспериментам |

## Структура

```
examples/
  maze_frontier.py      # teacher LF-ACCEL (legacy entry)
  maze_teacher.py       # единые режимы teacher (SFL, MNA, filtered, EMA, …)
  teacher_scores.py     # score-функции
  maze_plr_baseline.py  # PLR⊥ / ACCEL (локальный лог)
  maze_dr_baseline.py   # DR (локальный лог)
  local_log.py
scripts/
  run_new_methods.sh    # очередь: sfl_pure, sfl_accel_long, mna_accel, lf_filtered, lf_ema
  smoke_teacher_modes.sh
vendor/jaxued/          # upstream JaxUED (editable install)
report/REPORT.md
```
