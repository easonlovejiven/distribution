class Fx::TrainFee < ActiveRecord::Base
  self.table_name = "fx_tax_rates"
  belongs_to :user
  belongs_to :payer, foreign_key: "payer_id"
  scope :recent, -> { order('created_at DESC') }


  def trade_number
    "PXF#{self.id}#{Time.now.to_i}"
  end


  def pay!
    Fx::Transation.create!(user_id: self.id, amount: self.amount, sort: 1, subject: "培训费")
    Fx::Transation.create!(user_id: self.payer_id, amount: self.amount, sort: 0, subject: "培训费")
  end

  self.json_options={
      :only    => ["amount", "total_amount", "date", "state"],
      :methods => [:month_amount]
  }
end
