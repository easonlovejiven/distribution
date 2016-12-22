class CreateFxUpgrades < ActiveRecord::Migration
  def change
    create_table :fx_upgrades do |t|
      t.integer :level_id #所属级别id
      t.integer :month,default: 1  #计算月份
      t.integer :count,default: 1 #下线人数
      t.integer :amount,precision: 10, scale: 2, default: 0.0 #销售总金额
    end
  end
end
