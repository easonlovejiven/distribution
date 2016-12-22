class AddUpgrateStateToFxUsers < ActiveRecord::Migration
  def change
    add_column  "fx_users","upgrade_state",:integer, default: 0  #升级状态
  end
end
