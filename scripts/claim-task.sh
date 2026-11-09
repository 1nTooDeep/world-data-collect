#!/usr/bin/env bash
# 多机任务认领接口: agent 认领任务时调用本脚本(带 flock 文件锁), 输出认领结果或 FAIL
# 用法: claim-task.sh <worker名> [数据目录]
# 输出: CLAIMED|<任务号>|<主题>|<产物路径> 或 EMPTY 或 FAIL|<原因>
set -u
WORKER="${1:-unknown-worker}"
BASE="${2:-/mnt/data/world-data}"
TASKS="$BASE/tasks.md"
LEDGER="$BASE/collection-log.md"
LOCK="$BASE/.queue.lock"

exec 9>"$LOCK"
flock -w 10 9 || { echo "FAIL|锁等待超时"; exit 1; }

# 找第一个 PENDING
TASK_LINE=$(grep -nE '^\| [0-9]+ \| PENDING' "$TASKS" | head -1)
if [ -z "$TASK_LINE" ]; then
    echo "EMPTY"
    exit 0
fi
LINE_NO="${TASK_LINE%%:*}"
TASK_NO=$(echo "$TASK_LINE" | awk -F'|' '{print $2}' | tr -d ' ')

# 标记为 CLAIMED(worker名) —— PENDING→CLAIMED 需唯一认领
sed -i "${LINE_NO}s/| PENDING |/| CLAIMED($WORKER) |/" "$TASKS"

TOPIC=$(echo "$TASK_LINE" | awk -F'|' '{print $4}' | trim 2>/dev/null || echo "$TASK_LINE" | awk -F'|' '{print $4}' | sed 's/^ *//;s/ *$//')
OUTPUT=$(echo "$TASK_LINE" | awk -F'|' '{print $6}' | sed 's/^ *//;s/ *$//')

# 记认领时间戳
echo "$(date '+%F %T') | CLAIM | $WORKER | 任务#$TASK_NO | $TOPIC" >> "$BASE/claim-log.md"
echo "CLAIMED|$TASK_NO|$TOPIC|$OUTPUT"
