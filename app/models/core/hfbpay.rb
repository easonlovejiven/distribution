class Core::Hfbpay < ActiveRecord::Base
  establish_connection(Rails.configuration.database_configuration["core"][Rails.env])
  #会付宝
  belongs_to :user

  validates_presence_of :user_id, :message => "用户不能为空"

  #是否是会付宝会员
  def is_hfbpay
    true
  end

  def invitation
    self.user.try(:invitation)
  end

  def user_nickname
    self.user.try(:nickname)
  end

  def user_account
    self.user.try(:account)
  end

  def bang_total_amount
    Core::Payment.where(user_id: self.user_id, target_type: 'Bang').sum("price")
  end
  
  def bang_withdraw_pay(bang_withdraw)
    user = bang_withdraw.user
    balance = self.bang_amount - bang_withdraw.price
    payment = Core::Payment.new(target: bang_withdraw, :number =>bang_withdraw.number, :user_id => user.id, :price => bang_withdraw.price, :sort => Core::Payment::SORT[:payment],
      :paytype => Core::Payment::PAYTYPE[:hfbpay],:state=> 0, :balance => balance, :subject => '邦邦提现')
    payment.save!
    self.update_attributes!(bang_amount: balance)
  end
  
  def self.set_total_bang_amount
    Core::Hfbpay.all.each do |hfbpay|
      task_user = Core::TaskUser.where(user_id: hfbpay.user_id)
      if task_user
        task_amount = task_user.sum(:amount) 
      else
        task_amount = 0
      end
      fx_user = Fx::User.where(id: hfbpay.user_id).first
      if fx_user
        user_amount = fx_user.total_amount
      else
        user_amount = 0
      end
      hfbpay.update(total_bang_amount: task_amount + user_amount)
    end
  end

  self.json_options={
    :only => ["id", "user_id", "assure_amount", "bang_amount", "current_amount", "total_amount"],
    :methods => [:is_hfbpay, :invitation, :user_nickname, :user_account,:bang_total_amount]
  }
end
