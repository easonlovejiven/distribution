class Fx::Transation < ActiveRecord::Base
  self.table_name = "fx_transations"
  belongs_to :trade
  belongs_to :dealer,class_name: "::Fx::User",foreign_key: "user_id"
  scope :recent, -> { order('created_at DESC') }

  def trade_name
    self.trade.name
  end

  def trade_amount
    self.trade.total_amount
  end

  self.json_options={
      :only => ["trade_id","amount","created_at","sort"],
      :methods => [:trade_name,:trade_amount]
  }
end