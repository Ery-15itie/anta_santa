module Api
  module V1
    class OgpImagesController < ApplicationController
      def create
        # Base64データの受け取り
        image_data = params[:image]
        
        if image_data.present?
          # "data:image/png;base64," の部分を取り除く
          data = image_data.sub(/\Adata:image\/png;base64,/, "")
          decoded_data = Base64.decode64(data)
          
          ogp = OgpImage.new
          
          # 画像をアタッチ
          ogp.image.attach(
            io: StringIO.new(decoded_data),
            filename: "ogp_#{Time.current.to_i}.png",
            content_type: "image/png"
          )
          
          if ogp.save
            # シェア用ページのURLを返す (例: /share/abcdef12345)
            render json: { url: share_url(ogp.uuid) }
          else
            render json: { error: '保存に失敗しました' }, status: 422
          end
        else
          render json: { error: '画像データがありません' }, status: 400
        end
      end
    end
  end
end
