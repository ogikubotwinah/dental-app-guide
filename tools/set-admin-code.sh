#!/bin/bash
# 管理者用ページ（admin.html）の合言葉を設定する（2026-09-04）
#   使い方: bash tools/set-admin-code.sh '好きな合言葉'
#
# ★合言葉は admin.html に そのままは書きません（ハッシュだけ書きます）。
#   ただし公開ページに置く以上、これは「のれん」であって鍵ではありません。
#   本当の鍵はアプリを開いたときのパスコードです。給与のパスコードをここに使い回さないでください。
set -euo pipefail
cd "$(dirname "$0")/.."
CODE="${1:-}"
if [ -z "$CODE" ]; then
  echo "使い方: bash tools/set-admin-code.sh '好きな合言葉'"
  echo "  ※ 給与のパスコードは使わないでください（別のことばにしてください）"
  exit 1
fi
HASH=$(printf '%s' "$CODE" | shasum -a 256 | cut -d' ' -f1)
python3 - "$HASH" <<'PY'
import re, sys
h = sys.argv[1]
p = 'admin.html'
s = open(p, encoding='utf-8').read()
s2 = re.sub(r"const CODE_HASH = '[^']*';", "const CODE_HASH = '%s';" % h, s, count=1)
if s == s2:
    print('admin.html の CODE_HASH が見つかりません'); sys.exit(1)
open(p, 'w', encoding='utf-8').write(s2)
print('admin.html に合言葉を設定しました（ハッシュのみ）')
PY
echo "→ 反映するには: git add admin.html && git commit -m 'admin: 合言葉を設定' && git push"
