class AddDealerCountToInfos < ActiveRecord::Migration
  def change
    add_column :fx_infos,:dealer_count,:integer,default: 0
  end
end
