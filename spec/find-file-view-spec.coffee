{WorkspaceView} = require 'atom'
fs = require 'fs'
path = require 'path'

FileFinderView = require '../lib/find-file-view'

describe 'file finder view', ->
  context = (uri) ->
    atom.workspace = {
      getActiveEditor: -> {getUri: -> uri}
    }

  beforeEach ->
    path.sep = '/'
    process.env.HOME = '/home/me'

    atom.workspaceView = new WorkspaceView

  describe 'initialization', ->
    beforeEach ->
      spyOn(fs, 'existsSync').andReturn true

    it 'uses HOME as default directory when no file is open', ->
      context ''
      spyOn(fs, 'readdirSync').andReturn []

      fileFinderView = new FileFinderView

      expect(fileFinderView.filterEditorView.getText()).toBe '~/'

    it 'uses HOME as default directory when file has no path', ->
      context '.'
      spyOn(fs, 'readdirSync').andReturn []

      fileFinderView = new FileFinderView

      expect(fileFinderView.filterEditorView.getText()).toBe '~/'


    it 'finds file in parent directory', ->
      context '/a/b/c'
      spyOn(fs, 'readdirSync').andReturn []

      fileFinderView = new FileFinderView

      expect(fileFinderView.filterEditorView.getText()).toBe '/a/b/'

    it 'finds file in parent directory in home', ->
      context '/home/me/a/b'
      spyOn(fs, 'readdirSync').andReturn []

      fileFinderView = new FileFinderView

      expect(fileFinderView.filterEditorView.getText()).toBe '~/a/'
