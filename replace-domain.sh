#!/bin/sh
# replace-domain.sh —— 一次性把占位符换成你的正式域名和邮箱
#
# 用法:
#   sh replace-domain.sh acgn.example.com hi@example.com
#
# 只接受裸域名（不带 https:// 和结尾斜杠），脚本自己补。
set -e
cd "$(dirname "$0")"

DOMAIN="$1"
EMAIL="$2"

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
  echo "用法: sh replace-domain.sh 你的域名.com 你的邮箱@example.com" >&2
  exit 1
fi

case "$DOMAIN" in
  http://*|https://*|*/) echo "✗ 域名不要带协议和斜杠，只要 acgn.example.com 这种" >&2; exit 1 ;;
  *.*) ;;
  *) echo "✗ 这不像一个域名: $DOMAIN" >&2; exit 1 ;;
esac

case "$EMAIL" in
  *@*.*) ;;
  *) echo "✗ 这不像一个邮箱: $EMAIL" >&2; exit 1 ;;
esac

for f in index.html en/index.html robots.txt sitemap.xml; do
  [ -f "$f" ] || { echo "✗ 找不到 $f（请在解压后的目录里运行）" >&2; exit 1; }
done

# macOS 和 GNU sed 的 -i 参数不同，这里用临时文件避开差异
for f in index.html en/index.html robots.txt sitemap.xml; do
  sed -e "s|YOUR-DOMAIN\.com|$DOMAIN|g" -e "s|YOUR-EMAIL@example\.com|$EMAIL|g" "$f" > "$f.tmp"
  mv "$f.tmp" "$f"
done

echo "✓ 已替换为 https://$DOMAIN  /  $EMAIL"
echo
echo "--- 校验 ---"
if grep -rn "YOUR-" index.html en/index.html robots.txt sitemap.xml; then
  echo "✗ 上面这些还没替换干净"
  exit 1
fi
echo "✓ 没有残留占位符"
grep -h "canonical\|og:url" index.html en/index.html | sed 's/^[[:space:]]*/  /'
grep -h "<loc>" sitemap.xml | sed 's/^[[:space:]]*/  /'
echo
echo "下一步: 把整个文件夹拖到 Cloudflare Pages（或你的主机）即可。"
