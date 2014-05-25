KillRing = require '../lib/kill-ring-model'

describe 'kill ring model', ->
  killRing = null

  beforeEach ->
    killRing = new KillRing

  describe 'yank', ->
    it 'should perform simple paste', ->
      killRing.put 'foo'

      item = killRing.yank()
      expect(item.text).toBe 'foo'

    it 'should paste the latest text', ->
      killRing.put 'foo'
      killRing.put 'bar'

      item = killRing.yank()
      expect(item.text).toBe 'bar'

    it 'should return empty item if there is no item in the killring', ->
      item = killRing.yank()
      expect(item.text).toBe ''

  describe 'yank pop', ->
    it 'should raise an error if previous command is not yank', ->
      killRing.put 'foo'

      expect(-> killRing.yankPop()).toThrow()

    it 'should go through the kill ring over again', ->
      killRing.put 'foo'
      killRing.put 'bar'
      killRing.yank()

      item = killRing.yankPop()
      expect(item.text).toBe 'foo'

      item = killRing.yankPop()
      expect(item.text).toBe 'bar'

    it 'should work when there is only one item in the kill ring', ->
      killRing.put 'foo'
      killRing.yank()

      killRing.yankPop()
      item = killRing.yankPop()

      expect(item.text).toBe 'foo'

    it 'should take the lastest poped item as top', ->
      killRing.put 'foo'
      killRing.put 'bar'

      killRing.yank()
      killRing.yankPop()

      item = killRing.yank()

      expect(item.text).toBe 'foo'

    it 'should cancel a yanking', ->
      killRing.put 'foo'
      killRing.put 'bar'

      killRing.yank()
      killRing.yankPop()
      killRing.cancel()

      expect(-> killRing.yankPop()).toThrow()

    it 'should reset index to top when putting new item', ->
      killRing.put 'foo'
      killRing.put 'bar'

      killRing.yank()
      killRing.yankPop()

      killRing.put 'bla'

      item = killRing.yank()
      expect(item.text).toBe 'bla'

      item = killRing.yankPop()
      expect(item.text).toBe 'bar'

  it 'should store meta info together with text', ->
    killRing.put 'foo', {start: 100}
    item = killRing.yank()

    expect(item.meta.start).toBe 100

  it 'reset kill ring', ->
    killRing.put 'foo'
    killRing.yank()

    killRing.reset()
    expect(killRing.items.length).toBe 0
    expect(killRing.yanking).toBe false
    expect(killRing.currentItemIndex).toBe -1
