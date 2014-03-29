{SelectListView} = require 'atom'

module.exports =
  class SwitchBufferView extends SelectListView
    initialize: ->
      super
      @addClass('overlay from-top')
      editors = atom.workspace.getActivePane().getItems()
      titles = (title: editor.getTitle(), uri: editor.getUri() || '' for editor in editors)

      @setItems(titles)
      atom.workspaceView.appendToBottom(this)
      @focusFilterEditor()

    getFilterKey: ->
      return 'title'

    viewForItem: (item) ->
      """
      <li>
        <div>#{item.title}</div>
        <div>#{item.uri}</div>
      </li>
      """

    confirmed: (item) ->
      console.log("#{item.title} was selected")
      atom.workspace.getActivePane().activateItemForUri(item.uri)
      @cancel()
