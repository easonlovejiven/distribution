class CreateManageNotifications < ActiveRecord::Migration
  def change
    create_table "manage_notifications" do |t|
      t.integer "app_id"
      t.integer "user_id"
      t.integer "receiver_id"
      t.text "content"
      t.boolean "unread", default: true
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
