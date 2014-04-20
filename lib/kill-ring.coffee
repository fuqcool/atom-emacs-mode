_ = require 'underscore-plus'

module.exports =
  class KillRing
    constructor: ->
      @items = []
      @yanking = false
      @capacity = 1000
      @emptyItem =
        text: ''
        meta: null

    _top: ->
      _.last @items

    _shift: ->
      @items.unshift @items.pop()

    put: (text, meta) ->
      @items.push(text: text, meta: meta)

    yank: ->
      if @items.length
        @yanking = true
        @_top()
      else
        @emptyItem

    yankPop: ->
      if @yanking
        @_shift()
        @_top()
      else
        throw new Error("Previous command is not yank.")

    yankText: -> @yank().text

    yankPopText: -> @yankPop().text

    cancel: ->
      @yanking = false if @yanking
