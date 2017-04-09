class Point < ActiveRecord::Base
	enum category: [ :liquer, :nicotine, :machine ]
	
	attr_accessor :category_count, :date, :type
			
	belongs_to :user
	has_many :sale
	has_many :gift
end