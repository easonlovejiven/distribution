class FxSettings < ActiveRecord::Migration
  def change
    create_table "fx_settings"  do |t|
      t.string "key"#配置名称
      t.text "value"#配置值
    end
  end
end
