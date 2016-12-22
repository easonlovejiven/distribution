class CreateManageRoles < ActiveRecord::Migration
  def change
    create_table "manage_roles" do |t|
      t.integer "creator_id"
      t.string "name"
      t.text "description"
      t.datetime "destroyed_at"
      t.integer "updater_id"
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
