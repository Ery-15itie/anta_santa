# app/controllers/homes_controller.rb
class HomesController < ApplicationController
  # これがあることで、ログインしていない人は自動的にログイン画面へ弾かれる
  before_action :authenticate_user!

  def index
    # Reactを表示するだけなので、ここには何も書かなくてOK
  end
end