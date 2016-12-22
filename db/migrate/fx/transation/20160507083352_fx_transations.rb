class FxTransations < ActiveRecord::Migration #分销商获利
  def change
    create_table "fx_transations" do |t|
      t.integer "trader_id" #分销订单id
      t.integer "user_id" #分销商id
      t.integer "dealer_level" #分销等级
      t.string "subject" #收入名称
      t.integer "amount", precision: 10, scale: 2, default: 0.0 #获利
      t.integer "balance", precision: 10, scale: 2, default: 0.0 #余额
      t.integer "sort" #0支出 1收入
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end