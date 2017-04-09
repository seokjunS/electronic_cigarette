class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
    	t.integer :liquer_threshold
    	t.integer :nicotine_threshold
    	t.integer :machine_threshold

      t.timestamps
    end
  end
end
