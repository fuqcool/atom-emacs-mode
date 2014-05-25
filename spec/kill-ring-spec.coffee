{WorkspaceView, EditorView, Range} = require 'atom'
killRing = require '../lib/kill-ring'

describe 'kill-ring', ->
  editorView = null
  editor = null

  beforeEach ->
    session = atom.project.openSync()
    editorView = new EditorView(session)

    editor = editorView.getEditor()
    editor.setText 'abcde'

    killRing.model.reset()
    killRing.enableKillRing editorView

    atom.clipboard.write 'initial clipboard content'

  it 'has class attached', ->
    expect(editorView.hasClass('kill-ring')).toBe true

  it 'copies text', ->
    editor.setSelectedBufferRange(new Range([0, 0], [0, 3]))
    editorView.trigger 'emacs:kill-ring-save'

    text = atom.clipboard.read()

    expect(text).toBe 'abc'
    expect(editor.getText()).toBe 'abcde'

  it 'cuts text', ->
    editor.setSelectedBufferRange(new Range([0, 2], [0, 5]))
    editorView.trigger 'emacs:kill-region'

    text = atom.clipboard.read()

    expect(text).toBe 'cde'
    expect(editor.getText()).toBe 'ab'

  it 'pastes text', ->
    editor.setSelectedBufferRange(new Range([0, 0], [0, 3]))
    editorView.trigger 'emacs:kill-region'

    text = atom.clipboard.read()
    editor.moveCursorToEndOfLine()

    editorView.trigger 'emacs:yank'

    expect(editor.getText()).toBe 'deabc'

    editorView.trigger 'emacs:yank'

    expect(editorView.getText()).toBe 'deabcabc'

  it 'searches kill ring', ->
    editor.setSelectedBufferRange(new Range([0, 0], [0, 1]))
    editorView.trigger 'emacs:kill-region'

    editor.setSelectedBufferRange(new Range([0, 0], [0, 4]))
    editorView.trigger 'emacs:kill-region'

    editorView.trigger 'emacs:yank'
    expect(editor.getText()).toBe 'bcde'

    editorView.trigger 'emacs:yank-pop'
    expect(editor.getText()).toBe 'a'

    editorView.trigger 'emacs:yank-pop'
    expect(editor.getText()).toBe 'bcde'

  it 'copies text by mouse', ->
    editor.setSelectedBufferRange(new Range([0, 0], [0, 3]))

    editorView.trigger 'mouseup'

    text = atom.clipboard.read()
    expect(text).toBe 'abc'

  it 'paste text from outside atom', ->
    editor.setText ''
    atom.clipboard.write 'alien'

    editorView.trigger 'emacs:yank'

    expect(editor.getText()).toBe 'alien'
