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
      @pwd = @appendSlash @pwd

      @subscribe @filterEditorView.getEditor().getBuffer(), 'changed', =>
        @setItems @renderItems()
        @populateList()

      @filterEditorView.setText(@pwd)
      atom.workspaceView.appendToBottom(this)
      @focusFilterEditor()

    viewForItem: (item) ->
      """
      <li>#{item.name}</li>
      """

    listDir: (dir) ->
      try
        files = (path.join dir, f for f in fs.readdirSync dir)
        (uri: f, name: f for f in files)
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
          files.unshift(name: "Open #{dir} in new window", uri: dir, open: true)
      catch
        files.push(uri: dir, name: "Create #{dir}")
      finally
        parent = path.dirname(dir)
        files = files.concat @listDir(parent)

      files

    getFilterKey: -> 'uri'

    confirmed: (item) ->
      fs.stat item.uri, (err, stats) =>
        if err? or stats.isFile()
          atom.workspace.open(item.uri)
        else if stats.isDirectory()
          if item.open? and item.open
            atom.open(pathsToOpen: [item.uri])
          else
            @filterEditorView.setText(item.uri)

    appendSlash: (f) ->
      if f and f[f.length - 1] isnt '/'
        return f + '/'
      else
        return f
