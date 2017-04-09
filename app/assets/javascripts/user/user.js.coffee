# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = this

jQuery ->
	$(document).on "ready", ->
		if $('#layout-user-index').length
			root.UserIndex()
		else if $('#layout-user-new').length or $('#layout-user-edit').length
			root.UserNew()
		else if $('#layout-user-show').length
			root.UserShow()
			