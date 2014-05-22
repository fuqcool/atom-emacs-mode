KillRingModel = require './kill-ring-model'
{Range} = require 'atom'

module.exports =
  model: new KillRingModel,

  yank: (editorView) ->
    @_excludeCursor editorView, =>
      editor = editorView.getEditor()
      @yankBeg = editor.getCursorBufferPosition()
      editor.insertText @model.yankText()

  yankPop: (editorView) ->
    @_excludeCursor editorView, =>
      if @model.yanking
        editor = editorView.getEditor()
        text = @model.yankPopText()
        currentPos = editor.getCursorBufferPosition()
        editor.setTextInBufferRange(new Range(@yankBeg, currentPos), text)

  killRingSave: (editorView) ->
    @_saveClipboard()

    editor = editorView.getEditor()
    editor.copySelectedText()
    text = atom.clipboard.read()

    @model.put text
    editorView.trigger 'emacs:clear-mark'

  killRegion: (editorView) ->
    @_saveClipboard()

    editor = editorView.getEditor()
    editor.cutSelectedText()
    text = atom.clipboard.read()

    @model.put text

  cancelYank: ->
    @model.cancel()

  # need a better way to disable cursor while callback is executing
  _excludeCursor: (editorView, callback) ->
    editorView.off 'cursor:moved'

    callback.call @

    setTimeout =>
      editorView.on 'cursor:moved', => @cancelYank()

  _saveClipboard: ->
    text = atom.clipboard.read()
    if text isnt @model.yankText()
      @model.put text
