{WorkspaceView} = require 'atom'

describe 'config', ->
  hideTabs = jasmine.createSpy 'hideTabs'
  hideSidebar = jasmine.createSpy 'hideSidebar'
  useEmacsCursor = jasmine.createSpy 'useEmacsCursor'
  useFuzzyFileFinder = jasmine.createSpy 'useFuzzyFileFinder'

  beforeEach ->
    atom.config.set 'emacs-mode.hideTabs', undefined
    atom.config.set 'emacs-mode.hideSidebar', undefined
    atom.config.set 'emacs-mode.useEmacsCursor', undefined
    atom.config.set 'emacs-mode.useFuzzyFileFinder', undefined

    atom.workspaceView = new WorkspaceView
    atom.workspaceView.on 'emacs:hide-tabs', hideTabs
    atom.workspaceView.on 'emacs:hide-sidebar', hideSidebar
    atom.workspaceView.on 'emacs:use-emacs-cursor', useEmacsCursor
    atom.workspaceView.on 'emacs:use-fuzzy-file-finder', useFuzzyFileFinder

    require '../lib/config'

  it 'should ensure config exists', ->
    expect(atom.config.get('emacs-mode.hideTabs')).toBe(false)
    expect(atom.config.get('emacs-mode.hideSidebar')).toBeDefined(false)
    expect(atom.config.get('emacs-mode.useEmacsCursor')).toBeDefined(true)
    expect(atom.config.get('emacs-mode.useFuzzyFileFinder')).toBeDefined(true)

  it 'should trigger corresponding events', ->
    expect(hideTabs).toHaveBeenCalled()
    expect(hideSidebar).toHaveBeenCalled()
    expect(useEmacsCursor).toHaveBeenCalled()
    expect(useFuzzyFileFinder).toHaveBeenCalled()
