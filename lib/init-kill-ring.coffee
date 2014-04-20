KillRing = require './kill-ring'
{Range} = require 'atom'

# kill ring is shared by all editor views
killRing = new KillRing
yankBeg = null

saveClipboard = ->
  text = atom.clipboard.read()
  if text isnt killRing.yankText()
    killRing.put text

yank = (editorView) ->
  saveClipboard()

  excludeCursor editorView, ->
    editor = editorView.getEditor()
    yankBeg = editor.getCursorBufferPosition()
    editor.insertText(killRing.yankText())

yankPop = (editorView) ->
  excludeCursor editorView, ->
    if killRing.yanking
      editor = editorView.getEditor()
      text = killRing.yankPopText()
      currentPos = editor.getCursorBufferPosition()
      editor.setTextInBufferRange(new Range(yankBeg, currentPos), text)

killRingSave = (editorView) ->
  saveClipboard()

  editor = editorView.getEditor()
  editor.copySelectedText()
  text = atom.clipboard.read()

  killRing.put text
  editorView.trigger 'emacs:clear-mark'

killRegion = (editorView) ->
  saveClipboard()

  editor = editorView.getEditor()
  editor.cutSelectedText()
  text = atom.clipboard.read()

  killRing.put text

cancelYank = ->
  killRing.cancel()

excludeCursor = (editorView, callback) ->
  editorView.off 'cursor:moved', cancelYank
  callback?()
  setTimeout(-> editorView.on 'cursor:moved', cancelYank)

atom.workspaceView.eachEditorView (editorView) =>
  editorView.command 'emacs:yank', -> yank(editorView)
  editorView.command 'emacs:yank-pop', -> yankPop(editorView)
  editorView.command 'emacs:kill-region', -> killRegion(editorView)
  editorView.command 'emacs:kill-ring-save', ->
    killRingSave(editorView)
    editorView.trigger 'emacs:clear-selection'

  editorView.on 'mouseup', -> killRingSave(editorView)
  editorView.on 'core:cancel', -> cancelYank()
