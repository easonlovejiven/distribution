class Api::V1::Fx::HomeController < Api::V1::ApplicationController


  def posters
    @posters=Fx::Setting.find_by(key: "poster").value
    @posters.each { |item|
      item[:pic]=get_img_url(item[:pic])
    }
    render json: @posters
  end

  def info
    @apply=Fx::Setting.find_by(key: "apply").value
    render :json => {apply: @apply}
  end

  private
  def get_img_url(key)
    Rails.application.secrets[:qiniu_fx_url] + key
  end
end
