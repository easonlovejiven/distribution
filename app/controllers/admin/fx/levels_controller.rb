class Admin::Fx::LevelsController < Admin::Fx::ApplicationController
  before_action :current_tab

  def index
    @levels = ::Fx::Level.active._where(params[:where])._order(params[:order]).page(params[:page]).per(params[:per_page])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @levels }
    end
  end

  def show
    @level = ::Fx::Level.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @level }
    end
  end

  def new
    @level = ::Fx::Level.new

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @level }
    end
  end

  def create
    @level = ::Fx::Level.new(level_params)

    respond_to do |format|
      if @level.save
        flash[:notice] = '等级创建成功'
        format.html { redirect_to :back}
        format.xml { render :xml => @level, :status => :created, :location => @level }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @level.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @level = ::Fx::Level.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @level }
    end
  end

  def update
    @level = ::Fx::Level.find(params[:id])

    respond_to do |format|
      if @level.update_attributes(level_params)
        flash[:notice] = '等级更新成功'
        format.html { redirect_to :back }
        format.js { head :ok }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { raise }
        format.xml { render :xml => @level.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete
    @level = ::Fx::Level.find(params[:id])

    respond_to do |format|
      format.html { render template: 'admin/shared/delete', locals: {record: @level, unable_msg: '此等级无法删除？'}, :layout => false }
      format.xml { render :xml => @level }
    end
  end

  def destroy
    @level = ::Fx::Level.find(params[:id])
    @level.destroy_softly

    respond_to do |format|
      format.html { redirect_to :back, :status => :ok }
      format.xml { head :ok }
    end
  end

  protected

  def current_tab
    @current_tab="level"
  end

  def level_params
    params[:level].permit([:name,:label, :dealer1_percent, :dealer2_percent, :dealer3_percent])
  end

  def authorized?
    true
  end
end
