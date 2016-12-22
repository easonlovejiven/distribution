class Admin::Fx::TradesController < Admin::Fx::ApplicationController
  before_action :current_tab
  def index
    @trades = ::Fx::Trade.active._where(params[:where])._order(params[:order]).page(params[:page]).per(params[:per_page])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @trades }
    end
  end

  def show
    @trade = ::Fx::Trade.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @trade }
    end
  end

  def new
    @trade = ::Fx::Trade.new

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @trade }
    end
  end

  def create
    @trade = ::Fx::Trade.new(trade_params)
    respond_to do |format|
      if @trade.save
        flash[:notice] = '等级创建成功'
        format.html { redirect_to :back}
        format.xml { render :xml => @trade, :status => :created, :location => @trade }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @trade.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @trade = ::Fx::Trade.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @trade }
    end
  end

  def update
    @trade = ::Fx::Trade.find(params[:id])

    respond_to do |format|
      if @trade.update_attributes(trade_params)
        flash[:notice] = '用户更新成功'
        format.html { redirect_to :back }
        format.js { head :ok }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { raise }
        format.xml { render :xml => @trade.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete
    @trade = ::Fx::Trade.find(params[:id])

    respond_to do |format|
      format.html { render template: 'admin/shared/delete', locals: {record: @trade, unable_msg: '此等级无法删除？'}, :layout => false }
      format.xml { render :xml => @trade }
    end
  end
  
  def refund
    @trade = ::Fx::Trade.find(params[:id])
    respond_to do |format|
      format.html { render template: 'admin/shared/refund', locals: {record: @trade, unable_msg: '此等级无法删除？'}, :layout => false }
    end
  end

  def refundment
    @trade = ::Fx::Trade.find(params[:id])
    respond_to do |format|
      unless @trade.state == -1
        @success=database_transaction do 
          @trade.update(state: -1,amount: (@trade.amount * -1))
          @trade.pay!
        end
      end
      if @success
        flash[:notice] = '退款成功'
      else
        flash[:error] = '退款失败'
      end
      format.html { redirect_to admin_fx_trades_path  }
    end
  end
  
  def destroy
    @trade = ::Fx::Trade.find(params[:id])
    @trade.destroy_softly

    respond_to do |format|
      format.html { redirect_to admin_fx_trades_path, :status => :ok }
      format.xml { head :ok }
    end
  end

  protected

  def current_tab
    @current_tab="trade"
  end

  def trade_params
    params[:trade].permit([:name,:label,:level_id, :dealer1_percent, :dealer2_percent, :dealer3_percent])
  end

  def authorized?
    true
  end
end
