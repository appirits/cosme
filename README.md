# Cosme

[![Build Status](https://img.shields.io/travis/appirits/cosme.svg?style=flat-square)](http://travis-ci.org/appirits/cosme)
[![Code Climate](https://img.shields.io/codeclimate/github/appirits/cosme.svg?style=flat-square)](https://codeclimate.com/github/appirits/cosme)
[![Dependency Status](https://img.shields.io/gemnasium/appirits/cosme.svg?style=flat-square)](https://gemnasium.com/appirits/cosme)
[![Gem Version](https://img.shields.io/gem/v/cosme.svg?style=flat-square)](https://rubygems.org/gems/cosme)

Cosme is a simple solution to customize views of any template engine in your Ruby on Rails application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cosme'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cosme

## Usage

1. Require a script in your `app/assets/javascripts/application.coffee`:

  ```coffee
  #= require cosme
  ```

2. Use the helper method in your views.

  ```erb
  <%= cosmeticize %>
  ```

3. Create a cosmetic file into `app/cosmetics`.


## Example

Inserts html to all elements of .example:

```ruby
# app/cosmetics/after_example.rb
Cosme.define(
  target: '.example',
  action: :after
)
```

```erb
<%# app/cosmetics/after_example.html.erb %>
<h2>After Example</h2>
```

```erb
<%# app/views/layouts/application.html.erb %>
<html>
  <head>
    <title>Example</title>
    <%= stylesheet_link_tag 'application', media: 'all' %>
    <%= javascript_include_tag 'application'%>
  </head>
  <body>
    <%= cosmeticize %>
    <div class="example">
      <h1>Example</h1>
    </div>
  </body>
</html>
```

The result of the above:

```html
<div class="example">
  <h1>Example</h1>
</div>
<h2>After Example</h2>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/appirits/cosme.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
