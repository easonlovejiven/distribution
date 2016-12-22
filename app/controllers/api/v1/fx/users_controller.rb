class Api::V1::Fx::UsersController < Api::V1::ApplicationController
  
  def new

  end

  def apply
    authenticate
    @current_account.active_hfbpay if @current_account
    if @current_user.present?
      return api_error(status: 422, errors: "你已经是#{@current_user.level.name}")
    end
    #    if Fx::Setting.first.apply[:remain].to_i==0
    #      return api_error(status: 422, errors: "#{Fx::Setting.first.apply[:limit]}名终身事业合伙人已招募满员")
    #    end
    @fx_user = Fx::User.create!(id: @current_account.id, state: 1)
    render json: @user.as_json(Fx::User.json_options)
  end

  def show
    @user=Fx::User.find(params[:id])
    data= @user.as_json(Fx::User.json_options)
    data.merge!(total_amount: '%.2f'%data['total_amount'].to_f,balance: '%.2f'%data['balance'].to_f ,tax_amount: '%.2f'%data['tax_amount'].to_f,bang_balance: '%.2f'%data['bang_balance'].to_f)
    info=data['info']
    data['info'].merge!(amount: '%.2f'%info['amount'].to_f,amount1: '%.2f'%info['amount1'].to_f ,amount2: '%.2f'%info['amount2'].to_f,current_month_amount: '%.2f'%info['current_month_amount'].to_f)
    render json: data
  end

  def create
    return unless validate_create_params
    return unless validate_captcha(params[:user][:account])
    password =Core::User.encrypt_password(params[:user][:password])
    @user = Core::User.new user_params.merge(:account => params[:user][:account], :password => password)
    @user.nickname=@user.account if params[:user][:nickname].blank?
    if @user.save!
      @success=database_transaction do
        @user.active_hfbpay
        @fx_user = Fx::User.create!(id: @user.id, state: 1)
        Fx::User.add_invitation_users(@fx_user, params[:invitation]) if params[:invitation].present?
      end
    else
      @user.delete
    end

    if @success
      render json: {token: @user.auth_token}
    else
      return invalid_resource!(@user.errors) if @user.errors.present?
      head status: 500
    end
  end

  def qrcode
    @user=Fx::User.find(params[:id])
    render json: {invitation_url: @user.invitation_url,invitaion_qrcode: @user.invitation_qrcode,invitation: @user.invitation }
  end

  def check
    @user=Fx::User.find(params[:id])
    render json: {is_fx: @user.present?}
  end

  def invalid
    user = Fx::User.where(id: params[:user_id]).first
    if user
      api_error(status: 631, errors: '分销账号已存在!')
      return false
    end
    @success=database_transaction do
      @fx_user = Fx::User.create!(id: params[:user_id])
      Fx::User.add_invitation_users(@fx_user, params[:invitation]) if params[:invitation].present?
    end  
    if @success
      head status: 200
    else
      return invalid_resource!(@fx_user.errors) if @fx_user.errors.present?
      head status: 500
    end
    
  end
  
  def note
    @user=Fx::User.find(params[:id])
    @relations =  @user.relations.recent.page params[:page]
    render json: {relations: @relations.as_json(Fx::Relation.json_options), meta: meta_attributes(@relations)}
  end
  
  private

  def validate_create_params
    if params[:user][:account].blank?
      api_error(status: 631, errors: '账户不能为空')
      return false
    end
    if @user=Core::User.find_by_account(params[:user][:account])
      api_error(status: 422, errors: "当前用户已存在")
      return false
    end
    return true
  end


  def user_params
    params.require(:user).permit(["account", "nickname", "optype"])
  end


end
