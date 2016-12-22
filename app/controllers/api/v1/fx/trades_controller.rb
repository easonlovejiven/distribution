class Api::V1::Fx::TradesController < Api::V1::ApplicationController

  before_action :authenticate_user!
  before_action :active_user_hfbpay,:only=>[:create]

  def index
    @trades = @current_user.trades.page params[:page]
  end

  def create
    trade = Fx::Trade.find_by_number(params[:trade][:number])
    if trade.present?
      return api_error(status: 422,errors: "分销订单已创建")
    end
    @trade = Fx::Trade.new trade_params
    #    if @trade.user.state!=1
    #      return api_error(status: 422,errors: "分销商未审核")
    #    end
    if @trade.save
      render json: { success: '创建成功'}
    else
      head status: 500
    end
  end


  def show
    @trade = @current_user.trades.find(params[:id])
    # 提示当前订单的状态
    callback_params = params.except(*request.path_parameters.keys)
    if callback_params.any? && Alipay::Sign.verify?(callback_params)
      flash[:notice] = '支付完成'
    end
  end

  private
  def trade_params
    params.require(:trade).permit(["number","name", "total_amount", "amount", "optype", "user_id"] )
  end
  
  def active_user_hfbpay
    unless @current_user.account.try(:hfbpay)
      hfbpay = @current_user.account.build_hfbpay(current_amount: 0)
      hfbpay.save!
    end
  end


end
