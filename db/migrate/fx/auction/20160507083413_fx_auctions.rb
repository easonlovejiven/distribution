class FxAuctions < ActiveRecord::Migration
  def change
    create_table "fx_auctions" do |t|
      t.datetime "started_at"  #设置时间
      t.datetime "ended_at"#结束时间
      t.integer "user_limit" #限制人数
      t.integer "more_limit" #限制可抢最多人数
      t.string "audtion_level" #让谁来抢人	1:天使会员，2：合伙人（逗号分隔）
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
