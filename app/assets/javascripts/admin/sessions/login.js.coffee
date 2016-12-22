$ ->
$('#new_session_form, #ldap_form').on 'submit', ->
  $.ajax
    url: $(this).attr('action') + '.json'
    type: 'post'
    data: $(this).serialize()
    dataType: 'json'
    success: (data) ->
      if data['error']
        $('#login_error').show()
        return
      $('#login_error').hide()
      $.cookie 'remember_me', '1',
        expires: if $('#rememberme').prop('checked') then 90 else null
        path: '/'
      window.location.href = $('#redirect').val()
    error: ->
    $('#login_error').show()
  false
$('#new_account_form').on 'submit', ->
  $.ajax
    url: $(this).attr('action') + '.json'
    type: 'post'
    data: $(this).serialize()
    dataType: 'json'
    success: (data) ->
      if data['error']
        $('#login_error').show()
        return
      location.href = $('#redirect').val()
    error: ->
      $('#login_error').show()
  false
$('#session_link').on 'click', ->
  $('#account_area, #login_error').hide()
  $('#session_area').show()
  false
$('#account_link').on 'click', ->
  $('#session_area, #login_error').hide()
  $('#account_area').show()
  false
$('#ldap_login').on 'click', ->
  $('#ldap_area').show();
  $('#session_area').hide();
  false
$('#original_login').on 'click', ->
  $('#session_area').show();
  $('#ldap_area').hide();
  false
