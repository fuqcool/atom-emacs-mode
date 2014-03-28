{Range, Point} = require 'atom'
BufferListView = require './buffer-list-view'
KillRing = require './kill-ring'


module.exports =
  killRing: new KillRing()

  activate: (state) ->
    atom.workspaceView.eachEditorView (editorView) =>
      editorView.command 'emacs:switch-buffer', => @switchBuffer(editorView)
      editorView.command 'emacs:yank', => @yank(editorView)
      editorView.on 'cursor:moved', => @killRing.cancelYank()
      editorView.command 'emacs:yank-pop', => @yankPop(editorView)
      editorView.command 'emacs:kill-region', => @killRegion(editorView)
      editorView.command 'emacs:kill-ring-save', => @killRingSave(editorView)
      editorView.command 'emacs:open-line', => @openLine(editorView)
      editorView.command 'emacs:forward-word', => @forwardWord(editorView)
      editorView.command 'emacs:backward-word', => @backwardWord(editorView)
      editorView.on 'core:cancel', => @clearSelection(editorView)
      editorView.on 'mouseup', => @selectByMouse(editorView)

  deactivate: ->

  serialize: ->

  switchBuffer: ->
    new BufferListView()

  yank: (editorView) ->
    @killRing.yank(editorView)

  yankPop: (editorView) ->
    @killRing.yankPop(editorView)

  killRegion: (editorView) ->
    editor = editorView.getEditor()
    @killRing.killRegion(editorView)

  killRingSave: (editorView) ->
    @killRing.killRingSave(editorView)
    @clearSelection(editorView)

  openLine: (editorView) ->
    editor = editorView.getEditor()
    pos = editor.getCursorBufferPosition()
    editor.insertNewline()
    editor.setCursorBufferPosition(pos)

  clearSelection: (editorView) ->
    editor = editorView.getEditor()
    sel.clear() for sel in editor.getSelections()

  selectByMouse: (editorView) ->
    @killRing.killRingSave(editorView)

  _getChar: (editor, row, col) ->
    editor.getTextInBufferRange(
      new Range(new Point(row, col), new Point(row, col + 1)))

  forwardWord: (editorView) ->
    editor = editorView.getEditor()
    cursors = editor.getCursors()
    for cursor in cursors
      while (true)
        before = cursor.getBufferPosition()
        cursor.moveToEndOfWord()
        pos = cursor.getBufferPosition()

        break if before.isEqual pos
        break if @_getChar(editor, pos.row, pos.column - 1).match(/[0-9a-zA-Z]/)

  backwardWord: (editorView) ->
    editor = editorView.getEditor()
    cursors = editor.getCursors()
    for cursor in cursors
      while (true)
        before = cursor.getBufferPosition()
        cursor.moveToBeginningOfWord()
        pos = cursor.getBufferPosition()

        break if before.isEqual pos
        break if @_getChar(editor, pos.row, pos.column).match(/[0-9a-zA-Z]/)
