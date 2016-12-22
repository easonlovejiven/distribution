class Admin::Fx::UsersController < Admin::Fx::ApplicationController
  before_action :current_tab

  def index
    @users = ::Fx::User.active._where(params[:where])._order(params[:order]).page(params[:page]).per(params[:per_page])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @users }
    end
  end

  def apply
    @users = ::Fx::User.active.where.not(state: [1,-1])._where(params[:where])._order(params[:order]).page(params[:page]).per(params[:per_page])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @users }
    end
  end

  def show
    @user = ::Fx::User.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @user }
    end
  end

  def children
    @user     = ::Fx::User.find(params[:id])
    @level1_dealers=@user.level1_dealers.includes(:dealer)._where(params[:where])._order(params[:order]).page(params[:page])
  end

  def new
    @user = ::Fx::User.new

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @user }
    end
  end

  def create
    @user = ::Fx::User.new(user_params)

    respond_to do |format|
      if @user.save
        flash[:notice] = '等级创建成功'
        format.html { redirect_to :back }
        format.xml { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @user = ::Fx::User.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @user }
    end
  end

  def update
    @user = ::Fx::User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(user_params)
        flash[:notice] = '用户更新成功'
        format.html { redirect_to :back }
        format.js { head :ok }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { raise }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete
    @user = ::Fx::User.find(params[:id])

    respond_to do |format|
      format.html { render template: 'admin/shared/delete', locals: {record: @user, unable_msg: '此等级无法删除？'}, :layout => false }
      format.xml { render :xml => @user }
    end
  end

  def delete_relation_list

  end


  def edit_relation
    @user = ::Fx::User.find(params[:id])
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @user }
    end
  end
  
  def new_relation
    @user = ::Fx::User.find(params[:id])
    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @user }
    end
  end

  def update_relation
    @user = ::Fx::User.find(params[:id])
    @user.update_prev_relation(params[:user][:new_user_id])
    respond_to do |format|
      format.js { render :js => "App.redirect('#{admin_fx_users_path(page: params[:page])}');" }
    end
  end
  
  def add_relation
    @user = ::Fx::User.find(params[:id])
    @user.add_relation(params[:user][:new_user_id])
    respond_to do |format|
      format.html { redirect_to :back, :status => :ok }
      format.xml { render :xml => @user }
    end
  end

  def delete_relation
    @user = ::Fx::User.find(params[:id])

    respond_to do |format|
      format.html { render action: 'delete_relation', locals: {record: @user, unable_msg: '当前无法解除？'}, :layout => false }
      format.xml { render :xml => @user }
    end
  end

  def remove_relation
    @user = ::Fx::User.find(params[:id])
    @user.remove_prev_relation
    respond_to do |format|
      format.js { render :js => "App.redirect('#{admin_fx_users_path(page: params[:page])}');" }
    end
  end

  def destroy
    @user = ::Fx::User.find(params[:id])
    @user.destroy_softly

    respond_to do |format|
      format.html { redirect_to :back, :status => :ok }
      format.xml { head :ok }
    end
  end
  
 

  protected

  def current_tab
    @current_tab="user"
  end

  def user_params
    params[:user].permit([:name, :label, :level_id, :dealer1_percent, :dealer2_percent, :dealer3_percent, :state])
  end

  def authorized?
    true
  end
end
