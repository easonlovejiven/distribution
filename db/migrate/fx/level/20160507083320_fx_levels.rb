class FxLevels < ActiveRecord::Migration
  def change
    create_table "fx_levels" do |t|
      t.string "name"  #级别名称
      t.string "label"  #标识
      t.integer "dealer1_percent",default: 0  #金牌会员消费(1级分销)
      t.integer "dealer2_percent" ,default: 0 #天使消费(2级分销)
      t.integer "dealer2_percent" ,default: 0 #天使消费(2级分销)
      t.integer "sort" ,default: 1 #级别等级
      t.boolean "active", default: true, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end