class Setting < ActiveRecord::Base
	validates :liquer_threshold, :nicotine_threshold, :machine_threshold, presence: true
	validates :liquer_threshold, :nicotine_threshold, :machine_threshold, numericality: { :greater_than => 0 }

end
