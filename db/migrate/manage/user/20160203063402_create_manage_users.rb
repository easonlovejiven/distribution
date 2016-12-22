class CreateManageUsers < ActiveRecord::Migration
  def change
    create_table "manage_users" do |t|
      t.string "pic"
      t.string "name"
      t.string "gender"
      t.date "birthday"
      t.datetime "login_at"
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "manage_users", ["birthday"], name: "index_manage_users_on_birthday", using: :btree
    add_index "manage_users", ["created_at"], name: "index_manage_users_on_created_at", using: :btree
    add_index "manage_users", ["id"], name: "index_manage_users_on_id", using: :btree
    add_index "manage_users", ["login_at"], name: "index_manage_users_on_login_at", using: :btree
    add_index "manage_users", ["updated_at"], name: "index_manage_users_on_updated_at", using: :btree
  end
end
