#!/usr/bin/env bash
# UnipusHelperPro 工程基线验证。
#
# 用法：
#   bash scripts/verify-baseline.sh              # 构建 + 静态自检（本地默认）
#   bash scripts/verify-baseline.sh --no-build   # 只跑静态自检（CI 里复用已构建产物）
#
# 输出每步 PASS/FAIL，退出码 0 = 全部通过，1 = 有失败项，2 = 用法或环境问题。
# 只做验证：不改业务代码，不写测试。

set -uo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT" || exit 2

SKIP_BUILD=0
for arg in "$@"; do
  case "$arg" in
    --no-build) SKIP_BUILD=1 ;;
    -h|--help) sed -n '2,10p' "${BASH_SOURCE[0]}"; exit 0 ;;
    *) echo "未知参数: $arg（可用：--no-build）"; exit 2 ;;
  esac
done

FAILED=0
fail() { echo "FAIL  $1"; FAILED=$((FAILED + 1)); }
pass() { echo "PASS  $1"; }
section() { printf '\n== %s ==\n' "$1"; }

# 1. 构建：mvn -B -DskipTests package
if [ "$SKIP_BUILD" -eq 0 ]; then
  section "1/3 构建 mvn -B -DskipTests package"
  mvn -B -DskipTests package
  rc=$?
  if [ "$rc" -eq 0 ]; then
    pass "mvn package 退出码 0"
  else
    fail "mvn package 退出码 $rc"
  fi
fi

section "2/3 产物"
JARS=$(ls target/unipusHelperPro-*.jar 2>/dev/null || true)
if [ -z "$JARS" ]; then
  fail "target/ 下没有 unipusHelperPro-*.jar"
else
  for j in $JARS; do
    pass "jar $j $(wc -c <"$j" | tr -d ' ') 字节"
  done
fi
if [ -d target/lib ]; then
  pass "target/lib $(ls target/lib | wc -l | tr -d ' ') 个文件，$(du -sb target/lib | cut -f1) 字节"
else
  fail "target/lib 不存在（maven-dependency-plugin copy-dependencies 未执行）"
fi

section "3/3 静态自检"

# 3a. 仓库里没有用户凭据：扫描入库的非源码文本文件（md/txt/json/yml/properties/env/log/har/csv）。
#     源码里的登录表单字段、协议签名常量不属于用户凭据，不在此检查范围（见 ImplementationStatus 的「发现的问题」）。
mapfile -t CRED_SCOPE < <(git ls-files | grep -Ei '\.(md|txt|json|ya?ml|properties|env|log|har|csv)$' || true)
if [ "${#CRED_SCOPE[@]}" -eq 0 ]; then
  pass "无入库文本文件需要扫描凭据模式"
else
  CRED_HITS=$(grep -nEi \
    '(pass(word|wd)?|pwd|token|secret|cookie|session_?id|authorization)["'"'"']?[[:space:]]*[:=][[:space:]]*["'"'"']?[A-Za-z0-9+/=_-]{16,}' \
    "${CRED_SCOPE[@]}" 2>/dev/null || true)
  if [ -z "$CRED_HITS" ]; then
    pass "入库文本文件中无账号/密码/Token 模式（扫描 ${#CRED_SCOPE[@]} 个文件）"
  else
    fail "发现疑似凭据："
    echo "$CRED_HITS"
  fi
fi

# 3b. 构建产物与日志不进仓库
TRACKED_TARGET=$(git ls-files | grep -Ei '(^|/)target/' || true)
if [ -z "$TRACKED_TARGET" ]; then
  pass "target/ 未入库"
else
  fail "target/ 下有入库文件："
  echo "$TRACKED_TARGET"
fi

TRACKED_LOGS=$(git ls-files | grep -Ei '(^|/)logs/|\.log$' || true)
if [ -z "$TRACKED_LOGS" ]; then
  pass "日志文件与日志目录未入库"
else
  fail "有入库的日志："
  echo "$TRACKED_LOGS"
fi

IGNORE_MISSING=""
for p in target/lib/x.jar logs/x.log x.log Documentation/Handoffs/x.md; do
  git check-ignore -q "$p" || IGNORE_MISSING="$IGNORE_MISSING $p"
done
if [ -z "$IGNORE_MISSING" ]; then
  pass ".gitignore 覆盖 target/、*.log、logs、Documentation/Handoffs/"
else
  fail ".gitignore 未覆盖：$IGNORE_MISSING"
fi

section "结果"
if [ "$FAILED" -eq 0 ]; then
  echo "全部通过"
  exit 0
fi
echo "失败 $FAILED 项"
exit 1
