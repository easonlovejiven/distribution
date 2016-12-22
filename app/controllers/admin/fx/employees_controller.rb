class Admin::Fx::EmployeesController < Admin::Fx::ApplicationController
  before_action :current_tab

  def index
    @employees = ::Fx::Employee._where(params[:where])._order(params[:order]).page(params[:page]).per(params[:per_page])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @employees }
    end
  end

  def show
    @employee = ::Fx::Employee.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @employee }
    end
  end

  def new
    @employee = ::Fx::Employee.new

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @employee }
    end
  end

  def create
     success= ::Fx::Employee.create(employee_params)

    respond_to do |format|
      if success
        flash[:notice] = '等级创建成功'
        format.html { redirect_to :back}
        format.xml { render :xml => @employee, :status => :created, :location => @employee }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @employee.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @employee = ::Fx::Employee.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false if request.xhr? }
      format.xml { render :xml => @employee }
    end
  end

  def update
    @employee = ::Fx::Employee.find(params[:id])

    respond_to do |format|
      if @employee.update_attributes(employee_params)
        flash[:notice] = '等级更新成功'
        format.html { redirect_to :back }
        format.js { head :ok }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.js { raise }
        format.xml { render :xml => @employee.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete
    @employee = ::Fx::Employee.find(params[:id])

    respond_to do |format|
      format.html { render template: 'admin/shared/delete', locals: {record: @employee, unable_msg: '此等级无法删除？'}, :layout => false }
      format.xml { render :xml => @employee }
    end
  end

  def destroy
    @employee = ::Fx::Employee.find(params[:id])
    @employee.destroy_softly

    respond_to do |format|
      format.html { redirect_to :back, :status => :ok }
      format.xml { head :ok }
    end
  end

  protected

  def current_tab
    @current_tab="employee"
  end

  def employee_params
    params[:employee].permit([:id,:name,:role])
  end

  def authorized?
    true
  end
end
