#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Ruby Gemsのインストール
bundle install

# ▼▼▼ 修正ポイント：yarn.lock を削除して、その場で最適なものを入れ直させる ▼▼▼
rm -f yarn.lock
yarn install

# 3. アセットのプリコンパイル
bundle exec rake assets:precompile

# 4. 古いアセットの削除
bundle exec rake assets:clean

# 5. データベースのマイグレーション
#絶対reset,seedしないで！！！！！！！！！！！！！
bundle exec rake db:migrate