class Core::Payment < ActiveRecord::Base
  establish_connection(Rails.configuration.database_configuration["core"][Rails.env])
  #交易支付
  belongs_to :user
  belongs_to :target, polymorphic: true

  validates_presence_of   :user_id,:message=>"用户不能为空"
  validates_presence_of   :target_id,:message=>"不能为空"
  validates_presence_of   :number,:message=>"交易编号不能为空"

  paginates_per 10
  PAYTYPE = {
    :alipay =>'alipay' ,#支付宝
    :weixin => 'weixin' ,#微信
    :hfbpay => 'hfbpay' ,#会付宝
    :tonglian => 'tonglian', #通联支付
    :bank => 'bank'  #银行
  }
  
  SORT ={
    :payment => 0, #支出
    :income => 1 #收入
  }
  
  scope :recent, -> { order('created_at DESC')}
  
  def paytype_name
    case paytype
    when 'alipay'
      '支付宝'
    when 'weixin'
      '微信'
    when 'tonglian'
      '通联'
    when 'bank'
      '银行转账'
    else
      '会付宝'  
    end
  end

  self.json_options={
      :only => ["id", "user_id", "price", "target_id", "target_type", "balance", "paytype", "subject", "state", "created_at", "sort", "brokerage", "number"] ,
  }


end
