class Api::V1::Fx::TaxRatesController < Api::V1::ApplicationController

  before_action :authenticate_user!

  def index
    @tax_rates = @current_user.tax_rates.order("date desc").page params[:page]
    data=@tax_rates.as_json(Fx::TaxRate.json_options)
    data.map{|item| item.merge!(total_amount: '%.2f'%item['total_amount'] ,amount: '%.2f'%item['amount'])}
    render json: {tax_amount: @current_user.tax_amount, tax_rates: data, meta: meta_attributes(@tax_rates)}
  end

end
