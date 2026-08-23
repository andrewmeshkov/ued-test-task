@echo off
set SEED=%1
if "%SEED%"=="" set SEED=0
.\.venv\Scripts\python.exe examples\maze_frontier.py --seed %SEED% --num_updates 250 --eval_freq 250 --eval_num_attempts 2 --checkpoint_save_interval 0 --run_name smoke
