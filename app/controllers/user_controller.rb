class UserController < ApplicationController
	USER, PASSWORD = 'gmlcksdlrkrp', 'p/01091970367'

	before_filter :authentication_check

	def index
		# sales in 7 days
		sales = Sale.select("category, date, count(category) as category_count")
			.where("date >= :start_date AND date <= :end_date", {start_date: Date.today - 6, end_date: Date.today})
			.group("date, category")
 
		count = 0
		@current_sales = {}
		begin
			@current_sales[(Date.today - count).to_s] = {"date" => (Date.today - count).to_s}
			count += 1
		end while count < 7

		sales.each do |sale|
			@current_sales[sale.date.to_s][sale.category] = sale[:category_count]
		end

		# giftss in 7 days
		gifts = Gift.select("category, date, count(category) as category_count")
			.where("date >= :start_date AND date <= :end_date", {start_date: Date.today - 6, end_date: Date.today})
			.group("date, category")

		count = 0
		@current_gifts = {}
		begin
			@current_gifts[(Date.today - count).to_s] = {"date" => (Date.today - count).to_s}
			count += 1
		end while count < 7

		gifts.each do |gift|
			@current_gifts[gift.date.to_s][gift.category] = gift[:category_count]
		end

		@today_sales = Sale.where("date = ?", Date.today)
		@today_gifts = Gift.where("date = ?", Date.today)
		@category_hash = {
			'liquer' => '액상',
			'nicotine' => '니코틴',
			'machine' => '기계'
		}
	end

	def new
	end

	def edit
		@user = User.find(params[:id])
		pn = @user.phone_number.split('-')

		@user.phone_number_1 = pn[0]
		@user.phone_number_2 = pn[1]
		@user.phone_number_3 = pn[2]

		@recommender = User.select(:id, :name, :token).where('id = ?', @user.recommender).first
	end

	def update
		user = User.find(params[:id])
		user.name = params[:user][:name]
		user.phone_number = user.phone_number = params[:user][:phone_number_1] + "-" + params[:user][:phone_number_2] + "-" + params[:user][:phone_number_3]
		user.token = params[:user][:phone_number_3]

		unless params[:user][:recommender] == ""
			user.recommender = params[:user][:recommender]
		else
			user.recommender = nil
		end

		unless user.save
			redirect_to :back, :flash => { :type => "danger", :header => "고객 수정 실패", :message => "잘못된 입력이 존재합니다." }
		else 
			redirect_to user
		end
	end

	def create
		user = User.new

		user.name = params[:user][:name]
		user.phone_number = params[:user][:phone_number_1] + "-" + params[:user][:phone_number_2] + "-" + params[:user][:phone_number_3]
		user.token = params[:user][:phone_number_3]
		unless params[:user][:recommender] == ""
			user.recommender = params[:user][:recommender]
		end
		
		unless user.save
			redirect_to :back, :flash => { :type => "danger", :header => "고객 등록 실패", :message => "잘못된 입력이 존재합니다." }
		else 
			redirect_to user
		end
	end

	def search
		users = nil

		if params[:user][:name] == "" && params[:user][:token] == ""
			users = []
		elsif params[:user][:name] == ""
			users = User.where("token = ?", params[:user][:token]).pluck(:id)
		elsif params[:user][:token] == ""
			users = User.where("name = ?", params[:user][:name]).pluck(:id)
		else
			users = User.where("name = ? AND token = ?", params[:user][:name], params[:user][:token]).pluck(:id)
		end

		if users.length == 0
			# no result
			redirect_to :back, :flash => { :type => "danger", :header => "검색 실패", :message => "해당 고객이 존재하지 않습니다." }
		elsif users.length == 1
			redirect_to :action => 'show', :id => users.first
		else
			redirect_to :action => 'user_select', :id => users
		end
	end

	def user_select
		ids = params[:id].split('/')
		@users = User.find(ids)
	end

	def show
		if params[:id].nil?
			@user = nil
			@children = nil
		else
			@setting = Setting.first
			@user = User.find(params[:id])
			@recommender = if @user.recommender.nil? then nil else User.find(@user.recommender) end
			# @valid_points_by_categories = Point.where("dirty = ? AND user_id = ?", false, params[:id]).select("category, count(category) as category_count").group(:category)	
			# without machine_count
			@valid_points_by_categories = Point.where("dirty = ? AND user_id = ? AND category != ?", false, params[:id], 2).select("category, count(category) as category_count").group(:category)

			@gift = categorize( Gift.where('user_id = ?', params[:id]).order("date DESC, created_at DESC").limit(50) )
			@sale = categorize( Sale.where('user_id = ?', params[:id]).order("date DESC, created_at DESC").limit(50) )

			point_join_table = Point.joins('LEFT OUTER JOIN sales ON sales.id = points.sale_id').joins('LEFT OUTER JOIN gifts ON gifts.id = points.gift_id')
			@children = User.where("recommender = ?", params[:id]).map { |c| {'id' => c.id, 'name' => c.name} }
			@total_history = {}
			@total_history[@user.id] = {'user' => @user, 'data' => []}

			# points.user_id = me => my points
			# type id = 0 => gift
			history = point_join_table.select("CASE WHEN points.sale_id IS NULL THEN 'gift' ELSE 'sale' END AS type, IFNULL(sales.date, gifts.date) AS date, IFNULL(sales.category, gifts.category) AS category, sale_id, gift_id")
																.where('points.dirty = ? AND points.user_id = ?', false, params[:id]).order('date DESC')
			
			@children.each do |child|
				tmp_id = child['id']
				@total_history[tmp_id] = {'user' => child, 'data' => []}
			end

			history.each do |h|
				if h['type'] == 'sale'
					tmp_id = Sale.where('id = ?', h.sale_id).pluck(:user_id).first
					unless @total_history[tmp_id].nil?
						@total_history[tmp_id]['data'].push h
					else
						user = User.find(tmp_id)
						obj = {'id' => tmp_id, 'name' => user.name }
						@children.push obj
						@total_history[tmp_id] = {'user' => user, 'data' => [h] }
					end
				else
					tmp_id = Gift.where('id = ?', h.gift_id).pluck(:user_id).first
					unless @total_history[tmp_id].nil?
						@total_history[tmp_id]['data'].push h
					else
						user = User.find(tmp_id)
						obj = {'id' => tmp_id, 'name' => user.name }
						@children.push obj
						@total_history[tmp_id] = {'user' => user, 'data' => [h] }
					end
				end				
			end

			tmp_idx = @children
			tmp_obj = {'id' => @user.id, 'name' => @user.name}
			tmp_idx.push tmp_obj

			tmp_idx.each do |i|
				id = i['id']
				@total_history[id]['data'] = categorize_without_machine( @total_history[id]['data'] )
			end
			tmp_idx.pop

			#render plain: @total_history.inspect
		end
	end

	def sale
		sale = Sale.new
		sale.user_id = params[:user_id]
		sale.category = params[:category]

		case params[:category]
		when 'liquer'
			category = '액상'
		when 'nicotine'
			category = '니코틴'
		when 'machine'
			category = '기계'
		end

		unless sale.save
			redirect_to :back, :flash => { :type => "danger", :header => "구매 실패", :message => "잘못된 접근입니다." }
		else
			redirect_to user_path(:id => params[:user_id]), :flash => { :type => "success", :header => "구매 성공", :message => "#{category} 구매에 성공하였습니다." }
		end
	end

	def gift
		gift = Gift.new
		gift.user_id = params[:user_id]
		gift.category = params[:category]
		setting = Setting.first

		threshold = -1
		category = -1
		
		if params[:category] == "liquer"
			threshold = setting.liquer_threshold
			category = 0
			category_name = '액상'
		elsif params[:category] == "nicotine"
			threshold = setting.nicotine_threshold
			category = 1
			category_name = '니코틴'
		else
			threshold = setting.machine_threshold
			category = 2
			category_name = '기계'
		end

		valid_points = Point.where("dirty = ? AND user_id = ? AND category = ?", false, gift.user_id, category)
												.order(created_at: :asc).limit(threshold)

		
		if valid_points.count < threshold or not gift.save
			redirect_to :back, :flash => { :type => "danger", :header => "증정 실패", :message => "잘못된 접근입니다." }
		else
			valid_points.each do |p|
				p.update(dirty: true)
			end
			redirect_to user_path(:id => params[:user_id]), :flash => { :type => "success", :header => "증정 성공", :message => "#{category_name} 증정에 성공하였습니다." }
		end
	end

	def find_user
		users = nil

		if params[:name] == "" && params[:token] == ""
			users = []
		elsif params[:name] == ""
			users = User.where("token = ?", params[:token])
		elsif params[:token] == ""
			users = User.where("name = ?", params[:name])
		else
			users = User.where("name = ? AND token = ?", params[:name], params[:token])
		end

		respond_to do |format|
			format.json { render :json => users }
		end
	end

	def show_all
		@offset = params[:offset].to_i
		count = 100
		inline = 10
		page_num_max = (User.count / count.to_f).ceil - 1

		@offset_from = @offset
		@offset_from = (@offset_from / inline) * inline

		if @offset_from <= 0
			@offset_from = 0
		elsif @offset_from > page_num_max
			@offset_from = page_num_max - (inline - 1)
		end

		@offset_to = @offset_from + inline - 1

		if @offset_to > page_num_max
			@offset_to = page_num_max
		end

		if @offset < @offset_from
			@offset = @offset_from
		elsif @offset > @offset_to
			@offset = @offset_to
		end

		# 0, count - 1, 2count - 1,...
		@users = User.limit(count).offset(@offset * count)
	end

	def delete_sale
		sale = Sale.find(params[:id])
		sale.destroy

		redirect_to :back, :flash => { :type => "success", :header => "판매 취소", :message => "판매 취소에 성공하였습니다." }
	end

	def settings
		@settings = Setting.first
	end

	def update_settings
		settings = Setting.first

		settings.liquer_threshold = params[:settings][:liquer_threshold]
		settings.nicotine_threshold = params[:settings][:nicotine_threshold]
		settings.machine_threshold = params[:settings][:machine_threshold]


		if settings.save
	    redirect_to :back, :flash => { :type => "success", :header => "설정 변경 성공", :message => "설정 변경에 성공하였습니다." }
	  else
	    redirect_to :back, :flash => { :type => "danger", :header => "설정 변경 실패", :message => "잘못된 설정입니다." }
	  end
	end

	private
		def categorize(query)
			res = [[],[],[]]
			query.each do |q|
				case q.category
				when 'liquer'
					res[0].push q
				when 'nicotine'
					res[1].push q
				when 'machine'
					res[2].push q
				end
			end

			return res
		end

		def categorize_without_machine(query)
			res = [ [], [] ]
			query.each do |q|
				case q.category
				when 'liquer'
					res[0].push q
				when 'nicotine'
					res[1].push q
				end
			end

			return res
		end

		def authentication_check
	   authenticate_or_request_with_http_basic do |user, password|
	    user == USER && password == PASSWORD
	   end
	  end
end

