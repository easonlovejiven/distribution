class Fx::UsersController < ApplicationController
  skip_before_action :login_filter
  layout 'register'

  def new
    session[:account]       = nil
    @user                   = Fx::User.new
    session[:fx_invitation] = params[:invitation]
  end

  def validate_params
    validate_resutl = validate_account_params
    if validate_resutl.present?
      render :js => "hzb.show_error_note('#{validate_resutl}')"
    else
      session[:account] = params[:user][:account]
      @status           = 'success'
      render :js => "hzb.redirect('#{register_fx_users_path}');"
    end
  end

  def register
    if session[:account].blank?
      return redirect_to signup_path
    end
    @fx_invitation = session[:fx_invitation] if session[:fx_invitation].present?
    @user          = Fx::User.new
  end

  def send_sms
    sms     = Core::Sm.find_mobile(params[:account])
    captcha = generate_code
    expires = Time.now + Core::Sm::EXPIRES_TIME
    sort    = params[:sort].to_i
    if sms
      sms.update(:captcha => captcha, :captchatime => expires, :state => 0, :sort => sort)
      sms.send_sms
    else
      sms = Core::Sm.create(:captcha => captcha, :mobile => params[:account], :captchatime => expires, :sort => sort)
      sms.send_sms
    end
    logger.debug "IN METHOD SMS captcha: #{captcha.to_s}"
    head status: 200
  end

  def create
    validate_resutl = validate_create_params
    @success=false
    if validate_resutl.present?
      return render :js => "hzb.show_error_note('#{validate_resutl}')"
    else
      password      = Core::User.encrypt_password(params[:user][:password])
      @user         = Core::User.new user_params.merge(:account => params[:user][:account], :password => password)
      @user.nickname=@user.account if params[:user][:nickname].blank?
      if @user.save!
        @success=database_transaction do
          @user.active_hfbpay
          @fx_user = Fx::User.create!(id: @user.id, state: 1)
          Fx::User.add_invitation_users(@fx_user, params[:invitation]) if params[:invitation].present?
        end
      end
    end
    if @success
      reset_session
      render :js =>  "hzb.redirect('/fx/download','注册成功,请下载App登陆.',2000);"
    else
      @user.try(:delete)
      render :js => "hzb.show_error_note('注册失败');"
    end
  end


  def apply
    unless current_user
      return render :js => "hzb.show_verify_error('请重新登录');"
    end
    current_user.active_hfbpay
    @user = Fx::User.where(:id => current_user.id).first
    if @user.present?
      return render :js => "hzb.redirect('/','你已经是#{@user.level.name}',2000);"
    end
    #if Fx::Setting.first.apply[:remain].to_i==0
    #   render :js => "hzb.show_error_note('#{Fx::Setting.first.apply[:limit]}名终身事业合伙人已招募满员')"
    # end
    @fx_user = Fx::User.create!(id: current_user.id, state: 1)
    if @fx_user
      return render :js => "hzb.redirect('/','恭喜您, 已经成为普通合伙人!',2000);"
    end
  end


  #验证码注册
  def validate_code
    validate_resutl = validate_captcha(params[:account])
    if validate_resutl.blank?
      user = User.find_by_account(params[:account])
      unless user
        user = User.create(:account => params[:account], :nickname => generate_nickname(params[:account]), :password => generate_token(params[:account]))
      end
      session[:user_account] = user.account
      render :json => {:recode => 0, :msg => '验证成功'}
    else
      render :json => {:recode => 500, :msg => validate_resutl}
    end
  end


  private
  def user_params
    params.require(:user).permit(:nickname, :email, :city_id, :province_id, :district_id)
  end

  def profile_params
    params.require(:profile).permit(:id_card, :name, :address, :id_card_front, :id_card_back, :sex, :phone)
  end

  def validate_account_params
    unless Core::User::PHONE_REGEX.match(params[:user][:account])
      return "手机格式不正确"
    end
    if params[:captcha].blank? or params[:yzm].try(:upcase) != params[:captcha].upcase
      return '验证码失败'
    end
    if params[:invitation].present?
      fx_user=Fx::User.find_by_invitation(params[:invitation])
      return "邀请码无效" if !fx_user.present?
    end
    if Core::User.find_by_account(params[:user][:account]).present?
      return '账户已经存在'
    end

    return nil
  end

  def validate_create_params
    if session[:account].blank?
      return '账户不能为空'
    end
    if params[:user][:nickname].blank?
      return '昵称不能为空'
    end
    if Core::User.find_by_account(params[:user][:account]).present?
      return '账户已经存在'
    end
    if Core::User.find_by_nickname(params[:user][:nickname]).present?
      return '昵称已经存在'
    end
    
    validate_phone = validate_captcha(params[:user][:account])
    if validate_phone.present?
      return validate_phone
    end
  end

  def validate_captcha(account)
    sms = Core::Sm.find_mobile(account)
    if sms.blank?
      return '手机验证码不存在'
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

  def validate_modify_password_params
    old_password     = params[:old_password]
    password         = params[:password]
    password_confirm = params[:password_confirmation]

    if old_password.blank? or !@current_user.valid_password(old_password)
      return "当前密码错误!"
    end
    if password.blank? or password != password_confirm
      return "确认密码和密码不一致!"
    end
    return ''
  end


  def generate_nickname(account)
    [*'a'..'z'].sample(4).join + account[-4..-1]
  end


end
