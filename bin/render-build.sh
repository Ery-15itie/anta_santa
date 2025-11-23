#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Ruby Gemsのインストール
bundle install

# 2. Yarnロックファイルの削除と再インストール
rm -f yarn.lock

# ▼▼▼ 修正--production=false を追加して、ビルドツールを確実にインストールさせる!! ▼▼▼
yarn install --production=false

# 3. ビルドコマンドの実行 (package.jsonの "build" を実行)
yarn build

# 4. アセットのプリコンパイル
bundle exec rake assets:precompile

# 5. 古いアセットの削除
bundle exec rake assets:clean

# 6. データベースのマイグレーション
#resetしない！！！！！！！！！！！！！
bundle exec rake db:migrate