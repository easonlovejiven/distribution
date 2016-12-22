class CreateAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.integer :target_id
      t.string :target_type
      t.string :file #文件url
      t.string :desc
      t.string :key #名称
      t.integer :is_default, default: 0 #是否默认图
      t.string :sort #图片类型
      t.string :img #编辑后的图片
      t.timestamps null: false
    end
  end
end
