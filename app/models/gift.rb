class Gift < ActiveRecord::Base
	enum category: [ :liquer, :nicotine, :machine ]

	attr_accessor :category_count
	
	belongs_to :user, inverse_of: :gifts
	belongs_to :point

	before_create :record_date
	after_create :create_point
	after_update :update_point


	private
		def record_date
			self.date = Date.today
		end

		def create_point
			unless self.category == 'machine'
				# give point to recommender
				rec = User.find(self.user_id)

				unless rec.recommender.nil?
					p = Point.new
					p.user_id = rec.recommender
					p.gift_id = self.id
					p.category = self.category
					p.save
				end
			end
		end

		def update_point
		end
end
