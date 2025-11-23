#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Ruby Gemsのインストール
bundle install

# 2. Yarnロックファイルの削除と再インストール
rm -f yarn.lock
# 開発用ツール(esbuild)を含めてインストールさせる
yarn install --production=false

# 3. アセットのプリコンパイル
# (package.jsonでパスを指定したので、Rake経由でもesbuildが見つかるはず)
bundle exec rake assets:precompile

# 4. 古いアセットの削除
bundle exec rake assets:clean

# 5. データベースのマイグレーション(resetしない！！！！！！！)
bundle exec rake db:migrate