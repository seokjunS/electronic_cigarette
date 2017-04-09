class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
    	t.integer :user_id
    	t.integer :sale_id
    	t.integer :gift_id
    	t.integer :category
    	t.boolean :dirty, :default => false

      t.timestamps
    end
  end
end
