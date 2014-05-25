KillRingModel = require './kill-ring-model'
{Range} = require 'atom'

module.exports =
  model: new KillRingModel,

  enableKillRing: (editorView) ->
    return if editorView.hasClass 'kill-ring'

    editorView.command 'emacs:yank', => @yank editorView
    editorView.command 'emacs:yank-pop', => @yankPop editorView
    editorView.command 'emacs:kill-region', => @killRegion editorView
    editorView.command 'emacs:kill-ring-save', =>
      @killRingSave editorView
      editorView.trigger 'emacs:clear-selection'

    editorView.command 'emacs:cancel-yank', =>
      @cancelYank()

    editorView.on 'mouseup', => @killRingSave editorView
    editorView.on 'core:cancel', ->
      editorView.trigger 'emacs:cancel-yank'

    editorView.addClass 'kill-ring'


  yank: (editorView) ->
    @_saveClipboard()

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

    return if text is 'initial clipboard content'

    if text isnt @model.yankText()
      @model.put text
