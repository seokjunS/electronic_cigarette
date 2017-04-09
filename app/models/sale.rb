class Sale < ActiveRecord::Base
	enum category: [ :liquer, :nicotine, :machine ]

	attr_accessor :category_count

	belongs_to :user, inverse_of: :sales
	belongs_to :point

	before_create :record_date
	after_create :create_point
	after_destroy :destroy_points


	private
		def record_date
			self.date = Date.today
		end

		def create_point
			# give point to me
			# when buy a machine, no point
			unless self.category == 'machine'
				p = Point.new
				p.user_id = self.user_id
				p.sale_id = self.id
				p.category = self.category
				p.save
			

				# give point to recommender
				rec = User.find(self.user_id)
				unless rec.recommender.nil?
					p = Point.new
					p.user_id = rec.recommender
					p.sale_id = self.id
					p.category = self.category
					p.save
				end
				
			end
		end

		def destroy_points
			# delete all points where sale_id is my id
			# when a machine, no point to me
			points = Point.where(sale_id: self.id)

			points.each do |p|
				p.destroy
			end
		end
end
