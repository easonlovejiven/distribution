class Admin::Fx::UpgradesController < Admin::Fx::ApplicationController

  def show
    @upgrade = ::Fx::Upgrade.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @upgrade }
    end
  end

  def new
    @upgrade = ::Fx::Upgrade.new

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @upgrade }
    end
  end

  def create
    @upgrade = ::Fx::Upgrade.new(upgrade_params)

    respond_to do |format|
      if @upgrade.save
        flash[:notice] = '等级创建成功'
        format.html { redirect_to :back}
        format.xml { render :xml => @upgrade, :status => :created, :location => @upgrade }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @upgrade.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @upgrade = ::Fx::Upgrade.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @upgrade }
    end
  end

  def update
    @upgrade = ::Fx::Upgrade.find(params[:id])

    respond_to do |format|
      if @upgrade.update_attributes(upgrade_params)
        flash[:notice] = '等级更新成功'
        format.html { redirect_to :back}
        format.js { head :ok }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { raise }
        format.xml { render :xml => @upgrade.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

  def upgrade_params
    params[:upgrade].permit([:level_id,:month,:count,:amount])
  end

  def authorized?
    true
  end
end
