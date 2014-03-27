{Range} = require 'atom'

STATUS_IDLE = 0
STATUS_READY = 1
STATUS_YANK = 2

module.exports =
  class KillRing
    constructor: ->
      @ring = []
      @status = STATUS_IDLE
      @yankBeg = null

    _push: (text) ->
      @ring.push(text)

    _pop: ->
      if @ring.length
        @ring.unshift @ring.pop()
        @ring[@ring.length - 1]

    _top: ->
      if @ring.length
        @ring[@ring.length - 1]

    _bottom: ->
      if @ring.length
        @ring[0]

    _saveClipboard: ->
      text = atom.clipboard.read()
      if text != @_top()
        @_push(text)

    cancelYank: ->
      if @status is STATUS_YANK
        @status = STATUS_IDLE
      else if @status is STATUS_READY
        @status = STATUS_YANK

    yank: (editorView) ->
      @_saveClipboard()
      if @ring.length
        editor = editorView.getEditor()
        @yankBeg = editor.getCursorBufferPosition()
        @status = STATUS_READY
        editor.insertText(@_top())

    yankPop: (editorView) ->
      if @status is STATUS_YANK
        editor = editorView.getEditor()
        text = @_pop()
        if text.length != @_bottom().length
          @status = STATUS_READY
        currentPos = editor.getCursorBufferPosition()
        editor.setTextInBufferRange(new Range(@yankBeg, currentPos), text)

    killRingSave: (editorView) ->
      @_saveClipboard()
      editor = editorView.getEditor()
      editor.copySelectedText()
      text = atom.clipboard.read()
      @_push(text)

    killRegion: (editorView) ->
      @_saveClipboard()
      editor = editorView.getEditor()
      editor.cutSelectedText()
      text = atom.clipboard.read()
      @_push(text)
