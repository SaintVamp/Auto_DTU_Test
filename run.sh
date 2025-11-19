#!/bin/sh

# 函数：测试Git仓库延迟并选择最佳的
select_best_remote() {
    # 使用字符串而不是数组
    REMOTE1="github.com"
    REMOTE2="gitee.com"

    # 简化的延迟测试
    if ping -c 1 -W 3 "$REMOTE1" >/dev/null 2>&1; then
        echo "origin"  # 假设 origin 对应 github
    elif ping -c 1 -W 3 "$REMOTE2" >/dev/null 2>&1; then
        echo "gitee"  # 假设 mirror 对应 gitee
    else
        echo "origin"  # 默认回退
    fi
}

# 在你的脚本中使用
git_pull_best() {
    best_remote=$(select_best_remote)
    echo "Using remote: $best_remote"

    # 执行 git pull
    git pull "$best_remote" main  # 根据实际情况调整分支名
}
git_pull_best
cp /auto_dtu/model_config/model-config.toml /auto_dtu/config/.
cp /auto_dtu/model_config/readme_dtu.txt /auto_dtu/config/.
python3 run.py &
sleep 30
while true; do
  if [ -f /auto_dtu/upgrade ]; then
    git_pull_best
    cp /auto_dtu/model_config/model-config.toml /auto_dtu/config/.
    cp /auto_dtu/model_config/readme_dtu.txt /auto_dtu/config/.
    ps | grep "python3 run.py" | grep -v grep | awk '{print $1}' | xargs kill -9
    python3 run.py &
    rm /auto_dtu/upgrade
  fi
  sleep 300
done
