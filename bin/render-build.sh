#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Ruby Gemsのインストール
bundle install

# 2. Yarnロックファイルをリセット（MacとLinuxの差異を吸収するため）
rm -f yarn.lock

# 3. JavaScriptパッケージのインストール
# production=false を付けて、esbuild等の開発ツールも強制的に入れる
yarn install --production=false

# 4. アセットのプリコンパイル
bundle exec rake assets:precompile

# 5. 古いアセットの削除
bundle exec rake assets:clean

# 6. データベースのマイグレーション(resetなし!!!!!)
bundle exec rake db:migrate