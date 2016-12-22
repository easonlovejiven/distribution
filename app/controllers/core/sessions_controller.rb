# encoding: utf-8
class Core::SessionsController < ApplicationController
  skip_before_action :login_filter
 layout 'register'

  def new

  end

  def create
    user = Core::User.authenticate(params[:account], Core::User.encrypt_password(params[:password]))
    if user.present?
      session[:user_id] = user.id
      #session[:store_login] = session[:user_account]
      #session[:sid] = env['rack.request.cookie_hash']['_hzb_session']

      return_url = session[:return_to] || '/'

      render :js => "hzb.redirect('#{return_url}','登录成功',2000);"
    else
      render :js => "hzb.show_error_note('账号或者密码不对')"
    end
  end

  def captcha_login
    validate_resutl = validate_captcha(params[:account])
    if validate_resutl.blank?
      user = User.find_by_account(params[:account])
      if user
        session[:user_account] = user.account
        render :js => "hzb.redirect('/','登录成功'); "
      else
        render :js => "hzb.show_error_note('账号或者密码不对')"
      end
    else
      render :js => "hzb.show_error_note('#{validate_resutl}');"
    end
  end

  def logout
    #session[:store_logout] = session[:user_account]
    # session[:user_id] = nil
    # session.clear
    # flash[:notice] = '退出成功'
    logout_killing_session!
    respond_to do |format|
      format.html { redirect_to params[:redirect] || root_path }
      format.js { head :ok }
    end
  end

  def forget_password
  end

  def validate_account
    account = params[:account]
    captcha = params[:captcha]
    yzm = params[:yzm]
    if captcha.blank? or captcha.upcase != yzm.try(:upcase)
      return render :js => "hzb.show_error_note('验证码不正确');"
    end
    user = User.find_by_account(account)
    if user.blank?
      return render :js => "hzb.show_error_note('用户不存在');"
    end

    session[:temp_user] = user.id
    session[:user_account] = nil
    return render :js => "hzb.redirect('#{get_sms_sessions_path}');"
  end

  def get_sms
    @user = User.where(:id => session[:temp_user]).first
    if @user.blank?
      return redirect_to forget_password_sessions_path
    end
  end

  def validate_code
    @user = User.where(:id => session[:temp_user]).first
    if @user.blank?
      return redirect_to forget_password_sessions_path
    end
    sms = Sm.find_mobile(@user.account)
    unless sms and sms.captcha == params[:mcaptcha] and sms.expires?
      return render :js => "hzb.show_error_note('验证码不正确');"
    end
    session[:already_validate_code] = sms.captcha
    return render :js => "hzb.redirect('#{show_reset_password_sessions_path}');"
  end

  def del_store
    session[:store_login] = nil
    session[:store_logout] = nil
    head status: 200
  end

  private

  def validate_captcha(account)
    sms = Sm.find_mobile(account)
    if sms.blank?
      return '手机验证码不正确'
    end
    unless sms.captcha == params[:mcaptcha]
      return '手机验证码不正确'
    end
    unless sms.expires?
      return '手机验证码已过期'
    end
    sms.update(:state => 1)
    return nil
  end

end
