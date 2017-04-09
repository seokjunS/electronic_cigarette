class User < ActiveRecord::Base
	has_many :sales, inverse_of: :user
	has_many :gifts, inverse_of: :user
	#has_many :valid_points, -> { where(dirty: false) }, class_name: 'Point'

	attr_accessor :phone_number_1, :phone_number_2, :phone_number_3

	validates :name, :phone_number, :token, presence: true
end