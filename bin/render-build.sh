#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Ruby Gemsのインストール
bundle install

# 2. Yarnロックファイルの削除と再インストール
rm -f yarn.lock
yarn install

#  esbuildを明示的に実行 (rake経由の失敗回避) 
yarn build

# 3. アセットのプリコンパイル
# (※すでに yarn build でJSは作られているので、ここではCSSなどの処理が中心)
bundle exec rake assets:precompile

# 4. 古いアセットの削除
bundle exec rake assets:clean

# 5. データベースのマイグレーション
# 絶対reset,seedしないで！！！！！！！！！！！！！
bundle exec rake db:migrate