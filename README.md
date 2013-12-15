# Jekyll::TemplateWrapper

jekyll-template_wrapper adds haml template support to jekyll.  It's
implemented by wrapping whole layout/partial files in 'haml'
Liquid-block-tag.  So you can access the Jekyll/Liquid context in haml
templates.

## Installation

Add this line to your application's Gemfile:

```
gem 'jekyll-template_wrapper'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install jekyll-template_wrapper
```

## Usage

* `.haml` files converted as Haml template.
* Liquid `include` tag can include `.haml` files as Haml template.
* In Haml templates you can access Liquid/Jekyll context.

### Variables

* `=_('name.of.var')` is equivalent `{{ name.of.var }}`.
* `=_('name.of.var', :foo )` is equivalent `{{ name.of.var | foo }}`.
* `=_('name.of.var', foo: arg1, bar: [arg2, arg3] )` is equivalent `{{ name.of.var | foo arg1 | bar arg2 arg3 }}`.

And

* `=content` is equivalent `{{ content }}`

### Filters

* `_` prefixed name is treated as Liquid-filter call.
* `=_xml_escape('...')` is equivalent `{{ '...' | xml_escape }}`.

### Liquid tag

* `liquid_` prefixed name is treated as Liquid-tag call.
* `=liquid_post_url '2013-12-15-foobar'` is equivalent `{% post_url '2013-12-15-foobar %}`.
* format of arguments for `liquid_` call:
  * Liquid style: `liquid_foo 'arg1 arg2 ...'`
  * array style: `liquid_foo 'arg1', 'arg2', ...` (args are joined by ` ` and passed to Liquid tag.)

### include tag

* `liquid_include` includes a partial.
* `=liquid_include 'foo.html'` includes `_includes/foo.html` as Liquid templates.
* `=liquid_include 'foo.haml'` includes `_includes/foo.haml` as Haml templates.
* `=liquid_include '...', foo: 'bar', bar: 'baz'` is equivalent `{% include ... foo=bar bar=baz %}`.
  * In included file you can refer the locals as `_('include.foo')`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
