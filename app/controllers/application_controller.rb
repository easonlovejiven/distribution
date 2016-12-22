class ApplicationController < ActionController::Base
  include GenerateFormatExt
  include UserCookie
  include Auth
  before_action :login_filter
  before_action :user_cookies
  include RespondToXml
  around_filter :respond_to_xml
  protect_from_forgery with: :exception
  # before_action :authenticate_user!, :except => [:notify]
  skip_before_action :verify_authenticity_token
  before_action :preprocess_params
  helper_method :current_user


  def can?(*argv)
    @current_user.try(:can?, *argv)
  end

  def preprocess_params
    params[:page] = nil if params[:page] == ''
    params[:per_page] = nil if params[:per_page] == ''
    params[:format] = nil if params[:format] == ''
    # params[:engine] ||= 'solr'
    # sleep 10
  end

  #邀请用户
  def add_invitation_users
    user = Fx::User.find_by_invitation(params[:invitation])
    if user
      invite = user.invites.new(:used_by => @user.id)
      invite.save
    end
  end
  
  def generate_code
    [*'0'..'9'].sample(4).join
  end
 
  protected

  def database_transaction
    begin
      ActiveRecord::Base.transaction do
        yield
      end
      true
    rescue => e
      logger.error %[#{e.class.to_s} (#{e.message}):\n\n #{e.backtrace.join("\n")}\n\n]
      false
    end
  end
end
