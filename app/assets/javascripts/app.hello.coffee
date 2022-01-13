class App.Hello
  constructor: (@el) ->
# intialize some stuff

  render: ->
    today = new Date
    $("body").append("<p/>")
    $("body p").text("App.Hello JavaScript")

$(document).on "page:change", ->
  return unless $(".hello.index").length > 0
  hello = new App.Hello $("#body")
  hello.render()
