class Admin::HomeController < Admin::ApplicationController
  before_action :current_tab

  def index
    ### 不能有layout
  end

  private

  def current_tab
    @current_tab="home"
  end
end
