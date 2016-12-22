class Fx::TaxRate < ActiveRecord::Base
  self.table_name = "fx_tax_rates"
  belongs_to :user
  belongs_to :trade
  scope :recent, -> { order('created_at DESC') }
  STATE={
      0 => "未结算",
      1 => "已结算"
  }

  def trade_number
    "PXF#{self.id}#{Time.now.to_i}"
  end

  def pay
    Fx::Transation.create!(user_id: self.user_id, amount: self.amount, sort: 0, subject: "个人所得税")
  end

  def state_name
    STATE[self.state]
  end

  def pay!
    pay
    user.outcome!(self.amount)
  end

  def balance_income
    state==1 ? total_amount-amount :  0
  end

  self.json_options={
      :only    => ["amount", "total_amount", "date", "state"],
      :methods => [:month_amount]
  }
end
