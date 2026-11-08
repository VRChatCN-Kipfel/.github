#!/usr/bin/env bash
# CN-Kipfel 代码签名证书安装（非 Windows 平台）
#
# Windows 的证书存储只有 Windows 才有。这个脚本在 MSYS/MinGW/Cygwin 下等价于
# setup.bat；在纯 POSIX 系统上只输出说明，不改动任何东西。

set -euo pipefail
cd "$(dirname "$0")"

ROOT_CERT="XChen446_Root_CA.crt"
CA_CERT="CN-Kipfel_Organization_Common_CA_2026.pem"
README="README.md"

for f in "$ROOT_CERT" "$CA_CERT" "$README"; do
    if [[ ! -f "$f" ]]; then
        echo "[错误] 找不到 $f"
        echo "请把 setup.sh、README.md 与证书文件放在同一目录。"
        exit 1
    fi
done

# 直接读取 README 原文件展示，不内嵌正文。
cat "$README"

# 同意提示由脚本负责，README 只讲事实与风险，不写这句。
echo
echo "============================================================"
echo "  按【回车】= 同意并继续安装"
echo "  Ctrl+C 或关窗口 = 取消，不做任何改动"
echo "============================================================"
echo
printf '  > '
read -r _ || true
echo

case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
        echo "[1/2] 安装根证书 → 受信任的根证书颁发机构 ..."
        certutil -addstore -user Root "$ROOT_CERT" >/dev/null
        echo "      完成。"
        echo "[2/2] 安装中间证书 → 中间证书颁发机构 ..."
        certutil -addstore -user CA "$CA_CERT" >/dev/null
        echo "      完成。"
        echo
        echo "现在运行安装包即可，签名会正常显示。"
        ;;
    *)
        if command -v wine >/dev/null 2>&1; then
            echo "检测到 Wine，写入 Wine prefix（不影响宿主系统）..."
            wine certutil -addstore -user Root "$(winepath -w "$PWD/$ROOT_CERT")" >/dev/null
            wine certutil -addstore -user CA "$(winepath -w "$PWD/$CA_CERT")" >/dev/null
            echo "      完成。"
        else
            cat <<'MSG'

当前系统不是 Windows，也没有 Wine —— 本脚本没有做任何改动。

Windows 之外没有 Windows 证书存储可写，这两份证书只用于验证本组织发布的
Windows 安装包。如果要在 macOS / Linux 上核验：

    # 查看证书信息
    openssl x509 -in CN-Kipfel_Organization_Common_CA_2026.pem -noout -subject -issuer -dates

    # 校验 Authenticode 签名（需要 osslsigncode）
    osslsigncode verify -in <安装包>.exe -CAfile XChen446_Root_CA.crt

MSG
        fi
        ;;
esac
