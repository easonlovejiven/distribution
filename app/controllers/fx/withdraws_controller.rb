class Fx::WithdrawsController < ApplicationController
  before_action :login_filter 
  before_action :fx_login_user_filter
  before_action :verified_hfbpay,:only=>[:new,:create]
  def index
    @bang_withdraws = Core::BangWithdraw.recent.where(user_id: @user.id) 
  end
 
  def new
    @withdraw = Core::BangWithdraw.new
  end
  
  def create
    price = params[:price]
    return unless verified_bang_price(price)
    @withdraw = current_user.bang_withdraws.new(number: current_user.withdraw_coding, bank_name: params[:bank_name],
      price:  params[:price], user_name: params[:user_name], bank_account: params[:bank_account])
    @success=database_transaction do
      @withdraw.save!
      @hfbpay.bang_withdraw_pay(@withdraw)
    end  
    if @success
      render :js => "hzb.redirect_to('/fx/withdraws','提现成功',2000);"
       
    else
      render :js => "hzb.show_error_note('提现失败')"
    end
   
  end
 
  private
   
  def fx_login_user_filter
    @user =  Fx::User.where(:id=>current_user.id).first if current_user
  end
 
  def verified_hfbpay
    unless current_user.verified?
      return redirect_to verify_fx_home_index_path
    end
    @hfbpay = current_user.hfbpay
    unless @hfbpay
      return render :js => "hzb.show_error_note('请激活用户!')"
    end
  end
 
  def verified_bang_price(price)
    unless current_user.verified?
      render :js => "hzb.show_error_note('请实名认证')"
      return false
    end
    
    if params[:bank_account].blank?
      render :js => "hzb.show_error_note('账号不能为空')"
      return false
    end 
    if params[:user_name].blank?
      render :js => "hzb.show_error_note('开户名不能为空')"
      return false
    end
    if params[:bank_name].blank?
      render :js => "hzb.show_error_note('开户行不能为空')"
      return false
    end
    if @hfbpay.bang_amount < price.to_i
      render :js => "hzb.show_error_note('余额不足')"
      return false
    end
    if price.to_i < 100
      render :js => "hzb.show_error_note('每次提现金额必须满100元')"
      return false
    end
    if params[:account_password].blank?
      render :js => "hzb.show_error_note('密码不能为空')"
      return false
    end

    user = Core::User.pay_authenticate(current_user.account, Core::User.encrypt_password(params[:account_password]))
    unless user
      render :js => "hzb.show_error_note('支付密码错误')"
      return false
    end
    return true
  end
  
end
