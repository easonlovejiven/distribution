class Admin::ApplicationController < ApplicationController
  protect_from_forgery
  layout 'admin/application'
  before_filter :log, if: -> { @current_user }

  def index
    return render('admin/manage/editors/login', layout: false) unless @current_user
    # return render :file => 'manage/manage/editors/activate', :layout => true unless (editor = @current_user.editor) && editor.active?
    return redirect_to params[:redirect] unless params[:redirect].blank?
    render :text => '', :layout => false if request.xhr?
  end

  private

  def is_special?
    ### admin/* 下页面需要 layout false
    params[:controller] == 'admin/home' ||
        params[:controller] == 'admin/uploads' ||
        params[:controller] == 'admin/cache/caches' ||
        params[:controller] =~ /\/application/ ||
        (params[:controller] == 'admin/manage/editors' && %w[activate_mail].include?(params[:action]))
  end

  def authorized?
    @enable_lazyload = !request.xhr?
    if @current_user.blank?
      return (params[:controller] == 'admin/application') ? true : redirect_to(root_path)
    else
      @current_user = ::Manage::User.acquire(@current_user.id)
      return redirect_to(root_path) unless @current_user && @current_user.active
    end
    return true if is_special?
    table = params[:controller].sub('admin/', '').gsub('/', '_').singularize
    table = 'manage_editor' if params[:controller] == 'admin/users'
    action = {
        'search' => 'index',
        'new' => 'create',
        'edit' => 'update',
        'browse' => 'show',
        'preview' => 'show',
        'unpublish' => "publish",
        'batch' => "create",
        'batch_create' => "create",
        'point_rank' => 'show',
        'chart' => 'show',
        'update_phone' => 'update',
        'clear_ip' => 'update',
        'delete' => 'destroy',
        'batch_delete' => 'destroy',
        'update_batch' => 'update',
        'snapshoot' => 'show',
        'customizer' => 'create',
        'customize' => 'create',
        'sync' => 'manage'
    }[params[:action]] || params[:action]
    return @current_user.can?(:index, table) || @current_user.can?(:show, table) if action == 'index'
    @current_user.send("can_#{action}_#{table}?")
  end

  def not_authorized
    session[:redirect_back_uri] = request.url
    # make sure return_to_url is right after user re-login once session is expired.
    # unless request.url.include? 'admin/sessions/new'
    #   session[:return_to_url] = root_url + 'manage/#' + request.fullpath
    # end
    # redirect_to new_manage_session_path, alert: "First login to acce"
    respond_to do |format|
      format.html { render template: 'admin/manage/editors/forbidden', layout: false }
      format.js { raise ActiveResource::UnauthorizedAccess.new(response) }
      format.xml { raise ActiveResource::UnauthorizedAccess.new(response) }
    end
  end

  def export(options = {})
    fields = (options[:records].const_defined?(:EXPORTS) ? options[:records].const_get(:EXPORTS) : {}).stringify_keys[options[:export]]
    fields = fields.map { |field| [field, field] }.to_h if fields.is_a?(Array)
    fields = {id: 'id'}.update(fields.to_h)
    table = [fields.keys.map { |field| options[:records].arel.engine.human_attribute_name(field) }] + options[:records].map { |record| fields.values.map { |field| field.respond_to?(:call) ? field.call(record) : record.respond_to?(field) ? record.send(field) : field } }
  end

  def log
    ::Manage::Log.create({
                             user_id: @current_user.id,
                             controller: '_controller_' + self.class.name.sub('Admin::Manage::', 'Admin::Shop::').gsub(/^Manage::|Controller$/, '').singularize,
                             action: '_action_' + self.action_name,
                             params_id: params[:id],
                         })
  end

  def model
    @model ||= self.class.name.gsub(/^Admin|Controller$/, '').singularize.constantize
  end

  def can?(*argv)
    return true
    @current_user.try(:can?, *argv)
  end

  def param_key
    model.model_name.param_key
  end

  def id
    @id ||= params[:id].try(:to_i)
  end
end
