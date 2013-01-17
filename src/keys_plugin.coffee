do (window, $ = jQuery, module = $.fn.textext) ->
  { Plugin } = module

  class KeysPlugin extends Plugin
    @defaults =
      keys :
        8   : { name : 'backspace' }
        9   : { name : 'tab' }
        13  : { name : 'enter', trap : true }
        27  : { name : 'esc', trap : true }
        37  : { name : 'left' }
        38  : { name : 'up', trap : true }
        39  : { name : 'right' }
        40  : { name : 'down', trap : true }
        46  : { name : 'delete' }
        108 : { name : 'numpadEnter' }

      html :
        element : '<div class="textext-keys"/>'

    constructor : (opts = {}) ->
      super opts, KeysPlugin.defaults

      @downKeys = {}

      input = opts.element

      unless input
        input = @parent.element
        input = input.find 'input'

      input
        .keydown((e) => @onKeyDown e.keyCode)
        .keyup((e) => @onKeyUp e.keyCode)

    key : (keyCode) ->
      @options("keys.#{keyCode}") or name : "code.#{keyCode}"

    onKeyDown : (keyCode) ->
      @downKeys[keyCode] = true
      key = @key keyCode
      @emit "keys.down.#{key.name}", keyCode
      key.trap isnt true

    onKeyUp : (keyCode) ->
      key = @key keyCode
      @emit "keys.up.#{key.name}", keyCode, key.name
      @emit "keys.press.#{key.name}", keyCode, key.name if @downKeys[keyCode]
      @downKeys[keyCode] = false
      key.trap isnt true

  # add plugin to the registery so that it is usable by TextExt
  Plugin.register 'keys', KeysPlugin

  module.KeysPlugin = KeysPlugin
