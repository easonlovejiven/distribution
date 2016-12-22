class CreateManageEditors < ActiveRecord::Migration
  def change
    create_table "manage_editors" do |t|
      t.integer "creator_id"
      t.string "name"
      t.integer "role_id"
      t.integer "company_id"
      t.datetime "destroyed_at"
      t.string "identifier"
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "updater_id"
      t.integer "department_id"
      t.integer "supervisor_id"
      t.string "position"
      t.string "prefix"
    end
  end
end
