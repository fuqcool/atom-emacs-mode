watch = (key) ->
  return if not key?

  if arguments.length is 2
    callback = arguments[1]
    defaultValue = null
  else
    defaultValue = arguments[1]
    callback = arguments[2]

  value = atom.config.get key

  # if config does not exists and default value is given, write default value
  if (not value?) and defaultValue?
    atom.config.set key, defaultValue

  atom.config.observe key, ->
    callback?(atom.config.get(key) ? null)

module.exports =
  watch: watch
