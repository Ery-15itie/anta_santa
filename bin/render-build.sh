#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Ruby Gemsのインストール
bundle install

# 2. Yarnロックファイルをリセット（MacとLinuxの差異を吸収するため）
rm -f yarn.lock

# 3. JavaScriptパッケージのインストール
# esbuildをdependenciesに入れたので、普通のインストール
yarn install

# 4. アセットのプリコンパイル
bundle exec rake assets:precompile

# 5. 古いアセットの削除
bundle exec rake assets:clean

# 6. データベースのマイグレーション
# (リセットはせず、変更分のみ適用してデータを守る！！！！)
bundle exec rake db:migrate