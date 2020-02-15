$(document).on('turbolinks:load', function() {
 	// Mobile Nav
 	$('a#mobile-nav').click(function(e) {
 	  e.preventDefault();
 	  $('.mobile-primary').toggleClass("open");
 	});

 	// Mobile Search Bar
 	$('.search-open').click(function(e) {
 	  e.preventDefault();
 	  if(
 	  	$('#mobile-search-overlay').css('height') === "0px"){
				$('#mobile-search-overlay').addClass("open");
			} else {
 	  		$('#mobile-search-overlay').removeClass("open");
 	  }
 	});

 	$('#search-close').click(function(e) {
 	  e.preventDefault();
 	  if(
 	  	$('#mobile-search-overlay').css('height') === "59px"){
				$('#mobile-search-overlay').removeClass("open");
		}
	});

	$('a#toggle-user').click(function(e) {
   e.preventDefault();
   	$('#user-container').toggleClass("open");
 	});

 	// Log-in Issues Menu
 	$('#login-issues').click(function(e) {
 		e.preventDefault();
 		$(this).css("display", "none");
 		$('#login-help').css("display", "block");
 	});

 	// Markdown Editor Upload Image Link
 	$('.mde-img a').click(function(e) {
		e.preventDefault();
		$(".mde-img input").trigger('click');
 	});

  // requires-agreement buttons and checkboxes
  $('.requires-agreement-checkbox').click(function(){
    let target_id = '#' + $(".requires-agreement-checkbox").data("target")
    if($(this).is(':checked')){
      $(target_id).attr('disabled', false)
    }
    else{
      $(target_id).attr('disabled', true)
    }
	})

	// validated fields
	$('form .validated-field').on('input paste', function() {
		const $field = $(this);
		const $form = $field.closest('form');
		const $fieldErrorMessage = $form.find('#' + $field.data('error-description-selector'))
		const $submit = $form.find('input[type=submit]');
		const fieldValue = $field.val();
		let valid = false;

		// validate changed field
		{
			switch($field.data('validation-type')) {
				case 'regex': {
					const regex = new RegExp($field.data('validation-regex-pattern'));
					valid = regex.test(fieldValue);
					break;
				}
			}
			$field.prop('validation-success', valid);
		}

		// show error message accordingly
		{
			if (valid) {
				$fieldErrorMessage.hide();
			} else {
				$fieldErrorMessage.show();
			}
		}

		// enable submit button accordingly
		{
			const allFieldsValid = $form.find('.validated-field').map(function() {
				return $(this).prop('validation-success');
			}).get().reduce((acc,x) => acc && x, true);

			if (allFieldsValid) {
				$submit.removeAttr('disabled')
			} else {
				$submit.attr('disabled', 'disabled')
			}
		}
	});
});
