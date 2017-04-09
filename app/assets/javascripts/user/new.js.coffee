root = this

jQuery ->
	root.UserNew = () ->
		### form checker ###
		$('form').submit (event) ->
			phone_rgx = new RegExp("^[0-9]{3,4}$")

			flag = false

			$(this).find("input[data-type='phone_number']").each () ->
				unless phone_rgx.test($(this).val())
					alert($("label[for=user_phone_number]").text() + "가 올바르지 않습니다.")
					flag = true
			
			if flag
				return false
			else
				return

		### click event handler ###
		$('#new-search-user').on "click", ->
			$.ajax '/user/find_user',
				type: 'POST'
				data: { name: $('#new-recommender-name').val(), token: $('#new-recommender-token').val() }
				beforeSend: ->
					$('i[data-toggle=true]').toggle()
					$('#new-result-panel').html("")
					$('#user_recommender').val("")
				error: (jqXHR, textStatus, errorThrown) ->
					$('i[data-toggle=true]').toggle()
					$('#new-result-panel').append("<a class='list-group-item list-group-item-danger'>예기치 않은 에러 발생. 다시 시도 해 주십시오.</a>")
				success: (data, textStatus, jqXHR) ->
					$('i[data-toggle=true]').toggle()

					if data.length is 0
						$('#new-result-panel').append("<a class='list-group-item list-group-item-danger'>해당 고객이 존재하지 않습니다.</a>")
					else

					data.forEach (elem, idx, arr) ->
						$('#new-result-panel').append("
							<a class='list-group-item' data-id='#{elem.id}'>
							이름: <strong>#{elem.name}</strong> &nbsp;&nbsp;
							전화번호: <strong>#{elem.phone_number}</strong> &nbsp;&nbsp;
							생년월일: <strong>#{elem.birthday}</strong></a>
							")
					return
			return false

		$('#new-result-panel').on "click", "a", () ->
			recommenderId =  $(this).attr('data-id')
			
			if recommenderId is undefined
				$('#user_recommender').val("")
			else
				$('#user_recommender').val( recommenderId )
				$(this).siblings().removeClass('list-group-item-success')
				$(this).addClass('list-group-item-success')

		$('#edit-reset-recommender').on "click", ->
			$('#user_recommender').val("")
			$('#new-recommender-name').val("")
			$('#new-recommender-token').val("")
			return false
				

