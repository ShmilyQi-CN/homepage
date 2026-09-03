#!/bin/bash
# 同步个人主页到 GitHub Pages:重新静态导出(剥手稿PDF/电话)→ 提交 → 推送 main+gh-pages
set -e
python3 - <<'EOF'
import json, os, re, shutil
SITE = '/home/zq/paperread-site'
html = open('/home/zq/paperread/backend/app/homepage.html').read()
html = html.replace('/hpstatic/', 'hpstatic/').replace('/hp/cover/', 'covers/')
html = html.replace('fetch("/hp/site")', 'fetch("site.json")')
html = re.sub(r'<span>☎ <b>[0-9]+</b></span>', '', html)
open(SITE + '/index.html', 'w').write(html)
d = json.load(open('/home/zq/paperread/data/homepage/site.json'))
if 'profile' in d: d['profile'].pop('phone', None)
for p in d.get('publications', []): p.pop('pdf', None)
json.dump(d, open(SITE + '/site.json', 'w'), ensure_ascii=False)
dst = SITE + '/covers'
if os.path.exists(dst): shutil.rmtree(dst)
shutil.copytree('/home/zq/paperread/data/homepage/covers', dst)
print('导出完成')
EOF
cd /home/zq/paperread-site
git add -A
git diff --cached --quiet && { echo "无变化,不用推"; exit 0; }
git commit -qm "同步主页内容 $(date +%F)

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
git push -q origin main && git push -qf origin main:gh-pages
echo "✓ 已推送,1-2 分钟后 https://shmilyqi-cn.github.io/homepage/ 生效"
