fs = require 'fs'
path = require 'path'
{SelectListView} = require 'atom'

module.exports =
  class FileFinderView extends SelectListView
    initialize: ->
      super
      @addClass 'overlay from-top'

      pwd = path.join '~', path.sep
      editor = atom.workspace.getActiveEditor()

      if editor
        uri = path.dirname editor.getUri()
        pwd = uri if uri? and uri isnt '.'

      pwd = @ensureTailSep pwd
      pwd = @toHome pwd

      # re-render list whenever buffer is changed
      @subscribe @filterEditorView.getEditor().getBuffer(), 'changed', =>
        @setItems @renderItems()
        @populateList()

      # use current directory as default
      @filterEditorView.setText pwd
      atom.workspaceView.appendToBottom this

      @focusFilterEditor()
      @disableTab()

    viewForItem: (item) ->
      try
        uri = @resolveHome item.uri
        stat = fs.statSync uri

        if stat.isFile()
          iconClass = 'icon-file-text'
        else if stat.isDirectory()
          iconClass = 'icon-file-directory'
      catch
        iconClass = 'icon-file-text'

      """
      <li><span class="icon #{iconClass}">#{item.name}</span></li>
      """

    listDir: (dir) ->
      result = []

      try
        files = fs.readdirSync @resolveHome(dir)

        for f in files
          result.push(uri: path.join(dir, f), name: f)
      catch e
        console.warn "Unable to read directory #{dir}, #{e.message}"

      result

    renderItems: ->
      filePath = @filterEditorView.getText().trim()
      return [] if filePath is ''

      files = []

      if @endWithSep filePath
        files = files.concat @listDir(filePath)

        if fs.existsSync @resolveHome(filePath)
          files.unshift
            name: "Open #{path.basename(filePath)} in new window"
            uri: filePath
            open: true
      else
        parentPath = @getParentPath filePath
        files = files.concat @listDir(parentPath)

        unless fs.existsSync @resolveHome(filePath)
          files.unshift
            name: "Create #{path.basename(filePath)}"
            uri: filePath

      files

    getParentPath: (filePath) ->
      if filePath is '~'
        filePath = process.env.HOME

      path.dirname filePath

    getFilterKey: -> 'uri'

    resolveHome: (filePath) ->
      if filePath[0] is '~'
        process.env.HOME + filePath.substring(1)
      else
        filePath

    toHome: (filePath) ->
      if filePath.indexOf(process.env.HOME) is 0
        filePath.replace process.env.HOME, '~'
      else
        filePath

    confirmed: (item) ->
      filePath = @resolveHome item.uri

      fs.stat filePath, (err, stats) =>
        if err? or stats.isFile()
          atom.workspace.open filePath
        else if stats.isDirectory()
          if item.open? and item.open
            atom.open(pathsToOpen: [filePath])
          else
            @filterEditorView.getEditor().setText(@ensureTailSep item.uri)

    endWithSep: (filePath) ->
      filePath[filePath.length - 1] is path.sep

    ensureTailSep: (f) ->
      if @endWithSep f then f else f + path.sep

    disableTab: ->
      @filterEditorView.on 'keydown', (evt) ->
        if evt.which is 9
          evt.stopPropagation()
          evt.preventDefault()
