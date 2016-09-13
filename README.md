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

For now it will automatically do the precompilation for your. You can monkey-patch the `ActionView::Template#compile!` method to see if it works like:

```
module ActionView
  class Template
    def compile!(view)
      puts "Template: #{virtual_path} compiled? #{@compiled}"

      return if @compiled
    end
  end
end
```

You should see something like this during boot time:

```
# I will fix the duplicated compilation issue later
Template: layouts/application compiled? false
Template: layouts/mailer compiled? false
Template: layouts/mailer compiled? false
Template: posts/_form compiled? false
Template: posts/edit compiled? false
Template: posts/index compiled? false
Template: posts/index compiled? false
Template: posts/new compiled? false
Template: posts/show compiled? false
Template: posts/show compiled? false
Template: kaminari/_first_page compiled? false
Template: kaminari/_first_page compiled? true
Template: kaminari/_first_page compiled? true
```

And after you visit a page (say `posts/1`) You will see

```
......
  Rendering posts/show.html.erb within layouts/application
Template: posts/show compiled? true
  Rendered posts/show.html.erb within layouts/application (8.4ms)
Template: layouts/application compiled? true
......

```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/zubot. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

