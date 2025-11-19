#!/bin/bash

# 函数：测试Git仓库延迟并选择最佳的
select_best_git_remote() {
    # 假设你有两个remote: origin 和 mirror
    remotes=("origin" "gitee")  # 替换为你的实际remote名称

    best_remote=""
    min_time=999999

    for remote in "${remotes[@]}"; do
        url=$(git remote get-url "$remote" 2>/dev/null)
        if [ ! -z "$url" ]; then
            # 提取主机名
            host=$(echo "$url" | sed 's/.*@//' | sed 's/[:/].*//' | cut -d'.' -f1,2)
            if [[ $host == *"."* ]]; then
                avg_time=$(ping -c 2 "$host" 2>/dev/null | tail -1 | awk '{print $4}' | cut -d'/' -f 2)
                if [ ! -z "$avg_time" ]; then
                    echo "$remote ($host): ${avg_time}ms"
                    # 将时间转换为整数比较
                    time_int=$(echo "$avg_time" | cut -d'.' -f1)
                    if [ "$time_int" -lt "$min_time" ] 2>/dev/null; then
                        min_time=$time_int
                        best_remote="$remote"
                    fi
                fi
            fi
        fi
    done

    echo "$best_remote"
}

# 在你的脚本中使用
git_pull_best() {
    best_remote=$(select_best_git_remote)
    if [ ! -z "$best_remote" ]; then
        echo "Using fastest remote: $best_remote"
        git pull "$best_remote" main  # 替换main为你的主分支名
    else
        echo "Falling back to default git pull"
        git pull
    fi
}
git_pull_best
cp /auto_dtu/model_config/model-config.toml /auto_dtu/config/.
cp /auto_dtu/model_config/readme_dtu.txt /auto_dtu/config/.
python3 run.py &
sleep 30s
while true; do
  if [ -f /auto_dtu/upgrade ]; then
    git_pull_best
    cp /auto_dtu/model_config/model-config.toml /auto_dtu/config/.
    cp /auto_dtu/model_config/readme_dtu.txt /auto_dtu/config/.
    ps | grep "python3 run.py" | grep -v grep | awk '{print $1}' | xargs kill -9
    python3 run.py &
    rm /auto_dtu/upgrade
  fi
  sleep 5m
done
