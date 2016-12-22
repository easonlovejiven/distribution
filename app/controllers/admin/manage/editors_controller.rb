class Admin::Manage::EditorsController < Admin::Manage::ApplicationController
  before_action :set_model

  def index
    @editors = Manage::Editor.active.where(params[:where]).order(params[:order]).page(params[:page]).per(params[:per_page])
    # @editors = [].paginate(:page => 1) unless @current_user.can?(:index, Manage::Editor.new) || @editors.total_entries <= 1
    respond_to do |format|
      format.html { render :action => 'index', :layout => false if request.xhr? }
    end
  end

  def show
    @editor = Manage::Editor.acquire(params[:id])
    respond_to do |format|
      format.html { render :action => 'show', :layout => false if request.xhr? }
    end
  end

  def new
    @editor = Manage::Editor.new
    @editor.id = params[:id]
    params[:manage_editor] = (params[:manage_editor]||{}).merge(Manage::User.acquire(params[:id]).attributes.slice(*%w[name])) if params[:id]
    @editor.attributes = (params[:manage_editor]||{}).slice(*@editor.class.manage_fields)

    respond_to do |format|
      format.html { render :action => 'show', :layout => false if request.xhr? }
    end
  end

  def create
    @editor = Manage::Editor.where(id: params[:manage_editor][:id]).first_or_initialize
    @manage_user = Manage::User.where(id:  @editor.id).first_or_initialize
    account = Core::User.acquire(@editor.id)
    @editor.attributes={identifier: params[:manage_editor][:identifier],name: params[:manage_editor][:name],active: true}
    @manage_user.attributes={active: true}
    @editor.role_id = params[:manage_editor][:role_id]
    # @editor.attributes = (params[:manage_editor]||{}).slice(*@editor.class.manage_fields).merge(:creator_id => @current_user.id, :active => true)
    success = database_transaction do
      @editor.save!
      @manage_user.save!
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { head :ok, info: success ? '创建成功！' : '创建失败！' }
    end
  end

  def edit
    @editor = Manage::Editor.acquire(params[:id])
    @editor.attributes = (params[:manage_editor]||{}).slice(*@editor.class.manage_fields)

    respond_to do |format|
      format.html { render :action => 'show', :layout => false if request.xhr? }
    end
  end

  def update
    @editor = Manage::Editor.acquire(params[:id])
    @editor.attributes = params[:manage_editor].permit(["identifier","role_id","name"])
    @editor.save

    respond_to do |format|
      format.html { redirect_to :back }
      format.js { head @editor.valid? ? :accepted : :bad_request }
    end
  end
  #
  # def update
  #   @record = model.f(id)
  #   @record.attributes = params.require(param_key).permit(*@record.manage_fields)
  #
  #   if @record.respond_to?(:updater_id)
  #     @record.updater_id = @current_user.id
  #   end
  #
  #   @success = database_transaction do
  #     @record.save!
  #     User.f(id).update_attributes!(email: "#{@record.prefix}")
  #   end
  #
  #   respond_to do |format|
  #     format.html { render :show }
  #     if @success
  #       format.js { head :ok, info: '修改成功！' }
  #     else
  #       format.js { head :ok, info: '创建失败！' }
  #     end
  #   end
  #
  # end

  def destroy
    @editor = Manage::Editor.acquire(params[:id])
    @editor.attributes = {:active => false}
    @editor.save

    respond_to do |format|
      format.html { render :action => 'show' }
    end
  end

  def activate_mail
    Core::Mailer.mail(params.slice(:to, :reply_to).merge(
                          :subject => "申请激活主站管理帐号（#{@current_user.name} #{request.domain(999)}）",
                          :body => "#{params[:body]}\n\nhttp://#{request.domain(999)}/manage/manage/editors/new?id=#{@current_user.id}\n\n",
                          :cc => %[info@barlar.cn],
                          :content_type => "text/plain"
                      ))
    render :text => "<h2>已向主管（#{params[:to]}）发送邮件，请等待批准</h2>", :layout => true
  end

  def delete
    @editor = Manage::Editor.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @editor }
    end
  end

  private

  def set_model
    @model = Manage::Editor
  end
end
