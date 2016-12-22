class Admin::Manage::SessionsController < Admin::Manage::ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    logout_keeping_session!
    @editor = ::Manage::Editor.active.find_by(identifier: params[:account][:login])
    if Core::User.authenticate(params[:account][:login],Core::User.encrypt_password(params[:account][:password]))
      session[:user_id] = @editor.id
      respond_to do |format|
        format.html { redirect_to params[:redirect] || root_path }
        format.xml { @data = {'account' => @editor.account} }
      end
    else
      logger.warn "Failed login for '#{params[:account][:login]}' from #{request.remote_ip} at #{Time.now}"
      @login = params[:login]
      @remember_me = params[:remember_me]

      flash[:notice] = "用户名或密码输入错误"
      respond_to do |format|
        format.html { render :action => 'new' }
        format.xml { raise ArgumentError, "用户名或密码输入错误" }
      end
    end
  end

  private

  def authorized?
    true
  end
end
