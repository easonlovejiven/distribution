class FxInvites < ActiveRecord::Migration
  def change
    create_table :fx_invites do |t|
      t.integer :user_id    #发起邀请人
      t.integer :used ,default: 0
      t.integer :used_by    #被邀请人
      t.timestamps null: false
    end
  end
end
