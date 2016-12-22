class FxTrades < ActiveRecord::Migration
  def change
    create_table "fx_trades" do |t|
      t.string "number"  #订单号
      t.string "name"  #交易名称
      t.integer "user_id"  #来自用户
      t.integer "optype"  #交易类型1:产品、2:任务,3:脉脉圈
      t.integer "total_amount",precision: 10, scale: 2, default: 0.0  #订单金额
      t.integer "amount",precision: 10, scale: 2, default: 0.0  #可分配利润
      t.integer "state", default: 0
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
