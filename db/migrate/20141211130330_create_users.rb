class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
    	t.string :name
    	t.string :phone_number
    	t.date :birthday
    	t.integer :token
    	t.integer :recommender

      t.timestamps
    end
  end
end
