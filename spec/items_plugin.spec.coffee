{ ItemsPlugin, ItemsManager, Plugin } = $.fn.textext

describe 'ItemsPlugin', ->
  expectItem   = (item) -> expect(plugin.$(".textext-items-item:contains(#{item})").length > 0)

  expectItems = (items) ->
    actual = []
    plugin.$('.textext-items-item .textext-items-label').each -> actual.push $(@).text().replace(/^\s+|\s+$/g, '')
    expect(actual.join ' ').to.equal items

  expectSelected = (item) -> expect(plugin.$(".textext-items-item:contains(#{item})")).to.match '.textext-items-selected'

  plugin = null

  beforeEach ->
    plugin = new ItemsPlugin element : $ '<div>'

  it 'has default options', -> expect(ItemsPlugin.defaults).to.be.ok

  describe 'instance', ->
    it 'is Plugin', -> expect(plugin).to.be.instanceof Plugin
    it 'is ItemsPlugin', -> expect(plugin).to.be.instanceof ItemsPlugin

  describe '.items', ->
    it 'returns instance of `ItemsManager` plugin', -> expect(plugin.items).to.be.instanceof ItemsManager

  describe '.select', ->
    beforeEach (done) ->
      plugin.setItems([ 'item1', 'item2', 'foo', 'bar' ]).done ->
        plugin.element.show()
        done()

    it 'selects first element by index', ->
      plugin.select 0
      expectSelected 'item1'

    it 'selects specified element by index', ->
      plugin.select 2
      expectSelected 'foo'

  describe '.hasItem', ->
    it 'returns `false` when specified item is not present', (done) ->
      plugin.items.fromString('item').done (item) =>
        expect(plugin.hasItem item).to.be.false
        done()

    it 'returns `true` when specified item is already present', (done) ->
      plugin.setItems([ 'item' ]).done ->
        plugin.items.fromString('item').done (item) =>
          expect(plugin.hasItem item).to.be.true
          done()

  describe '.selectedItem', ->
    beforeEach (done) -> plugin.setItems([ 'item1', 'item2', 'foo', 'bar' ]).done -> done()

    it 'returns `null` when no item selected', ->
      expect(plugin.selectedItem()).to.be.null

    it 'returns selected jQuery HTML element', ->
      plugin.$('.textext-items-item:eq(0)').addClass 'textext-items-selected'
      expect(plugin.selectedItem().find('.textext-items-label').text()).to.equal 'item1'

  describe '.selectedIndex', ->
    beforeEach (done) -> plugin.setItems([ 'item1', 'item2', 'foo', 'bar' ]).done -> done()

    describe 'when dropdown is not visible', ->
      it 'returns -1', -> expect(plugin.selectedIndex()).to.equal -1

    describe 'when dropdown is visible', ->
      it 'returns -1 when no item is selected', ->
        expect(plugin.selectedIndex()).to.equal -1

      it 'returns 0 when first item is selected', ->
        plugin.$('.textext-items-item:eq(0)').addClass 'textext-items-selected'
        expect(plugin.selectedIndex()).to.equal 0

      it 'returns 3 when fourth item is selected', ->
        plugin.$('.textext-items-item:eq(3)').addClass 'textext-items-selected'
        expect(plugin.selectedIndex()).to.equal 3

  describe '.defaultItems', ->
    beforeEach (done) ->
      plugin.userOptions.items = [ 'item1', 'item2' ]
      plugin.defaultItems().done ->
        done()

    it 'uses values from options to set the items', ->
      expectItems 'item1 item2'

  describe '.itemData', ->
    beforeEach (done) ->
      plugin.displayItems([ 'item1', 'item2', 'item3', 'item4' ]).done ->
        done()

    it 'returns original item object', ->
      expect(plugin.itemData plugin.$ '.textext-items-item:first').to.equal 'item1'

    it 'returns undefined if no data is present', ->
      expect(plugin.itemData $ '<div/>').to.be.undefined

  describe '.displayItems', ->
    describe 'first time', ->
      beforeEach (done) ->
        plugin.displayItems([ 'item1', 'item2', 'item3', 'item4' ]).done ->
          done()

      it 'does not change items', -> expect(plugin.items.items).to.deep.equal []
      it 'creates item elements in order', -> expectItems 'item1 item2 item3 item4'

      it 'adds labels to items', ->
        expectItem('item1').to.be.ok
        expectItem('item2').to.be.ok

      describe 'second time', ->
        it 'removes existing item elements', (done) ->
          plugin.displayItems([ 'new1', 'new2' ]).done ->
            expectItems 'new1 new2'
            done()

  describe '.setItems', ->
    beforeEach (done) ->
      plugin.setItems([ 'item1', 'item2', 'item3', 'item4' ]).done ->
        done()

    it 'changes items', -> expect(plugin.items.items).to.deep.equal [ 'item1', 'item2', 'item3', 'item4' ]
    it 'creates item elements in order', -> expectItems 'item1 item2 item3 item4'

    it 'emits `items.set`', (done) ->
      plugin.on event: 'items.set', handler: -> done()
      plugin.setItems([ 'item1' ])

  describe '.itemIndex', ->
    it 'returns item position for element', (done) ->
      plugin.setItems([ 'item1', 'item2', 'item3', 'item4' ]).done ->
        item = plugin.$ '.textext-items-item:eq(2)'
        expect(plugin.itemIndex item).to.equal 2
        done()

  describe '.addItem', ->
    describe 'with no existing items', ->
      it 'adds new item', (done) ->
        plugin.addItem('item1').done ->
          expectItem('item1').to.be.ok
          done()

    describe 'with one existing item', ->
      beforeEach (done) ->
        plugin.setItems([ 'item1' ]).done ->
          plugin.addItem('item2').done ->
            done()

      it 'adds new item', -> expectItem('item2').to.be.ok
      it 'has items in order', -> expectItems 'item1 item2'

    it 'emits `items.add`', (done) ->
      plugin.on event: 'items.add', handler: -> done()
      plugin.addItem 'item'

  describe '.removeItemAt', ->
    describe 'with one existing item', ->
      it 'removes the only item', (done) ->
        plugin.setItems([ 'item1' ]).done ->
          plugin.removeItemAt(0).done ->
            expectItem('item1').to.not.be.ok
            done()

    describe 'with two existing items', ->
      it 'removes one item', (done) ->
        plugin.setItems([ 'item1', 'item3' ]).done ->
          plugin.removeItemAt(1).done ->
            expectItem('item3').to.not.be.ok
            done()

    it 'emits `items.remove`', (done) ->
      plugin.setItems([ 'item1', 'item3' ]).done ->
        plugin.on event: 'items.remove', handler: -> done()
        plugin.removeItemAt 0

