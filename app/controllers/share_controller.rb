class ShareController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show], raise: false

  def show
    @ogp_image = OgpImage.find_by!(uuid: params[:id])
    
    # 画像が添付されているか確認
    unless @ogp_image.image.attached?
      render plain: 'Image Not Found', status: :not_found
      return
    end
    
    # レイアウトなしで表示
    render layout: false
    
  rescue ActiveRecord::RecordNotFound
    render plain: 'Not Found', status: :not_found
  end
end
