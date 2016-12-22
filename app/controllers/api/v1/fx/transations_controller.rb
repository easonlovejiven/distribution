class Api::V1::Fx::TransationsController < Api::V1::ApplicationController

  before_action :authenticate_user!,only: [:index]

  def index
    @user=Fx::User.find(params[:user_id])
    case params[:user_type].to_i
      when 1
        dealer_level=nil
        total_amount="amount"
      when 2
        dealer_level=1
        total_amount="amount1"
      when 3
        dealer_level=2
        total_amount="amount2"
      when 4
        dealer_level=[3,4,5,6,7,8]
        total_amount="amount3"
    end
    @transations = Fx::Transation.where(dealer_level: dealer_level,user_id: @user.id).page params[:page]
    data= @transations.as_json(Fx::Transation.json_options)
    data.map{|item| item.merge!(trade_amount: '%.2f'%item['trade_amount'],amount: '%.2f'%item['amount'], ) }
    total_amount= '%.2f' %@user.info.send(total_amount)
    render json: {total_amount: total_amount ,transations: data,meta: meta_attributes(@transations)}
  end

end
