class Admin::Fx::TaxRatesController < Admin::Fx::ApplicationController
  before_action :current_tab

  def index
    account=params[:where].delete(:account) if !params[:where].blank?
    @tax_rates = Fx::TaxRate._where(params[:where])._order(params[:order])
    if !account.blank?
      ids =Core::User.where("account like ?","%#{account}%").pluck(:id)
      @tax_rates=@tax_rates.joins(:user).where(fx_users: {id: ids})
    end
    @tax_rates =@tax_rates.page(params[:page]).per(params[:per_page])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @tax_rates }
    end
  end

  protected

  def current_tab
    @current_tab="tax_rate"
  end

  def authorized?
    true
  end
end
