class Admin::Manage::PatternsController < Admin::Manage::ApplicationController
  layout -> (controller) { controller.request.xhr? && %w{new show edit}.include?(controller.action_name) ? 'modal' : false }

  # before_action :find_record, except: [:index, :new, :create]

  def index
    render text: '', layout: true and return if controller_name.match(/application/)
    @records = model.default(params).includes(model.send(:reflections).keys)
    @records = @records.none if @records.count > 1
  end

  def show
    @record = model.f(id)
    @show = true
    # instance_variable_set "@#{controller_name.singularize}".to_sym, record
  end

  def preview
    @record = model.f(id)
    # instance_variable_set "@#{controller_name.singularize}".to_sym, model.f(id)
  end

  def new
    @record = model.new
    @record.attributes = model.f(id).attributes.slice(*@record.manage_fields) if id
    @show = false
    render :show
  end

  # TODO
  def create
    @record = model.new
    @record.attributes = params.require(param_key).permit(*@record.manage_fields)
    if @record.respond_to?(:creator_id)
      @record.creator_id = @current_user.id
    end
    @record.save

    respond_with(@record) do |format|
      format.html { render :show }
      format.js { head :ok, info: '创建成功！' }
    end
  end

  def edit
    @record = model.f(id)
    # instance_variable_set "@#{controller_name.singularize}".to_sym, model.f(id)
    @show = false
    render :show
  end

  def update
    @record = model.f(id)
    @record.attributes = params.require(param_key).permit(*@record.manage_fields)

    if @record.respond_to?(:updater_id)
      @record.updater_id = @current_user.id
    end

    @record.save

    respond_with(@record) do |format|
      format.html { render :show }
      format.js { head :ok, info: '修改成功！' }
    end
  end

  def publish
    @record = model.f(id)
    @record.update_attributes(published: true, updater_id: @current_user.id)
    head @record.valid? ? :accepted : :bad_request
  end

  def unpublish
    @record = model.f(id)
    @record.update_attributes(published: false, updater_id: @current_user.id)
    head @record.valid? ? :accepted : :bad_reqest
  end

  def delete
    @record = model.f(id)
    instance_variable_set "@#{controller_name.singularize}".to_sym, model.f(id)
    render template: 'manage/shared/delete'
  end

  def destroy
    @record = model.f(id)
    @record.attributes = {active: false, updater_id: @current_user.id}
    @record.save
    head @record.valid? ? :accepted : :bad_request
  end

  private

  def find_record
    # @record = model.f(id)
    @show = !%w[new edit].include?(params[:action]) && @record.valid?
    # head :not_found, info: '找不到你想要的记录！' if @record.blank?
  end
end
