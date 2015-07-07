{ScrollView} = require 'atom-space-pen-views'

module.exports =
class LogView extends ScrollView
  @content: ->
    @div class: "log-view", =>
      @button "Close", click: 'close'
      @div class: "detail", overflow: "auto", outlet: "container"

  initialize: ->
    super

  open: ->
    atom.workspace.addBottomPanel(item: this) unless @hasParent()

  close: ->
    @detach()

  toggle: ->
    if @hasParent()
      @close()
    else
      @open()

  addLine: (line) ->
    @container.append "<p>#{line}</p>"
    @container.scrollTop 99999
