configUtil = require './config-util'

configUtil.watch 'emacs-mode.hideTabs', false, (value) ->
  atom.workspaceView.trigger 'emacs:hide-tabs', value

configUtil.watch 'emacs-mode.hideSidebar', false, (value) ->
  atom.workspaceView.trigger 'emacs:hide-sidebar', value

configUtil.watch 'emacs-mode.useEmacsCursor', true, (value) ->
  atom.workspaceView.trigger 'emacs:use-emacs-cursor', value
