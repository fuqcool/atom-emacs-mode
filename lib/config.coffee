watch = (configName) ->
  if arguments.length is 2
    callback = arguments[1]
    defaultValue = null
  else
    defaultValue = arguments[1]
    callback = arguments[2]

  atom.config.observe configName, ->
    callback?(atom.config.get(configName) ? defaultValue)

watch 'emacs-mode.hideTabs', false, (value) ->
  atom.workspaceView.trigger 'emacs:hide-tabs', value

watch 'emacs-mode.hideSidebar', false, (value) ->
  atom.workspaceView.trigger 'emacs:hide-sidebar', value

watch 'emacs-mode.useEmacsCursor', true, (value) ->
  atom.workspaceView.trigger 'emacs:use-emacs-cursor', value
