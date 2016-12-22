class CreateFxEmployees < ActiveRecord::Migration
  def change
    create_table :fx_employees do |t|
      t.string :name
      t.integer :role,default: 0
    end
  end
end
