{WorkspaceView} = require 'atom'
fs = require 'fs'
path = require 'path'

FileFinderView = require '../lib/find-file-view'

describe 'file finder view', ->
  fileFinderView = null

  beforeEach ->
    path.sep = '/'
    process.env.HOME = '/home/me'

    atom.workspaceView = new WorkspaceView
    fileFinderView = new FileFinderView

    spyOn(fs, 'readdirSync').andCallFake (dir) ->
        if dir in ['/home/me', '/home/me/']
          ['foo', 'bar']
        else if dir in ['/home', '/home/']
          ['a', 'b', 'c']


  describe 'listDir', ->
    it 'list files in directory', ->
      files = fileFinderView.listDir '/home/me'

      expect(files).toEqual([
        {uri: '/home/me/foo', name: 'foo'}
        {uri: '/home/me/bar', name: 'bar'}
      ])

    it 'list files in home', ->
      files = fileFinderView.listDir '~'

      expect(files).toEqual([
        {uri: '~/foo', name: 'foo'}
        {uri: '~/bar', name: 'bar'}
      ])

  describe 'renderItems', ->
    it 'render directory with tail separator', ->
      spyOn(fileFinderView.filterEditorView, 'getText').andReturn '/home/me/'

      items = fileFinderView.renderItems()

      expect(items).toEqual([
        {uri: '/home/me/foo', name: 'foo'}
        {uri: '/home/me/bar', name: 'bar'}
      ])

    it 'render directory without tail separator', ->
      spyOn(fileFinderView.filterEditorView, 'getText').andReturn '/home/me'

      items = fileFinderView.renderItems()

      expect(items).toEqual([
        {uri: '/home/a', name: 'a'}
        {uri: '/home/b', name: 'b'}
        {uri: '/home/c', name: 'c'}
      ])

    it 'render directory with tail separator', ->
      spyOn(fileFinderView.filterEditorView, 'getText').andReturn '~/'

      items = fileFinderView.renderItems()

      expect(items).toEqual([
        {uri: '~/foo', name: 'foo'}
        {uri: '~/bar', name: 'bar'}
      ])

    it 'renders home without tail separator', ->
      spyOn(fileFinderView.filterEditorView, 'getText').andReturn '~'

      items = fileFinderView.renderItems()

      expect(items).toEqual([
        {uri: '/home/a', name: 'a'}
        {uri: '/home/b', name: 'b'}
        {uri: '/home/c', name: 'c'}
      ])

    it 'returns empty array if dir is empty', ->
      spyOn(fileFinderView.filterEditorView, 'getText').andReturn ''

      items = fileFinderView.renderItems()

      expect(items).toEqual []
