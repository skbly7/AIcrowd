$(document).on('turbolinks:load', function() {
  $('.modal[role=dialog]').on('shown.bs.modal', function() {
    $('[data-auto-focus=true]').focus();
  })
});
