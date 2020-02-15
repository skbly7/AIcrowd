// You will need to require 'jquery-ui' for this to work
window.ClientSideValidations.callbacks.element.fail = function(element, message, callback) {
  callback();
  if (!element.is('.form-check-input')){
    element.removeClass("is-valid");
    element.addClass("is-invalid");
  }
  if (element.data('valid') !== false) {
    element.parent().find('.message').hide().show('slide', {direction: "left", easing: "easeOutBounce"}, 500);
  }
}

window.ClientSideValidations.callbacks.element.pass = function(element, callback) {
  // Take note how we're passing the callback to the hide()
  // method so it is run after the animation is complete.
  if (!element.is('.form-check-input')){
    element.removeClass("is-invalid");
    element.addClass("is-valid");
  }
  element.parent().find('.message').hide('slide', {direction: "left"}, 500, callback);
}
