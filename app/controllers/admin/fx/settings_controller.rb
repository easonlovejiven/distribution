class Admin::Fx::SettingsController < Admin::Fx::ApplicationController
  before_action :current_tab

  def index
    @setting = ::Fx::Setting.where(key: "apply").first_or_create do |s|
      s.value={limit: 10000,remin: 10000}
    end
    @train_fee_setting = ::Fx::Setting.where(key: "train_fee").first_or_create do |s|
      s.value=1
    end
    @audit_setting = ::Fx::Setting.where(key: "audit_type").first_or_create do |s|
      s.value=1
    end
    @audit_cost_setting = ::Fx::Setting.where(key: "audit_cost_amount").first_or_create do |s|
      s.value=100
    end
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @levels }
    end
  end

  def update
    params[:setting].each do |key, value|
      setting =Fx::Setting.where(key: key).first
      setting.update_attributes(:value => value)
    end
    respond_to do |format|
      flash[:notice] = '等级更新成功'
      format.html { redirect_to :back }
      format.js { head :ok }
      format.xml { head :ok }
    end
  end

  def ui
    @setting = ::Fx::Setting.where(key: "poster").first_or_create do |s|
      s.value=[]
    end
    @posters =@setting.value
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @levels }
    end
  end

  protected

  def current_tab
    @current_tab="setting"
  end

  def setting_params
    params[:setting].permit([apply: [:limit, :remain, :tax_rate]], poster: [:pic, :url])
  end

  def authorized?
    true
  end
end
