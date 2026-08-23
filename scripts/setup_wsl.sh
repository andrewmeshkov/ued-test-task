#!/usr/bin/env bash
set -euo pipefail
cd "/mnt/c/Users/Андрон/Projects/ued-frontier-teacher"
python3 -m venv .venv-wsl
source .venv-wsl/bin/activate
pip install -U pip
pip install 'jax[cuda12]==0.4.30' flax==0.8.5 chex==0.1.86 optax==0.2.3 \
  distrax==0.1.5 gymnax==0.0.8 orbax-checkpoint==0.5.3 'numpy<2' pillow imageio
pip install --no-deps -e vendor/jaxued
python -c "import jax; print('jax', jax.__version__, jax.devices())"
