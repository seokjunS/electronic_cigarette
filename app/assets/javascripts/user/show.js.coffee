root = this

jQuery ->
	root.UserShow = () ->
		$('.toggling-panel').on "click", "a", () ->
			$(this).siblings().removeClass('hidden')
			$(this).addClass('hidden')

		$('.toggling-panel').on "click", "a[data-method='delete']", () ->
			res = confirm("정말 삭제 하시겠습니까?")

			if res
				return true
			else
				return false

	root.gift_function = (iUrl) ->
		res = confirm("정말 수령 하시겠습니까?")

		if res
			window.location.href = iUrl
			return true
		else
			return false