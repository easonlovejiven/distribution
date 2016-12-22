class Api::V1::Fx::WithdrawsController < Api::V1::ApplicationController
  before_action :authenticate_user!
  before_action :verified_user_hfbpay

  def index
    @withdraws = @current_user.account.bang_withdraws.page(params[:page]).per(params[:per_page])
    render json: {withdraws: @withdraws.as_json, meta: meta_attributes(@withdraws)}
  end

  def tax_rate_check
    price = params[:price]
    return unless verified_tax_rate_price(price)
    tax_rate=Fx::User.rate_rule(price.to_f)
    available_amount=@hfbpay.bang_amount-tax_rate
    render :json => { :bang_amount => @hfbpay.bang_amount,price: price,available_amount: available_amount,:tax_rate=>tax_rate}, status: 200
  end

  def create
    price = params[:price]
    return unless verified_bang_price(price)
    @withdraw = @current_user.account.bang_withdraws.new(number: @current_user.withdraw_coding, bank_name: params[:bank_name],
                                                         price:  params[:price], user_name: params[:user_name], bank_account: params[:bank_account])
    if @withdraw.save!
      @success=database_transaction do
        @hfbpay.bang_withdraw_pay(@withdraw)
      end
      # #税金（to实时获益提现）
      # tax_rate=Fx::User.rate_rule(price.to_f)
      # #可提现金额
      # available_amount=@hfbpay.bang_amount-tax_rate
      render :json => {:state => @withdraw.state, :bang_amount => @hfbpay.bang_amount}, status: 200
    else
      head status: 500
    end
  end

  def destroy
    @withdraw = @current_user.account.withdraws.find(params[:id])
    if @withdraw && @withdraw.state == Withdraw::STATE[:default]
      @withdraw.destroy
      head status: 200
    else
      head status: 500
    end
  end

  def bang_amount
    if @hfbpay
      render :json => {:bang_amount => @hfbpay.bang_amount}, status: 200
    else
      head status: 500
    end
  end


  private
  def withdraw_params
    params.require(:withdraw).permit(:price)
  end

  def verified_bang_price(price)
    if price.blank?
      api_error(status: 422, errors: '请输入提现金额')
      return false
    end
    if @hfbpay.bang_amount < price.to_i
      api_error(status: 422, errors: '余额不足')
      return false
    end
    if price.to_i < 100
      api_error(status: 422, errors: '每次提现金额必须满100元')
      return false
    end
    unless params[:account_password].present?
      api_error(status: 422, errors: '密码不能为空')
      return false
    end
    # user = Core::User.pay_authenticate(@current_user.account, Core::User.encrypt_password(params[:account_password]))
    # unless user
    #   api_error(status: 422, errors: '支付密码错误')
    #   return false
    # end
    return true
  end

  def verified_tax_rate_price(price)
    if price.blank?
      api_error(status: 422, errors: '请输入提现金额')
      return false
    end
    if @hfbpay.bang_amount < price.to_i
      api_error(status: 422, errors: '余额不足')
      return false
    end
    if price.to_i < 100
      api_error(status: 422, errors: '每次提现金额必须满100元')
      return false
    end
    return true
  end
end
