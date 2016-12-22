class Api::V1::ApplicationController < ApplicationController
  include Pundit
  include ActiveHashRelation

  # return api_error(status: 401)


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  before_action :destroy_session

  skip_before_action :verify_authenticity_token

  rescue_from ActiveRecord::RecordNotFound, with: :not_found!
  rescue_from Pundit::NotAuthorizedError, with: :unauthorized!

  attr_accessor :current_user

  def destroy_session
    request.session_options[:skip] = true
  end

  def unauthenticated!
    response.headers['WWW-Authenticate'] = "Token realm=Application"
    render json: {error: '用户未验证', status: 401}, status: 401
  end

  def unauthorized!
    render json: {error: '未授权', status: 403}, status: 403
  end

  def invalid_resource!(errors = [])
    api_error(status: 422, errors: errors)
  end

  def not_found!
    return api_error(status: 404, errors: 'Not found')
  end

  def api_error(status: 500, errors: [])
    unless Rails.env.production?
      puts errors.full_messages if errors.respond_to? :full_messages
    end
    head status: status and return if errors.empty?
    render json: jsonapi_format(status, errors).to_json, status: status
  end

  def paginate(resource)
    resource = resource.page(params[:page] || 1)
    if params[:per_page]
      resource = resource.per_page(params[:per_page])
    end
    return resource
  end


  #expects pagination!
  def meta_attributes(object)
    {
        current_page: object.current_page,
        next_page: object.next_page,
        prev_page: object.prev_page,
        total_pages: object.total_pages,
        total_count: object.total_count
    }
  end

  def authenticate_user!
    authenticate
    # if  ActiveSupport::SecurityUtils.secure_compare(user.auth_token, token)
    return unauthenticated! unless @current_user
  end


  def authenticate
    token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
    user=Core::User.where(auth_token: token).first
    fx_user=Fx::User.where(id: user.id).first if user
    if fx_user
      @current_user = fx_user
    else
      @current_account = user
    end
  end


  private


  def validate_captcha(account)
    if account.blank?
      api_error(status: 422, errors: '手机号不能为空')
      return false
    end
    sms = Core::Sm.find_mobile(account)
    if sms.blank?
      api_error(status: 606, errors: '手机验证码不正确')
      return false
    end
    unless sms.captcha == params[:mcaptcha]
      api_error(status: 606, errors: '手机验证码不正确')
      return false
    end
    unless sms.expires?
      api_error(status: 607, errors: '手机验证码已过期')
      return false
    end
    sms.update(:state => 1)
    return true
  end

  #ember specific :/
  def jsonapi_format(status, errors)
    return {status: status, error: errors} if errors.is_a? String
    errors_hash = ""
    errors.messages.each do |attribute, error|
      error.each do |e|
        errors_hash = {status: status, error: e}
      end
      errors_hash
    end

    return errors_hash
  end


  def verified_user_hfbpay
    unless @current_user.account.verified?
      return render json: {error: '请先实名认证', status: 403}, status: 403
    end

    @hfbpay = @current_user.account.hfbpay
    unless @hfbpay
      return render json: {error: '用户未验证', status: 403}, status: 403
    end
  end

  def validate_hfbpay_modify_password_params
    old_password = params[:old_password]
    if old_password.blank? or !@current_user.valid_hfbpay_password(old_password)
      api_error(status: 610, errors: "旧密码错误")
      false
    else
      true
    end
  end

  def validate_modify_password_params
    old_password = params[:old_password]
    if old_password.blank? or !@current_user.valid_password(old_password)
      api_error(status: 610, errors: "旧密码错误")
      false
    else
      true
    end
  end
end