[![Build Status](https://travis-ci.org/st0012/zubot.svg?branch=master)](https://travis-ci.org/st0012/zubot)

# Zubot

Zubot precompiles every templates under your application and rails enginge's app/views folder into ruby code during boot time. The benefit and reason of doing this can be found  [here](https://github.com/railsgsoc/ideas/wiki/2016-Ideas#eager-load-action-view-templates).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zubot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zubot

## Usage

For now it will automatically do the precompilation for your. But to actually cache the precompiled result you need to set `config.consider_all_requests_local = false`

And You can use configuration to choose if you want to print the result by put this in `config/initializers/zubot.rb`: 

```ruby
Zubot.debug_mode = true # default is true if you're in development environment
```

You should see belows in boot time:

```
Template: layouts/application, formats: [:html] compiled? false
Template: layouts/mailer, formats: [:html] compiled? false
Template: layouts/mailer, formats: [:text] compiled? false
Template: posts/_form, formats: [:html] compiled? false
Template: posts/edit, formats: [:html] compiled? false
Template: posts/index, formats: [:html] compiled? false
Template: posts/index, formats: [:json] compiled? false
Template: posts/new, formats: [:html] compiled? false
Template: posts/show, formats: [:html] compiled? false
Template: posts/show, formats: [:json] compiled? false
```

And after you visit a page (say posts/1), you will see:

```
  Rendering posts/show.html.erb within layouts/application
Template: posts/show, formats: [:html] compiled? true
  Rendered posts/show.html.erb within layouts/application (4.9ms)
Template: layouts/application, formats: [:html] compiled? true
```

# Major Issues

## Can't precompile partials

### The Problem
We can't precompile partial with locals while boot time. The reason is that during boot time we can't know what locals would be needed to compile the template.
For example, say we have a `edit.html.erb` like:

```erb
<h1>Editing Post</h1>

<%= render 'form', post: @post %>
```

And let's take a look on `ActionView`'s template [cache mechanism](https://github.com/rails/rails/blob/master/actionview/lib/action_view/template/resolver.rb#L185):

```ruby
    def cached(key, path_info, details, locals) #:nodoc:
      name, prefix, partial = path_info
      locals = locals.map(&:to_s).sort!

      if key
        @cache.cache(key, name, prefix, partial, locals) do
          decorate(yield, path_info, details, locals)
        end
      else
        decorate(yield, path_info, details, locals)
      end
    end
```

Locals are one of the cache key. So in order to find and cache the form partial correctly, we need to tell actionview that it would have a local called `post`. But we can't know that unless we actually render this `edit` template. That means even if we precompiled partials, we can't actually use it because the cache will miss. And I think this issue can only be solved after we find a way to remove locals from template's cache key.

Futhermore, the locals we get when compiling templates looks like `["post", "user"]`, which is used in [`ActionView::Template#locals_code`](https://github.com/rails/rails/blob/master/actionview/lib/action_view/template.rb#L326) to pre-define the renderence to the later `local_assigns` hash. If we don't do that, when the template actually get rendered, we would get message like `undefined method 'post'`, because Rails don't know where to get the locals.

### The Solution

So the requirement for an ideal solution is to remove locals from cache key (or even the entire template finding process), and make sure that Rails can still find out where to get the locals when rendering partials.

And my approach is to create binding method on the fly. I will monkey-patching the `ActionView::Template#compile` method's `source` part:

```ruby
  source = <<-end_src
    def #{method_name}(local_assigns, output_buffer)
      @local_assigns = local_assigns

      local_assigns.each_key do |key|
        unless methods.include?(key)
          source = <<-inner_source
            def \#{key}
              @local_assigns[:\#{key}]
            end
          inner_source
          self.instance_eval(source)
        end
      end
      _old_virtual_path, @virtual_path = @virtual_path, #{@virtual_path.inspect};_old_output_buffer = @output_buffer;#{locals_code};#{code}
    ensure
      @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer
    end
  end_src
```

When the source method was called, we store given local_assigns (say `{ title: "Hello" }`) into the instance variable. And then create a binding method `title` if there's no `title` method. So Rails can use the `title` method to access the local assigns.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/zubot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

