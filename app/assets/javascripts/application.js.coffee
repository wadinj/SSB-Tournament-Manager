# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
# vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file. JavaScript code in this file should be added after the last require_* statement.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require i18n/translations
#= require jquery
#= require jquery-ui/widget
#= require jquery-ui/widgets/sortable
#= require popper
#= require turbolinks
#= require bootstrap
#= require jquery.turbolinks
#= require bootstrap-sprockets
#= require jquery_ujs
#= require moment
#= require fullcalendar
#= require_tree .

document.addEventListener 'turbolinks:load', ->

  $('.sortable').sortable update: (e, ui) ->
    $.ajax
      method: 'patch'
      url: $(this).data('url')
      data: $(this).sortable('serialize')
      dataType: 'text'
      error: ->
        console.log("error: update sort_players ajax request")
      success: (response) ->
        # update seed
        $('.sortable tr').each( (i) ->
          $(this).find('td')[0].innerHTML = i+1
        )
    return

  # a click on a user discord icon copies it's discord username to the clipboard
  $('#copy_discord_name').on 'click', (e) ->
    event.preventDefault()
    discordUserName = $($(this).parent()[0]).attr('data-value')
    dummyTextArea = document.createElement("textarea")
    dummyTextArea.style.position = 'absolute'
    document.body.appendChild(dummyTextArea)
    if discordUserName[0] != '@'
      dummyTextArea.value = '@'
    dummyTextArea.value += discordUserName
    dummyTextArea.select()
    if document.execCommand("copy")
      alert(I18n.t('coffee.copied', {item: dummyTextArea.value}))
    else
      alert(I18n.t('coffee.not_copied', {item: discordUserName}))
    document.body.removeChild(dummyTextArea)

  # a click on a nav-link adds an anchor to the url and sets the page parameter to 1 if present and '/tournaments'
  $('.nav-link').on 'click', (e) ->
    window.history.replaceState(null, null, "#{$(this).attr('href')}")
    url = new URL(window.location.href)
    if url.href.includes('page') and url.searchParams.get('page') != 1 and url.href.includes('tournaments')
      url.searchParams.set('page', 1)
      window.location.href = url.href

  # get anchor from url and activate the correct nav-link
  anchor = window.location.href.split('#')[1]
  if anchor
    $('.nav-link.active').removeClass('active')
    $('.tab-pane.active').removeClass('active').removeClass('show')
    $("##{anchor}-tab").addClass('active')
    $("##{anchor}").addClass('active').addClass('show')
    $(window).scrollTop(0)  # workaround to prevent scroll from anchor tag

  # a click on a component-column links to its show
  $('tbody.with-show').on 'click', 'tr', (e) ->
    $et = $(e.target)
    unless $et.hasClass('admin-actions__link__icon') || $et.hasClass('btn-square') || $et.hasClass('paid-fee-checkbox') || $et.hasClass('game-stations-number-field')
      external_url = $(this).attr('data-external_url')
      if external_url
        window.open(external_url, '_blank')
      else
        id = $(this).attr('data-id')
        if id != undefined
          component = $(this).attr('data-component')
          window.location.href = "/#{component}s/#{id}"

  # a click on sort table header toggels its order param
  $('th a').on 'click', (e) ->
    wlhref = window.location.href
    if wlhref.includes('order=') && this.href.includes('order=')
      if wlhref.includes('order=asc')
        this.href = this.href.replace('order=asc', 'order=desc')
      else if wlhref.includes('order=desc')
        this.href = this.href.replace('order=desc', 'order=asc')

  $('.scroll-top').on 'click', (e) ->
    $('html, body').animate({
      scrollTop: 0
    }, 500)

  $('.toast').toast({delay: 10000}).toast('show')
