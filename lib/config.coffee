config = require './config-util'

config.watch 'emacs-mode.hideTabs', false, (value) ->
  atom.workspaceView.trigger 'emacs:hide-tabs', value

config.watch 'emacs-mode.hideSidebar', false, (value) ->
  atom.workspaceView.trigger 'emacs:hide-sidebar', value

config.watch 'emacs-mode.useEmacsCursor', true, (value) ->
  atom.workspaceView.trigger 'emacs:use-emacs-cursor', value

config.watch 'emacs-mode.useFuzzyFileFinder', false, (value) ->
  atom.workspaceView.trigger 'emacs:use-fuzzy-file-finder', value

config.watch 'emacs-mode.useFuzzyBufferFinder', false, (value) ->
  atom.workspaceView.trigger 'emacs:use-fuzzy-buffer-finder', value
