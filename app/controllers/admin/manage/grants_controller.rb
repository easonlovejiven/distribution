class Admin::Manage::GrantsController < Admin::Manage::ApplicationController
  before_action :set_model

  def index
    @grants = ::Manage::Grant.active._where(params[:where])._order(params[:order]).page(params[:page]).per(params[:per_page])
    # @grants = [].paginate(:page => 1) unless @current_user.can?(:index, ::Manage::Grant.new) || @grants.total_entries <= 1
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { @data = @brands }
    end
  end

  def show
    @grant = ::Manage::Grant.acquire(params[:id])
  end

  def new
    @grant = ::Manage::Grant.new
    params[:manage_grant] = (params[:manage_grant]||{}).merge(@grant.class.acquire(params[:id]).attributes) if params[:id]
    @grant.attributes = (params[:manage_grant]||{}).slice(*@grant.class.manage_fields)

    respond_to do |format|
      format.html { render :action => 'show', :layout => false if request.xhr? }
    end
  end

  def create
    @grant = ::Manage::Grant.new
    @grant.attributes = (params[:manage_grant]||{}).slice(*@grant.class.manage_fields)
    @grant.save

    respond_to do |format|
      format.html { render :action => 'show' }
    end
  end

  def edit
    @grant = ::Manage::Grant.acquire(params[:id])
    @grant.attributes = (params[:manage_grant]||{}).slice(*@grant.class.manage_fields)

    respond_to do |format|
      format.html { render :action => 'show' }
    end
  end

  def update
    @grant = ::Manage::Grant.acquire(params[:id])
    @grant.attributes = (params[:manage_grant]||{}).slice(*@grant.class.manage_fields)

    @grant.save

    respond_to do |format|
      format.html { render :action => 'show' }
      format.js { head @grant.valid? ? :accepted : :bad_request }
    end
  end

  def destroy
    @grant = ::Manage::Grant.acquire(params[:id])
    @grant.attributes = {:active => false}
    @grant.save

    respond_to do |format|
      format.html { render :action => 'show' }
    end
  end

  private

  def set_model
    @model = Manage::Editor
  end
end
