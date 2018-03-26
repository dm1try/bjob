# BJob

Simple background processing without any external dependencies(only Ruby core library is used).
Jobs are executed in a separate process(UNIX sockets are used for inter-process communication).
Jobs are persisted in memory but there is a fallback file-based storage strategy for unfinished jobs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bjob', require 'bjob/async'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bjob

## Usage
```ruby
# job.rb
require 'bjob/async'

class Job
  include BJob::Async

  def run(some_message)
    p "UPCASED: #{some_message.upcase}"
  end
end
```

1. run `bjob -r job` in terminal #1
2. run `ruby -I. -r job -e 'Job.async("message")'` in terminal #2

terminal #1 output should be something like this:
```
I, [2018-03-26T13:14:09.876185 #53274]  INFO -- : job #f7a8ac4081 started
"UPCASED: MESSAGE"
I, [2018-03-26T13:14:09.876343 #53274]  INFO -- : job #f7a8ac4081 done: 3.8e-05 ms

```

TODO: Write usage instructions for integration with frameworks.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/bjob. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the BJob project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/bjob/blob/master/CODE_OF_CONDUCT.md).
