{SelectListView} = require 'atom'


class SwitchBufferView extends SelectListView
  initialize: ->
    super

    @addClass 'overlay from-top'
    editors = atom.workspace.getActivePane().getItems()
    items = (title: editor.getTitle(), uri: editor.getUri() || '' for editor in editors)
    items = @sortItems items

    @setItems items
    atom.workspaceView.appendToBottom this
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

    SwitchBufferView.lastItemUri = atom.workspace.getActiveEditor().getUri()
    atom.workspace.getActivePane().activateItemForUri(item.uri)
    @cancel()

  sortItems: (items) ->
    return items if not SwitchBufferView.lastItemUri?

    target = null
    newItems = []

    for item in items
      if item.uri is SwitchBufferView.lastItemUri
        target = item
      else
        newItems.push item

    newItems.unshift target if target?
    newItems

SwitchBufferView.lastItemUri = null

module.exports = SwitchBufferView
