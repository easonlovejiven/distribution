class AddQrodeToFxUsers < ActiveRecord::Migration
  def change
    add_column :fx_users,"qrcode_pic",:string
  end
end
