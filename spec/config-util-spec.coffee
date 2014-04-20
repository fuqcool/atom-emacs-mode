configUtil = require '../lib/config-util'

describe 'config util', ->
  watchHandler = null
  keyPath = 'emacs-mode:foo'

  getConfig = -> atom.config.get keyPath
  setConfig = (value) -> atom.config.set keyPath, value

  beforeEach ->
    setConfig null
    watchHandler = jasmine.createSpy 'watchHandler'

  it 'should write default value if key does not exists', ->
    configUtil.watch keyPath, false, watchHandler

    expect(getConfig()).toBe(false)
    expect(watchHandler).toHaveBeenCalledWith(false)

  it 'should not write default value if key exists', ->
    setConfig false
    configUtil.watch keyPath, true, watchHandler

    expect(watchHandler).toHaveBeenCalledWith(false)
    expect(getConfig()).toBe(false)

  it 'should work with only two arguments', ->
    configUtil.watch keyPath, watchHandler
    setConfig true

    expect(watchHandler).toHaveBeenCalledWith(true)

  it 'should call handler with null if no config exists', ->
    configUtil.watch keyPath, watchHandler

    expect(watchHandler).toHaveBeenCalledWith(null)

  it 'should not throw error if there is only one argument', ->
    expect(->
      configUtil.watch keyPath
    ).not.toThrow()
