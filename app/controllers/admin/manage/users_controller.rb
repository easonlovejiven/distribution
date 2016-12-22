class Admin::Manage::UsersController < Admin::Manage::ApplicationController

  def show
    @user = ::Manage::User.acquire(params[:id])
  end
end
