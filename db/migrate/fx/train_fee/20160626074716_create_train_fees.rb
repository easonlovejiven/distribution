class CreateTrainFees < ActiveRecord::Migration
  def change
    create_table :train_fees do |t| #培训费用
      t.integer :user_id    #讲师
      t.integer :payer_id    #支付人
      t.integer :amount,precision: 10, scale: 2, default: 0.0  #培训费
      t.integer :state ,default: 0
      t.timestamps null: false
    end
  end
end
