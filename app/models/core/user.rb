##
# = 主站 用户 表
#
# == Fields
#
# pic :: 头像
# name :: 名字
# sex :: 性别
# birthday :: 生日
#
# == Indexes
#
class Core::User < ActiveRecord::Base
  establish_connection(Rails.configuration.database_configuration["core"][Rails.env])
  PHONE_REGEX = /\A0?1(3[0-9]|5[012356789]|7[0678]|8[0-9]|4[57])[0-9]{8}\z/

  has_one :hfbpay,class_name: "Core::Hfbpay"
  has_many :bang_withdraws,class_name: "Core::BangWithdraw"
  has_many :assets,class_name: "Core::Asset"
  belongs_to :city,class_name: "Core::City"
  belongs_to :province,class_name: "Core::Province"
  before_create :generate_auth_token
  validates_presence_of :nickname, :message => "请输入昵称"
  #validates_uniqueness_of :nickname, :message => '昵称已经存在'
  #验证通过
  VERIFIED = {
    #待定
    :default => 0,
    #通过
    :ok => 1,
    #正在审核
    :on => 2

  }

  def self.authenticate(account, password)
    user = Core::User.find_by_account_and_is_deleted(account, false)
    if user && user.password == password
      user
    else
      nil
    end
  end


  def self.pay_authenticate(account, password)
    user = Core::User.find_by_account(account)
    if user && user.account_password == password
      user
    else
      nil
    end
  end

  def self.encrypt_password(password)
    return Digest::MD5.hexdigest(password)
  end


  #已通过实名认证
  def verified?
    self.is_verify == Core::User::VERIFIED[:ok]
  end

  def avatar_url
    Rails.application.secrets.qiniu_domain + self.avatar if self.avatar.present?
  end

  def province_name
    province.try(:name)
  end

  def city_name
    city.try(:name)
  end

  def generate_auth_token
    loop do
      self.auth_token = SecureRandom.base64(64)
      break unless Core::User.find_by(auth_token: self.auth_token)
    end
  end

  def reset_auth_token!
    generate_auth_token
    save
  end

  def bang_amount
    self.hfbpay.try(:bang_amount)
  end

  def withdraw_coding
    "TX#{self.id}#{Time.now.to_i}"
  end
  
  #当月已提现的金额
  def current_month_withdraw_amount
    Core::BangWithdraw.where(user_id: self.id).sum(:price)
  end
  
  def active_hfbpay
    unless self.hfbpay
      hfbpay = self.build_hfbpay(current_amount: 0)
      hfbpay.save!
    end
  end

  # def login_today(ip_address) # :nodoc: all
  #   login = Core::Login.where(user_id: self.id, login_on: Time.now.to_date).first_or_initialize
  #   login.ip_address ||= ip_address
  #   account.last_login_on = Date.today
  #   account.save if account.changed?
  #   login.save if login.changed?
  # end

end
