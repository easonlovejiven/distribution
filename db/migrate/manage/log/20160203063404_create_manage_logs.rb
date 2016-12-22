class CreateManageLogs < ActiveRecord::Migration
  def change
    create_table "manage_logs" do |t|
      t.integer "user_id"
      t.integer "controller"
      t.integer "action"
      t.integer "params_id"
      t.datetime "created_at"
    end
  end
end
