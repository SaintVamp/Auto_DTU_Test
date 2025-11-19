git pull
cp /auto_dtu/model_config/model-config.toml /auto_dtu/config/.
cp /auto_dtu/model_config/readme_dtu.txt /auto_dtu/config/.
python3 run.py &
sleep 30s
while true; do
  if [ -f /auto_dtu/upgrade ]; then
    git pull
    cp /auto_dtu/model_config/model-config.toml /auto_dtu/config/.
    cp /auto_dtu/model_config/readme_dtu.txt /auto_dtu/config/.
    ps | grep "python3 run.py" | grep -v grep | awk '{print $1}' | xargs kill -9
    python3 run.py &
    rm /auto_dtu/upgrade
  fi
  sleep 5m
done