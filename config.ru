# This file is used by Rack-based servers to start the application.

require 'sidekiq/web'
require 'sidetiq/web'

map '/sidekiq' do
  use Rack::Auth::Basic, "Protected Area" do |username, password|
    username == 'hzb' && password == '123123'
  end

  run Sidekiq::Web
end

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
