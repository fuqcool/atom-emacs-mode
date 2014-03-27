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
    @_clearSelection(editorView)

  openLine: (editorView) ->
    editor = editorView.getEditor()
    pos = editor.getCursorBufferPosition()
    editor.insertNewline()
    editor.setCursorBufferPosition(pos)

  _clearSelection: (editorView) ->
    editor = editorView.getEditor()
    selections = editor.getSelections()
    selections.forEach (sel) ->
      sel.clear()
