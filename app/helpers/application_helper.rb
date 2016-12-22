module ApplicationHelper
  def stylesheet_inline_tag(*sources)
    content_tag :style, raw(sources.to_a.map { |source| Rails.application.assets.find_asset(source).to_s }.join), type: "text/css", scoped: ""
  end

  def javascript_inline_tag(*sources)
    content_tag :script, raw(sources.to_a.map { |source| Rails.application.assets.find_asset(source).to_s }.join), type: "text/javascript", scoped: ""
  end


  def uptoken
    bucket = Rails.application.secrets[:qiniu_fx]
    Qiniu::Auth.generate_uptoken(put_policy(bucket))
  end

  def put_policy(bucket)
    Qiniu::Auth::PutPolicy.new(bucket)
  end

  def format_price(price)
    ActionController::Base.helpers.number_to_currency(price,:unit =>'¥')
  end
  
  def get_img_url(key)
    Rails.application.secrets[:qiniu_fx_url] + key
  end
  
  #用户头像
  def avatar_tag(src,option={})
    if src.present?
      image_tag(thumb_small_image_url(src), option)
    else
      image_tag('avatar_logo.png', option)
    end
  end
  
  def thumb_small_image_url(filename)
    return   filename + "?imageView2/1/w/100/h/100" if filename.present?
    return ''
  end
  
end
