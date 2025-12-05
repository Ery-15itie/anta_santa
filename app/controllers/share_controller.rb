class ShareController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show], raise: false

  def show
    @ogp_image = OgpImage.find_by!(uuid: params[:id])
    
    # ActiveStorageの画像URLを取得（絶対URLで）
    if @ogp_image.image.attached?
      @image_url = rails_blob_url(@ogp_image.image, only_path: false)
    else
      render plain: 'Image Not Found', status: :not_found
      return
    end
    
    @title = "私の価値観 - サンタの書斎"
    @description = "私の大切な価値観の星々を見つけました✨"
    @share_url = request.original_url
    
    # レイアウトなしで表示
    render layout: false
    
  rescue ActiveRecord::RecordNotFound
    render plain: 'Not Found', status: :not_found
  end
end
