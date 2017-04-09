class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
    	t.integer :category
    	t.integer :user_id
    	t.date :date

      t.timestamps
    end
  end
end
