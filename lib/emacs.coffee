{Range, Point} = require 'atom'
SwitchBufferView = require './switch-buffer-view'
FindFileView = require './find-file-view.coffee'
EmacsMark = require './mark'
killRing = require './kill-ring'

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'emacs:find-file', => @findFile()
    atom.workspaceView.command 'emacs:hide-tabs', (event, value) => @hideTabs value
    atom.workspaceView.command 'emacs:hide-sidebar', (event, value) => @hideSidebar value
    atom.workspaceView.command 'emacs:use-emacs-cursor', (event, value) => @useEmacsCursor value
    atom.workspaceView.command 'emacs:use-fuzzy-file-finder', (event, value) => @useFuzzyFileFinder = value
    atom.workspaceView.command 'emacs:use-fuzzy-buffer-finder', (event, value) => @useFuzzyBufferFinder = value

    require './config'

    atom.workspaceView.eachEditorView (editorView) =>
      new EmacsMark(editorView)

      editorView.command 'emacs:switch-buffer', => @switchBuffer()
      editorView.command 'emacs:open-line', => @openLine editorView
      editorView.command 'emacs:forward-word', => @forwardWord editorView
      editorView.command 'emacs:backward-word', => @backwardWord editorView
      editorView.command 'emacs:recenter', => @recenter editorView
      editorView.command 'emacs:clear-selection', => @clearSelection editorView

      editorView.on 'core:cancel', => editorView.trigger 'emacs:clear-selection'

      @enableKillRing editorView

    atom.workspaceView.on 'editor:attached', (evt) =>
      @enableKillRing evt.targetView()

  deactivate: ->

  serialize: ->

  switchBuffer: ->
    if @useFuzzyBufferFinder
      atom.workspaceView.trigger 'fuzzy-finder:toggle-buffer-finder'
    else
      new SwitchBufferView()

  findFile: ->
    if @useFuzzyFileFinder
      atom.workspaceView.trigger 'fuzzy-finder:toggle-file-finder'
    else
      new FindFileView()

  openLine: (editorView) ->
    editor = editorView.getEditor()
    pos = editor.getCursorBufferPosition()
    editor.insertNewline()
    editor.setCursorBufferPosition pos

  clearSelection: (editorView) ->
    editor = editorView.getEditor()
    sel.clear() for sel in editor.getSelections()

  _getChar: (editor, row, col) ->
    editor.getTextInBufferRange(new Range(new Point(row, col), new Point(row, col + 1)))

  forwardWord: (editorView) ->
    editor = editorView.getEditor()
    cursors = editor.getCursors()
    for cursor in cursors
      while true
        before = cursor.getBufferPosition()
        cursor.moveToEndOfWord()
        pos = cursor.getBufferPosition()

        break if before.isEqual pos
        break if @_getChar(editor, pos.row, pos.column - 1).match /[0-9a-zA-Z]/

  backwardWord: (editorView) ->
    editor = editorView.getEditor()
    cursors = editor.getCursors()
    for cursor in cursors
      while true
        before = cursor.getBufferPosition()
        cursor.moveToBeginningOfWord()
        pos = cursor.getBufferPosition()

        break if before.isEqual pos
        break if @_getChar(editor, pos.row, pos.column).match /[0-9a-zA-Z]/

  hideTabs: (isHide) ->
    (if isHide then pane.find('.tab-bar').hide() else pane.find('.tab-bar').show()) for pane in atom.workspaceView.getPanes()

  hideSidebar: (isHide) ->
    panel = atom.workspaceView.parent().find '.tool-panel'
    if isHide then panel.hide() else panel.show()

  useEmacsCursor: (useEmacs) ->
    atom.workspaceView.eachEditorView (editorView) ->
      if useEmacs
        editorView.addClass 'emacs-cursor'
      else
        editorView.removeClass 'emacs-cursor'

  recenter: (editorView) ->
    cursorPos = editorView.getEditor().getCursorScreenPosition()
    rows = editorView.getPageRows()

    topRow = cursorPos.row - parseInt(rows / 2)
    topPos = editorView.getEditor().clipScreenPosition [topRow, 0]

    pix = editorView.pixelPositionForScreenPosition topPos
    editorView.scrollTop pix.top

  enableKillRing: (editorView) ->
    return if editorView.hasClass 'kill-ring'

    editorView.command 'emacs:yank', -> killRing.yank editorView
    editorView.command 'emacs:yank-pop', -> killRing.yankPop editorView
    editorView.command 'emacs:kill-region', -> killRing.killRegion editorView
    editorView.command 'emacs:kill-ring-save', ->
      killRing.killRingSave editorView
      editorView.trigger 'emacs:clear-selection'

    editorView.command 'emacs:cancel-yank', ->
      killRing.cancelYank()

    editorView.on 'mouseup', -> killRing.killRingSave editorView
    editorView.on 'core:cancel', ->
      editorView.trigger 'emacs:cancel-yank'

    editorView.addClass 'kill-ring'
