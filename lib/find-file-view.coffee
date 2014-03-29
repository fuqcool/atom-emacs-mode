fs = require 'fs'
path = require 'path'
{SelectListView} = require 'atom'

module.exports =
  class FileFinderView extends SelectListView
    initialize: ->
      super
      @addClass('overlay from-top')

      editor = atom.workspace.getActiveEditor()
      if editor
        uri = path.dirname editor.getUri()
        @pwd = uri if uri? and uri isnt '.'

      @pwd ?= process.env.HOME

      @subscribe @filterEditorView.getEditor().getBuffer(), 'changed', =>
        @setItems @renderItems()
        @populateList()

      @filterEditorView.setText(@pwd)
      atom.workspaceView.appendToBottom(this)
      @focusFilterEditor()

    viewForItem: (item) ->
      """
      <li>#{item.uri}</li>
      """

    listDir: (dir) ->
      try
        (path.join dir, f for f in fs.readdirSync dir)
      catch
        []

    renderItems: () ->
      dir = @filterEditorView.getText()
      return [] if dir is ''

      files = []

      try
        stats = fs.statSync dir

        if stats.isDirectory()
          files = files.concat @listDir(dir)
      catch
      finally
        parent = path.dirname(dir)
        files = files.concat @listDir(parent)

      (uri: f for f in files)

    getFilterKey: -> 'uri'

    confirmed: (item) ->
      fs.stat item.uri, (err, stats) =>
        atom.workspace.open(item.uri) if stats.isFile()
        if stats.isDirectory()
          @filterEditorView.setText(item.uri)
