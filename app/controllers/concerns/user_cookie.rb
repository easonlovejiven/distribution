module UserCookie
  def user_cookies
    if @current_user
      set_cookie(:user_id, @current_user.id)
      # set_cookie(:user_pic, @current_user.pic)
      user = Fx::User.try(:acquire, @current_user.id) if defined? Fx::User
    else
      set_cookie(:user_id, nil)
      set_cookie(:user_name, nil)
      set_cookie(:user_pic, nil)
      set_cookie(:site, nil)
      set_cookie(:orders_count, (orders_count = (JSON.parse(session[:cart_data]||'[]') rescue []).size) && orders_count > 0 ? orders_count : nil)
    end
  end

  def set_cookie(key, value, options={})
    if value == nil
      cookies.delete(key, :domain => ".#{Rails.application.secrets.domain}") if cookies[key]
    else
      if cookies[key] != URI.encode(value.to_s)
        cookies[key] = {
            :value => URI.encode(value.to_s),
            :expires => options[:expires] || 1.years.from_now,
            :domain => ".#{Rails.application.secrets.domain}",
            :path => '/'
        }
      end
    end
  end
end
