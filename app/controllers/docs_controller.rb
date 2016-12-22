class DocsController < ApplicationController

  USER_NAME, PASSWORD = 'hzb', '123123'

  before_filter :basic_authenticate

  layout false

  def index
    render :file=>"#{Rails.root}/public/docs/index.html"
  end

  private

  def basic_authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == USER_NAME && password == PASSWORD
    end
  end

end