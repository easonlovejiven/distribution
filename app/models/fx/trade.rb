class Fx::Trade < ActiveRecord::Base
  self.table_name = "fx_trades"
  has_many :transations
  belongs_to :user
  scope :active, -> { where :active => true }
  scope :recent, -> { order('created_at DESC') }


  OPTYPE_NAME={
    1 => "在线招标",
    2 => "商城",
    3 => "脉脉圈",
    4 => "所得税",
    5 => "培训费"
  }

  after_create do
    pay!
  end

  def optype_name
    OPTYPE_NAME[optype]
  end

  #分配分销获利todo移除实时余额获利
  def pay!
    #个人订单消费累计
    user.update!(cost_amount: user.cost_amount+amount)
    #分给自己
    if state == -1
      sort = -1
    else
      sort = 1
    end
    self.transations.create!(user_id: user.id, amount: amount,sort: sort,subject: "个人消费返利")
    user.info.update!({amount: user.info.amount + amount})
    user.update!(total_amount: user.total_amount + amount)
    # #二级分销利润分配
    if prev_dealer=user.prev_dealer
      dealer1_percent=employee_percent(prev_dealer, prev_dealer.level.send(:dealer1_percent))
      dealer1_amount =amount*dealer1_percent
      self.transations.create!(user_id: prev_dealer.id, amount: dealer1_amount, dealer_level: 1, sort: sort,subject: "一级分销返利")
      prev_dealer.info.update!({amount1: prev_dealer.info.amount1+dealer1_amount})
      prev_dealer.update!({total_amount: prev_dealer.total_amount + dealer1_amount})
      # prev_dealer.income!(dealer1_amount)
      if prev2_dealer=prev_dealer.prev_dealer
        dealer2_percent=employee_percent(prev2_dealer, prev2_dealer.level.send(:dealer2_percent))
        dealer2_amount =amount*dealer2_percent
        self.transations.create!(user_id: prev2_dealer.id, amount: dealer2_amount, dealer_level: 2, sort: sort,subject: "二级分销返利")
        prev2_dealer.info.update!({amount2: prev2_dealer.info.amount2.to_f + dealer2_amount})
        prev2_dealer.update!({total_amount: prev2_dealer.total_amount + dealer2_amount})
        # prev2_dealer.income!(dealer2_amount)
        #        if prev3_dealer=prev2_dealer.prev_dealer
        #          dealer3_percent=employee_percent(prev3_dealer,prev3_dealer.level.send(:dealer3_percent))
        #          dealer3_amount =amount*dealer3_percent
        #          self.transations.create!(user_id: prev3_dealer.id, amount: dealer3_amount, dealer_level: 3, sort: 1)
        #          prev3_dealer.info.update!({amount3: user.info.amount3+dealer3_amount})
        #          # prev3_dealer.income!(dealer3_amount)
        #        end
      end
    end
  end

  #内部员工新增获利
  def employee_percent(dealer, percent)
    if employee=dealer.is_employee
      percent+=employee.percent
    end
    percent/100.00
  end


end
