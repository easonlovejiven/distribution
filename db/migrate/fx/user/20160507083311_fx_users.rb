class FxUsers < ActiveRecord::Migration
  def change
    create_table "fx_users" do |t|
      t.string "account"  #core user id
      t.integer "level_id"  #合伙人级别（1： 普通2、终身3、地区4、省级、大区事业）
      t.integer "city_id"  #城市id
      t.integer "total_amount",precision: 10, scale: 2, default: 0.0  #总获利
      t.integer "balance",precision: 10, scale: 2, default: 0.0  #分销余额
      t.string "invitation"  #邀请码
      t.integer "is_remove_relation",default: false #当前分销关系是否解除
      t.integer "cost_amount",precision: 10, scale: 2, default: 0.0  #个人消费
      t.boolean "active", default: true, null: false
      t.integer "state", default: 0 #(0：待审核 1：通过2,： 审核中，1： 回退)
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end