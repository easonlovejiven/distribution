class FxAuctionRecords < ActiveRecord::Migration
  def change
    create_table "fx_auction_records" do |t|
      t.integer "user_id"  #抢人者
      t.datetime "dealer_id"#被抢者
      t.boolean "active", default: true, null: false
      t.integer "lock_version", default: 0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end