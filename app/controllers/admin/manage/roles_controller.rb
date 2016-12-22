class Admin::Manage::RolesController < Admin::Manage::ApplicationController
  before_action :set_model

  def index
    @roles = ::Manage::Role.active._where(params[:where])._order(params[:order]).page(params[:page]).per(params[:per_page])
    # @roles = [].paginate(:page => 1) unless @current_user.can?(:index, ::Manage::Role.new) || @roles.total_entries <= 1
    respond_to do |format|
      format.html { render :action => 'index', :layout => false if request.xhr? }
    end
  end

  def show
    @role = ::Manage::Role.acquire(params[:id])
    respond_to do |format|
      format.html { render :action => 'show', :layout => false if request.xhr? }
    end
  end

  def new
    @role = ::Manage::Role.new
    params[:manage_role] = (params[:manage_role]||{}).merge(@role.class.acquire(params[:id]).attributes) if params[:id]
    @role.attributes = (params[:manage_role]||{}).slice(*@role.class.manage_fields)

    respond_to do |format|
      format.html { render :action => 'show', :layout => false if request.xhr? }
    end
  end

  def create
    @role = ::Manage::Role.new
    @role.attributes = params.require(:manage_role).permit(*@role.class.manage_fields)
    @role.save

    respond_to do |format|
      format.html { redirect_to :action => 'index',status: :ok }
    end
  end

  def edit
    @role = ::Manage::Role.acquire(params[:id])
    @role.attributes = (params[:manage_role]||{}).slice(*@role.class.manage_fields)

    respond_to do |format|
      format.html { render :action => 'show', :layout => false if request.xhr? }
    end
  end

  def update
    @role = ::Manage::Role.acquire(params[:id])
    @role.attributes = params.require(:manage_role).permit(*@role.class.manage_fields)
    @role.save

    respond_to do |format|
      format.html { redirect_to :action=>"index",status: :ok }
      # format.js { head @role.valid? ? :accepted : :bad_request }
    end
  end

  def destroy
    @role = ::Manage::Role.acquire(params[:id])
    @role.attributes = {:active => false}
    @role.save

    respond_to do |format|
      format.html { redirect_to :action => 'index',status: :ok }
    end
  end

  def delete
    @role = ::Manage::Role.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @role }
    end
  end


  def set_model
    @model = Manage::Role
  end
end
