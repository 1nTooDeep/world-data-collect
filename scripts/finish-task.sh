#!/usr/bin/env bash
# 完成任务: 记账本+改状态 (flock 保护)
# 用法: finish-task.sh <worker名> <任务号> <SUCCESS|FAIL> <行数> <来源URL> <备注>
set -u
WORKER="${1:-unknown}"; TNO="${2:-0}"; STATUS="${3:-SUCCESS}"; LINES="${4:-0}"; SRC="${5:-}"; NOTE="${6:-}"
BASE="/mnt/data/world-data"
TASKS="$BASE/tasks.md"
LOCK="$BASE/.queue.lock"
exec 9>"$LOCK"
flock -w 10 9 || { echo "FAIL|锁等待超时"; exit 1; }

TOPIC=$(grep -E "^\| $TNO \|" "$TASKS" | awk -F'|' '{print $4}' | sed 's/^ *//;s/ *$//')
DATASET=$(grep -E "^\| $TNO \|" "$TASKS" | awk -F'|' '{print $6}' | sed 's/^ *//;s/ *$//')

# 写账本(带 worker 名)
echo "| $(date '+%F %T') | $TOPIC | $DATASET | $NOTE | $LINES | $SRC | $STATUS | worker=$WORKER |" >> "$BASE/collection-log.md"

# 任务状态: SUCCESS→DONE, FAIL→PENDING(可重试,备注失败原因)
NEW_STATE=$([ "$STATUS" = "SUCCESS" ] && echo "DONE" || echo "PENDING")
sed -i "s/| CLAIMED($WORKER) |/| $NEW_STATE |/" "$TASKS"
echo "OK|$TNO|$NEW_STATE"
