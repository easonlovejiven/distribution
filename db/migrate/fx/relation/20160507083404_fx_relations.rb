class FxRelations < ActiveRecord::Migration
  def change
    create_table "fx_relations"  do |t|
      t.integer "user_id"  #所属用户id
      t.integer "old_user_id"#旧用户id
      t.integer "dealer_id" #分销商id
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.integer :lft
      t.integer :rgt
      t.integer :dealers_count , default: 0
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
