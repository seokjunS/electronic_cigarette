root = this

jQuery ->
	$(document).on "page:change", ->
		if $('#layout-user-index').length
			$('#navbar li').removeClass('active')
			$('#navbar-index').addClass('active')
		else if $('#layout-user-new').length
			$('#navbar li').removeClass('active')
			$('#navbar-new').addClass('active')
		else if $('#layout-user-show-all').length
			$('#navbar li').removeClass('active')
			$('#navbar-show').addClass('active')
		else if $('#layout-user-settings').length
			$('#navbar li').removeClass('active')
			$('#navbar-settings').addClass('active')

		$('.navbar input.form-control').val('')