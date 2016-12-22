class Admin::Manage::LogsController < Admin::Manage::ApplicationController

  def index
    @logs = ::Manage::Log._where(params[:where])._order(params[:order]).paginate(page: params[:page], per_page: params[:per_page])
  end
end
