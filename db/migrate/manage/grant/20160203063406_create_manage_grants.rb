class CreateManageGrants < ActiveRecord::Migration
  def change
    create_table "manage_grants" do |t|
      t.integer "editor_id"
      t.integer "role_id"
      t.integer "updater_id"
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "creator_id"
    end

    add_index "manage_grants", ["active", "editor_id", "role_id"], name: "by_active_and_editor_id_and_role_id", using: :btree
  end
end
