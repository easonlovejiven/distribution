class FxInfos < ActiveRecord::Migration
  def change
    create_table "fx_infos" do |t|
      t.integer "user_id" #用户id
      t.decimal "amount",precision: 10, scale: 2, default: 0.0  #自己分销获利
      t.decimal "amount1",precision: 10, scale: 2, default: 0.0 #一级分销获利
      t.decimal "amount2",precision: 10, scale: 2, default: 0.0  #二级分销获利
      t.decimal "amount3",precision: 10, scale: 2, default: 0.0  #三级分销获利
      t.decimal "last_month_amount",precision: 10, scale: 2, default: 0.0  #上月获利统计
      t.decimal "current_month_amount",precision: 10, scale: 2, default: 0.0  #本月获利统计
      t.integer "dealer1_count",default: 0  #一级分销数量
      t.integer "dealer2_count",default: 0  #二级分销数量
      t.integer "dealer3_count",default: 0  #三级分销数量
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
