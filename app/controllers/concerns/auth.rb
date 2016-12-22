module Auth
  def logged_in?
    @current_user
  end


  def login_from_session
    # Rails.logger.info { "#{session.inspect}" }
    @current_user = Core::User.find(session[:user_id]) if session[:user_id]
    # if session[:user_account] && session[:user_expired_at] && Time.now < session[:user_expired_at]
  end

  #  def login_from_basic_auth
  #    authenticate_with_http_basic do |email, password|
  #      @current_user = Core::User.authenticate(email, password)
  #    end
  #  end

  def login_from_basic_auth_token
    if params[:token].present?
      logout_killing_session!
      token =  params[:token].gsub(' ', '+')
      account = Core::User.find_by_auth_token(token)
      if account  
        session[:user_id] = account.id 
        @current_user = account 
      end
    elsif session[:user_id]
      @current_user = Core::User.find(session[:user_id]) 
    end 
  end

  def logout_keeping_session!
    # @current_user.forget_me if @current_user.is_a? Core::User
    @current_user = false
    #kill_remember_cookie!
    session[:user_id] = nil
    session[:user_login_on] = nil
  end

  def logout_killing_session!
    logout_keeping_session!
    reset_session
  end

  def handle_remember_cookie!(new_cookie_flag)
    # return unless @current_user
    # @current_user.remember_me_until(new_cookie_flag ? 60.days.from_now : nil)
    send_remember_cookie!
  end

  def kill_remember_cookie!
    cookies.delete :auth_token
  end

  def send_remember_cookie!
    cookies[:auth_token] = {
      :domain => ".#{Rails.application.secrets.domain}",
      :path => "/",
      :value => "#{@current_user.id}-#{@current_user.remember_token}",
      :expires => @current_user.remember_token_expires_at
    }
  end

  def current_user
    @current_user ||=  login_from_basic_auth_token #|| login_from_cookie
  end

  def current_user= new_user
    @current_user = new_user
  end

  def authorized?
    true
  end

  def api(p={})
    app = (p.delete(:app) || current_app)
    p = {
      :v => "1.0",
      :format => "JSON",
      :call_id => Time.now.to_i,
      :api_key => "#{app[:id]}-#{app[:api_key]}",
      # :session_key => cookies[:auth_token] || params[:auth_token],
      :@current_user => @current_user
    }.merge(p)
    p.merge!(:sig => Digest::MD5.hexdigest(p.map { |k, v| "#{k}=#{v}" }.sort.join + app[:secret]))
    if Core::ApiController
      type, data = Core::ApiController.new.parse(p)
      resp = render_to_string :template => "core/api/#{type}.#{p[:format]=='JSON' ? 'json.erb' : 'xml.builder'}", :locals => data, :layout => false
    else
      resp = HTTParty.post("http://barlar.cn/core/api", :query => p)
    end
    hash = (p[:format]=='JSON' ? ActiveSupport::JSON.decode(resp) : Crack::XML.parse(resp))
    raise hash.inspect if hash.is_a?(Hash) && hash['error_code']
    hash
  end

  def not_authorized
    if @current_user
      respond_to do |format|
        format.html { raise ActiveResource::ForbiddenAccess.new(response) }
        format.js { raise ActiveResource::ForbiddenAccess.new(response) }
        format.xml { raise ActiveResource::ForbiddenAccess.new(response) }
      end
    else
      respond_to do |format|
        format.html {
          # if request.url =~ /comm\.barlar\.cn/
          #   redirect_to '/'
          #   return
          # end
          redirect_to new_core_session_path(:redirect => request.fullpath)
        }
        format.js { raise ActiveResource::UnauthorizedAccess.new(response) }
        format.xml { raise ActiveResource::UnauthorizedAccess.new(response) }
      end
    end
  end

  def not_found_source!
    raise ActiveRecord::RecordNotFound, 'not found published!'
  end

  def login_filter
    if current_user
      if session[:user_login_on] != Time.now.to_date
        # @current_user.login_today(request.remote_ip)
        session[:user_login_on] = Time.now.to_date
      end
    end
    not_authorized if !authorized?
  end
end
