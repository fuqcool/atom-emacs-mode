{WorkspaceView} = require 'atom'

describe 'config', ->
  hideTabs = jasmine.createSpy 'hideTabs'
  hideSidebar = jasmine.createSpy 'hideSidebar'
  useEmacsCursor = jasmine.createSpy 'useEmacsCursor'

  beforeEach ->
    atom.config.set 'emacs-mode.hideTabs', undefined
    atom.config.set 'emacs-mode.hideSidebar', undefined
    atom.config.set 'emacs-mode.useEmacsCursor', undefined

    atom.workspaceView = new WorkspaceView
    atom.workspaceView.on 'emacs:hide-tabs', hideTabs
    atom.workspaceView.on 'emacs:hide-sidebar', hideSidebar
    atom.workspaceView.on 'emacs:use-emacs-cursor', useEmacsCursor

    require '../lib/config'

  it 'should ensure config exists', ->
    expect(atom.config.get('emacs-mode.hideTabs')).toBe(false)
    expect(atom.config.get('emacs-mode.hideSidebar')).toBeDefined(false)
    expect(atom.config.get('emacs-mode.useEmacsCursor')).toBeDefined(true)

  it 'should trigger corresponding events', ->
    expect(hideTabs).toHaveBeenCalled()
    expect(hideSidebar).toHaveBeenCalled()
    expect(useEmacsCursor).toHaveBeenCalled()
