class Core::BangWithdraw < ActiveRecord::Base
  establish_connection(Rails.configuration.database_configuration["core"][Rails.env])

  belongs_to :user

  validates_presence_of :user_id, :message => "用户不能为空"
  validates_presence_of :price, :message => "金额不能为空"
  validates_presence_of :bank_name, :message => "银行不能为空"
  validates_presence_of :bank_account, :message => "银行卡号不能为空"
  validates_presence_of :user_name, :message => "开户名称不能为空"

  scope :recent, -> { order('created_at DESC') }
  #状态
  STATE = {
    :default =>0,#申请中
    :ok => 1,#已汇款
    :fail => -1, #审核未通过,
    :audit => 2, #审核中,
    :process => 3 #汇款中
  }
  
  STATE_NAME = {
    0 =>"申请中",
    2=>"审核中",
    3=>"汇款中",
    1=> "已汇款",
    -1 => "审核未通过",
  }
  
  def state_name
    STATE_NAME[self.state]
  end
  
end
