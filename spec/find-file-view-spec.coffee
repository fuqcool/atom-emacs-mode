{WorkspaceView} = require 'atom'
fs = require 'fs'
path = require 'path'

FileFinderView = require '../lib/find-file-view'

describe 'file finder view', ->
  fileFinderView = null

  activeUri = (uri) ->
    atom.workspace = {
      getActiveEditor: -> {getUri: -> uri}
    }

  beforeEach ->
    path.sep = '/'
    process.env.HOME = '/home/me'

    atom.workspaceView = new WorkspaceView

    spyOn(fs, 'readdirSync').andCallFake (dir) ->
        if dir in ['/home/me', '/home/me/']
          ['foo', 'bar']
        else if dir in ['/home', '/home/']
          ['a', 'b', 'me']

    activeUri ''
    fileFinderView = new FileFinderView

  describe 'init', ->
    it 'uses current file directory as initial directory', ->
      activeUri '/home/a'

      fileFinderView = new FileFinderView

      expect(fileFinderView.filterEditorView.getText()).toBe '/home/'

    it 'uses HOME as initial directory', ->
      fileFinderView = new FileFinderView

      expect(fileFinderView.items.length).toBe 2
      expect(fileFinderView.filterEditorView.getText()).toBe '~/'

    it 'use HOME as prefix', ->
      activeUri '/home/me/a/b'

      fileFinderView = new FileFinderView

      expect(fileFinderView.filterEditorView.getText()).toBe '~/a/'


  it 'renders files in directory', ->
    fileFinderView.filterEditorView.setText '/home/me/'

    expect(fileFinderView.items).toEqual([
      {uri: '/home/me/foo', name: 'foo'}
      {uri: '/home/me/bar', name: 'bar'}
    ])

    expect(fileFinderView.list.find('li').length).toBe 2

  it 'renders files in parent directory', ->
    fileFinderView.filterEditorView.setText '/home/me'

    expect(fileFinderView.items).toEqual([
      {uri: '/home/me', name: 'Create me'}
      {uri: '/home/a', name: 'a'}
      {uri: '/home/b', name: 'b'}
      {uri: '/home/me', name: 'me'}
    ])

    expect(fileFinderView.list.find('li').length).toBe 2

  it 'renders files when file name is partial complete', ->
    fileFinderView.filterEditorView.setText '/home/e'

    expect(fileFinderView.list.find('li').length).toBe 2
