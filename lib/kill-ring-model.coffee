_ = require 'underscore-plus'

module.exports =
  class KillRing
    constructor: ->
      @reset()

      @capacity = 1000
      @emptyItem =
        text: ''
        meta: null

    _getCurrentItem: ->
      if @currentItemIndex >= 0
        @items[@currentItemIndex]
      else
        @emptyItem

    _gotoNextItem: ->
      return if @currentItemIndex is -1

      if @currentItemIndex is 0
        @currentItemIndex = @items.length - 1
      else
        @currentItemIndex--

    reset: ->
      @items = []
      @yanking = false
      @currentItemIndex = -1

    put: (text, meta) ->
      @items.push(text: text, meta: meta)
      @currentItemIndex = @items.length - 1

    yank: ->
      if @items.length
        @yanking = true
        @_getCurrentItem()
      else
        @emptyItem

    yankPop: ->
      if @yanking
        @_gotoNextItem()
        @_getCurrentItem()
      else
        throw new Error("Previous command is not yank.")

    yankText: -> @yank().text

    yankPopText: -> @yankPop().text

    cancel: ->
      @yanking = false if @yanking
