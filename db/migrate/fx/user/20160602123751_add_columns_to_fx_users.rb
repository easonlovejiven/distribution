class AddColumnsToFxUsers < ActiveRecord::Migration
  def change
    add_column :fx_users, "rank", :integer,default: 10000
    add_column :fx_users, "province_rank", :integer,default: 10000
    add_column :fx_users, "province_id", :integer
  end
end
