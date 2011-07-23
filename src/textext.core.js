(function($, undefined)
{
	function TextExt()
	{
	};

	var p = TextExt.prototype,
		slice = Array.prototype.slice,
		DEFAULT_OPTS = {
			plugins : [],
			ext : {},

			html : {
				wrap : '<div class="text-core"><div class="text-wrap"/></div>'
			},

			keys : {
				8   : 'Backspace',
				9   : 'Tab',
				13  : 'Enter!',
				27  : 'Escape!',
				37  : 'Left',
				38  : 'Up!',
				39  : 'Right',
				40  : 'Down!',
				46  : 'Delete',
				108 : 'NumpadEnter',
				188 : 'Comma'
			}
		}
		;

	function combine()
	{
		var args   = slice.apply(arguments),
			target = args.shift(),
			source = args.shift(),
			key, item, isObject, isArray
			;

		if(source == null)
			return target;

		if($.isArray(source) && $.isArray(target))
			target = target.concat(source);

		else for(key in source)
		{
			item     = source[key];
			isObject = $.isPlainObject(item);
			isArray  = $.isArray(item);

			if(isObject || isArray)
				target[key] = combine(target[key] || (isArray ? [] : {}), item);
			else
				if(typeof(target[key]) == 'undefined' && item != null)
					target[key] = item;
		}

		if(args.length > 0)
		{
			args.unshift(target);
			target = combine.apply(null, args);
		}

		return target;
	};

	p.init = function(input, opts)
	{
		var self = this;

		self.opts = opts = $.extend(true, {}, DEFAULT_OPTS, opts || {});
		self.plugins = {};

		self.input = input = $(input)
			.wrap(opts.html.wrap)
			.keydown(function(e) { return self.onKeyDown(e) })
			.keyup(function(e) { return self.onKeyUp(e) })
			.blur(function(e) { return self.onBlur(e) })
			;

		$.extend(true, self, opts.ext['*'], opts.ext['core']);
		
		self.getWrapContainer().click(function(e) { return self.onClick(e) });

		self.originalWidth = input.outerWidth();

		self.invalidateBounds();
		self.initPlugins(opts.plugins);
	};

	p.initPlugins = function(plugins)
	{
		var self = this,
			ext, name, plugin
			;

		if(typeof(plugins) == 'string')
			plugins = plugins.split(/\s*,\s*/g);

		for(var i = 0; i < plugins.length, name = plugins[i]; i++)
		{
			plugin = $.fn.textext.plugins[name];

			if(plugin)
			{
				plugin             = new plugin();
				ext                = self.getOpts().ext;
				self.plugins[name] = plugin;

				$.extend(true, plugin, ext['*'], ext[name]);
				plugin.init(self);
			}
		}
	};

	p.trigger = function()
	{
		$(this).trigger(
			arguments[0],
			slice.call(arguments, 1)
		);
	};

	p.getInput = function()
	{
		return this.input;
	};

	p.getOpts = function()
	{
		return this.opts;
	};

	p.getWrapContainer = function()
	{
		return this.getInput().parent();
	};

	p.invalidateBounds = function()
	{
		var self      = this,
			input     = self.getInput(),
			wrap      = self.getWrapContainer(),
			container = wrap.parent(),
			width     = self.originalWidth,
			height
			;

		self.trigger('invalidate');

		height = input.outerHeight()

		input.width(width);
		wrap.width(width).height(height);
		container.height(height);
	};

	p.focusInput = function()
	{
		this.getInput()[0].focus();
	};

	//--------------------------------------------------------------------------------
	// User mouse/keyboard input
	
	p.onBlur = function(e)
	{
		this.trigger('blur');
	};

	p.onClick = function(e)
	{
		var self   = this,
			source = $(e.target)
			;

		self.trigger('click', source);

		return true;
	};

	$(['Down', 'Up']).each(function()
	{
		var type = this.toString();

		p['onKey' + type] = function(e)
		{
			var self          = this,
				keyName       = self.getOpts().keys[e.keyCode] || 'Other',
				defaultResult = keyName.indexOf('!') != keyName.length - 1,
				eventName     = keyName.replace('!', '') + 'Key' + type,
				result
				;

			self.trigger(eventName.charAt(0).toLowerCase() + eventName.substring(1));

			return defaultResult;
		};
	});

	//--------------------------------------------------------------------------------
	// Plugin Base
	
	function TextExtPlugin()
	{
	};

	p = TextExtPlugin.prototype;

	p.on = function(args)
	{
		var self   = this,
			parent = $(self.core()),
			event
			;

		for(event in args)
			(function(self, event, handler)
			{

				parent.bind(event, function()
				{
					return handler.apply(self, arguments);
				});

			})(self, event, args[event]);
	};

	p.baseInit = function(parent, opts)
	{
		parent.opts = combine({}, parent.opts, opts);
		p.parent    = parent;
	};

	p.core = function()
	{
		return this.parent;
	};

	p.getOpts = function()
	{
		return this.core().getOpts();
	};

	p.getInput = function()
	{
		return this.core().getInput();
	};

	p.trigger = function()
	{
		var core = this.core();
		core.trigger.apply(core, arguments);
	};

	p.stringToItem = function(str)
	{
		return str;
	};

	p.itemToString = function(item)
	{
		return item;
	};

	p.compareItems = function(item1, item2)
	{
		return item1 == item2;
	};

	//--------------------------------------------------------------------------------
	// jQuery Integration
	
	var textext = $.fn.textext = function(opts)
	{
		return this.map(function()
		{
			 var instance = new TextExt();
			 instance.init(this, opts);
			 return instance;
		});
	};

	textext.addPlugin = function(name, constructor)
	{
		textext.plugins[name]  = constructor;
		constructor.prototype = new textext.TextExtPlugin();
	};

	textext.TextExt       = TextExt;
	textext.TextExtPlugin = TextExtPlugin;
	textext.plugins       = {};
})(jQuery);
