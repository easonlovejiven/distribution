class Admin::Fx::InvitesController < Admin::Fx::ApplicationController
  before_action :current_tab
  def index
    @invites = ::Fx::Invite._where(params[:where])._order(params[:order]).page(params[:page]).per(params[:per_page])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @invites }
    end
  end

  def show
    @invite = ::Fx::Invite.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @invite }
    end
  end

  def new
    @invite = ::Fx::Invite.new

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @invite }
    end
  end

  def create
    @invite = ::Fx::Invite.new(invite_params)

    respond_to do |format|
      if @invite.save
        flash[:notice] = '等级创建成功'
        format.html { redirect_to :back }
        format.xml { render :xml => @invite, :status => :created, :location => @invite }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @invite.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @invite = ::Fx::Invite.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @invite }
    end
  end

  def update
    @invite = ::Fx::Invite.find(params[:id])

    respond_to do |format|
      if @invite.update_attributes(invite_params)
        flash[:notice] = '等级更新成功'
        format.html { redirect_to :back }
        format.js { head :ok }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { raise }
        format.xml { render :xml => @invite.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete
    @invite = ::Fx::Invite.find(params[:id])

    respond_to do |format|
      format.html { render template: 'admin/shared/delete', locals: {record: @invite, unable_msg: '此等级无法删除？'}, :layout => false }
      format.xml { render :xml => @invite }
    end
  end

  def destroy
    @invite = ::Fx::Invite.find(params[:id])
    @invite.destroy_softly

    respond_to do |format|
      format.html { redirect_to :back, :status => :ok }
      format.xml { head :ok }
    end
  end

  protected
  def current_tab
    @current_tab="invite"
  end

  def invite_params
    params[:invite].permit([:name,:label, :dealer1_percent, :dealer2_percent, :dealer3_percent])
  end

  def authorized?
    true
  end
end
