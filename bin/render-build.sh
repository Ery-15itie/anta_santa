#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Ruby Gems (ライブラリ) のインストール
bundle install

# 2. React用パッケージのインストール
# (これを忘れると本番でReactが動かない)
yarn install

# 3. アセットのコンパイル (JavaScript/CSSの生成)
# ここで esbuild が走り、Reactコードがブラウザで動く形に変換される
bundle exec rake assets:precompile

# 4. 古いアセットのお掃除
bundle exec rake assets:clean

# 5. データベースの更新 (マイグレーション)
# ⚠️重要: ここで db:reset や db:seed は絶対に使うなよ！
# db:migrate は「既存データを残したまま、テーブル構造だけを変更」
bundle exec rake db:migrate